if ~exist('simParams')
        
    load 'out.mat'
    load 'simParams.mat'
    load 'metaSimData.mat'
end

numberOfFactors = numel(nFacts); 
 
nFPar = numel(fParAll0);

alpha = 0.05;

speciesCategories = {'all','para','free','basal'};
statisticUsed = {'per','bio','cv'};
%make split data ('on' and 'off' for the 2-split; numbered
%for the full split
data = biomasses;

iiHeader2Split = 'x,yOn,mOn,yOff,mOff\n';
iiheaderDiffSplit = 'x,y1,y2,y3,y4,m1,m2,m3,m4\n';
allStats = {persistences,biomasses,cvs};
%Think about automating this?
statCode = statisticUsed{1};
stat = persistences;

for statCode = 1:3
    
    stat = allStats{statCode};
    statID = statisticUsed{statCode};
    
    for spCat = speciesCategories
        
        filenamePrefix = sprintf('%s-%s',statID,spCat);

        meanDiffs= nan(nFPar,numberOfFactors);
        marginDiffs = nan(nFPar,numberOfFactors);
        
        for ii = 1:numberOfFactors %numberOfFactors will always be 4.
            factSize = nFacts(ii);
            selector = cell(size(stat.(spCat)));
            selector{:} = deal(':');
            
            meansSplit    = zeros(nFPar,factSize);
            marginsSplit  = zeros(nFPar,factSize);
            margins2Split = zeros(nFPar,factSize);

            iiHeaderFullSplit  = 'x,';
            jjOn = 2;
            jjOff = 1;
            for jj = 1:factSize %originally was 2, but can handle more.
                selector{ii+2} = jj;
              
                
                datajj  = permute(data.(spCat)(selector{:}),[1,3,4,5,6,2]);
                datajj  = reshape(dataOn,[],nFPar);
                if jj == jjOff
                    dataOff = datajj;
                elseif jj == jjOn
                    dataOn = datajj;
                end
                meanjj  = mean(dataOn,'omitnan');
                stdjj   = std(dataOn,'omitnan');
                njj = sum(isfinite(datajj));

                nObs = sum(isfinite(meanjj));
                %Need to really think about how to apply Bonferroni here.
                %These are useful if we are doing an all for all bonferroni. 
                m2 = 2*nObs;
                mNFact = factSize*nObs;
                tCrit2 = tinv(1-alpha/(2*m2),njj-1);
                tCritN = tinv(1-alpha/(2*mNFact),njj-1);
                
                marginsSplit(:,jj) = tCritN*stdjj/sqrt(njj);
                margins2Split(:,jj) = tCrit2*stdjj/sqrt(njj);

                meansSplit(:,jj) = meanjj;
                iiHeaderYs= strcat(iiHeaderYs,sprintf('y%u,',jj));
                iiHeaderMs= strcat(iiHeaderMs,sprintf('m%u,',jj));
            end
            dataDiff = dataOn-dataOff;
            nDiff = sum(isfinite(dataDiff));
            
            meanDiff = mean(dataDiff);
            stdDiff = std(dataDiff);
            mDiff = sum(isfinite(meanDiff));
            meanDiffs(:,ii) = meanDiff;
            tCritDiff = tinv(1-alpha/(2*mDiff),nDiff-1);
            marginDiff = stdDiff/sqrt(nDiff)*tCritDiff;
            
            
            marginDiffs(:,ii) = marginDiff;
            
            headersii(end) = [];
            split2FileName = sprintf('../../figures/%s-2-subplot-%u',filenamePrefix,ii);
            fid2Split = fopen(split2FileName,'w')

            fprintf(fid2Split,iiHeaders2Split);
            fprintf(fid2Split,[fParAll0'...
                              ,meansSplit(:,jjOn)...
                              ,margins2Split(:,jjOn)...
                              ,meansSplit(:,jjOff)...
                              ,margins2Split(:,jjOff)...
                              ]'...
                   );
            fclose(fid2Split);
            
            iiHeaderFullSplit = strcat(iiHeaderYs,iiHeaderMs,'\n');

            splitNFileName = sprintf('../../figures/%s-full-subplot-%u',filenamePrefix,ii);
            fidNSplit = fopen(splitNFileName,'w');
            fprintf(fidNSplit,iiHeaderFullSPlit);
            fprintf(fidNSplit,[fParAll0'...
                              ,meansSplit...
                              ,marginsSplit]'...
                   );
            fclose(fidNSplit);
            selector{ii+2} = ':';
        end
        diffFilename = sprintf('../../figures/%s-diffs',filenamePrefix);
        fidDiff = fopen(diffFilename,'w');
        fprintf(fidDiff,iiHeaderDiffSplit);
        fprintf(fidDiff,[fParAll0'...
                        ,meanDiffs'...
                        ,marginDiffs'...
                        ]'...
                );
        fclose(fidDiff)

    end
end
