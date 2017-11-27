if ~exist('simParams','var')
    load '../raw/out.mat'
    load '../raw/simParams.mat'
    load '../raw/metaSimData.mat'
end
cd ../figures/

numberOfFactors = numel(nFacts); 
 
nFPar = numel(fParAll0);

alpha = 0.05;

speciesCategories = {'all','para','free','basal'};
statisticUsed = {'per','bio','cv','abc-common','abc-natural'};
%make split data ('on' and 'off' for the 2-split; numbered
%for the full split
data = biomasses;

iiHeaders2Split = 'x,yOn,mOn,yOff,mOff';
iiHeaderDiffSplit = 'x,y1,y2,y3,y4,m1,m2,m3,m4';
allStats = {persistences,biomasses,cvs,abc.common,abc.natural};
%Think about automating this?
statCode = statisticUsed{1};
stat = persistences;

for statCode = 1:5
    if statCode == 4
        speciesCategories = {'slopes','rSquared'};
    end
    
    stat = allStats{statCode};
    statID = statisticUsed{statCode};
    
    for spCat = speciesCategories
        
        filenamePrefix = sprintf('%s-%s',statID,spCat{:});

        meanDiffs= nan(nFPar,numberOfFactors);
        marginDiffs = nan(nFPar,numberOfFactors);
        
        for ii = 1:numberOfFactors %numberOfFactors will always be 4.
            factSize = nFacts(ii);
            selector = cell(numel(size(stat.(spCat{:}))));
            [selector{:}] = deal(':');
            
            meansSplit    = zeros(nFPar,factSize);
            marginsSplit  = zeros(nFPar,factSize);
            margins2Split = zeros(nFPar,factSize);

            jjOn = 2;
            jjOff = 1;
            iiHeaderYs = 'x,';
            iiHeaderMs = '';
            formatAllSplit = '%.3f,';
            for jj = 1:factSize %originally was 2, but can handle more.
                selector{ii+2} = jj;
              
                
                datajj  = permute(stat.(spCat{:})(selector{:}),[1,3,4,5,6,2]);
                datajj  = reshape(datajj,[],nFPar);
                
                if jj == jjOff
                    dataOff = datajj;
                elseif jj == jjOn
                    dataOn = datajj;
                end
                meanjj  = mean(datajj,'omitnan');
                stdjj   = std(datajj,'omitnan');
                njj = sum(isfinite(datajj));

                nObs = sum(isfinite(meanjj));
                %Need to really think about how to apply Bonferroni here.
                %These are useful if we are doing an all for all bonferroni. 
                m2 = 2*nObs;
                mNFact = factSize*nObs;
                tCrit2 = tinv(1-alpha/(2*m2),njj-1);
                tCritN = tinv(1-alpha/(2*mNFact),njj-1);
                
                marginsSplit(:,jj) = tCritN.*stdjj./sqrt(njj);
                margins2Split(:,jj) = tCrit2.*stdjj./sqrt(njj);

                meansSplit(:,jj) = meanjj;
                iiHeaderYs = strcat(iiHeaderYs,sprintf('y%u,',jj));
                iiHeaderMs = strcat(iiHeaderMs,sprintf('m%u,',jj));
                formatAllSplit = strcat(formatAllSplit,'%.9e,%.9e,');
            end
            dataDiff = dataOn-dataOff;
            nDiff = sum(isfinite(dataDiff));
            
            meanDiff = mean(dataDiff,'omitnan');
            stdDiff = std(dataDiff,'omitnan');
            mDiff = sum(isfinite(meanDiff));
            meanDiffs(:,ii) = meanDiff;
            tCritDiff = tinv(1-alpha/(2*mDiff),nDiff-1);
            marginDiff = stdDiff./sqrt(nDiff).*tCritDiff;
            
            
            marginDiffs(:,ii) = marginDiff;
            
            iiHeaderMs(end) = [];
            formatAllSplit(end) = [];
            split2FileName = sprintf('%s-2-subplot-%u',filenamePrefix,ii);
            fid2Split = fopen(split2FileName,'w');
%Need to get a format string of %.9f, entries.
            fprintf(fid2Split,'%s',iiHeaders2Split);
            fprintf(fid2Split,'\n%.2f,%.9e,%.9e,%.9e,%.9e',...
                              [fParAll0'...
                              ,meansSplit(:,jjOn)...
                              ,margins2Split(:,jjOn)...
                              ,meansSplit(:,jjOff)...
                              ,margins2Split(:,jjOff)...
                              ]'...
                   );
            fclose(fid2Split);
            
            iiHeaderFullSplit = strcat(iiHeaderYs,iiHeaderMs);

            splitNFileName = sprintf('%s-full-subplot-%u',filenamePrefix,ii);
            fidNSplit = fopen(splitNFileName,'w');
            fprintf(fidNSplit,'%s',iiHeaderFullSplit);
            fprintf(fidNSplit,sprintf('\n%s',formatAllSplit)...
                              ,[fParAll0'...
                              ,meansSplit...
                              ,marginsSplit]'...
                   );
            fclose(fidNSplit);
            selector{ii+2} = ':';
        end
        diffFilename = sprintf('%s-diffs',filenamePrefix);
        fidDiff = fopen(diffFilename,'w');
        diffFormat = strcat('%.3f,',repmat('%.9e,',1,7),'%.9e');
        fprintf(fidDiff,'%s',iiHeaderDiffSplit);
        fprintf(fidDiff,sprintf('\n%s',diffFormat),...
                        [fParAll0'...
                        ,meanDiffs...
                        ,marginDiffs...
                        ]'...
                );
        fclose(fidDiff);
    end
end
