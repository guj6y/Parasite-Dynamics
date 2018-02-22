%This code  makes data plottable by latex for a full of the results. The big
%idea is comparing 'full' model to the 'null' model.

if ~exist('persistences','var')
    load('../raw/out.mat')
end

cd ../figures-fullBreakdown/

modelNames = {'null','full'};
freeNames = {'smallFree','bigFree'};

%selector: first column is null or fullmodel. second column is small or big free.
selector = [1 1;
            1 2;
            2 1;
            2 2];
header = 'x,yPerAll,sPerAll,yPerPara,sPerPara,yPerFree,sPerFree,yBioBasal,sBioBasal,yBioFree,sBioFree,yBioPara,sBioPara,yBioAll,sBioAll,yActPara,sActPara,yActFree,sActFree,yActBasal,sActBasal,yActAll,sActAll';
fParAll = [0,0.025,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5];

fileFormat = repmat('%.9e,',1,23);
fileFormat = fileFormat(1:end-1);

for plotNo = 1:4;    
    
    modelNo = selector(plotNo,1);
    freeSize = selector(plotNo,2);

    perAll = squeeze(persistences.all(:,:,freeSize,:,modelNo,modelNo));
    perPara = squeeze(persistences.para(:,:,freeSize,:,modelNo,modelNo));
    perFree = squeeze(persistences.free(:,:,freeSize,:,modelNo,modelNo));

    bioPara = squeeze(biomasses.para(:,:,freeSize,:,modelNo,modelNo));
    bioFree = squeeze(biomasses.free(:,:,freeSize,:,modelNo,modelNo));
    bioBasal = squeeze(biomasses.basal(:,:,freeSize,:,modelNo,modelNo));
    bioAll = squeeze(biomasses.all(:,:,freeSize,:,modelNo,modelNo));    

    actPara = squeeze(activities.para(:,:,freeSize,:,modelNo,modelNo));
    actFree = squeeze(activities.free(:,:,freeSize,:,modelNo,modelNo));
    actBasal = squeeze(activities.basal(:,:,freeSize,:,modelNo,modelNo));
    actAll = squeeze(activities.all(:,:,freeSize,:,modelNo,modelNo));    

    meanPerAll = squeeze(mean(perAll));
    meanPerPara = squeeze(mean(perPara));
    meanPerFree = squeeze(mean(perFree));

    stdPerAll = squeeze(std(perAll));
    stdPerPara = squeeze(std(perPara));
    stdPerFree = squeeze(std(perFree));
    
    meanBioBasal = squeeze(mean(bioBasal));
    meanBioPara = squeeze(mean(bioPara));
    meanBioFree = squeeze(mean(bioFree));
    meanBioAll = squeeze(mean(bioAll));

    stdBioBasal = squeeze(std(bioBasal));
    stdBioPara = squeeze(std(bioPara));
    stdBioFree = squeeze(std(bioFree));
    stdBioAll = squeeze(std(bioAll));
    
    meanActBasal = squeeze(mean(actBasal));
    meanActPara = squeeze(mean(actPara));
    meanActFree = squeeze(mean(actFree));
    meanActAll = squeeze(mean(actAll));

    stdActBasal = squeeze(std(actBasal));
    stdActPara = squeeze(std(actPara));
    stdActFree = squeeze(std(actFree));
    stdActAll = squeeze(std(actAll));
    
    matrixSaveBigPara = [fParAll',meanPerAll(:,1),stdPerAll(:,1),meanPerPara(:,1),stdPerPara(:,1),meanPerFree(:,1),stdPerFree(:,1),...
                           meanBioBasal(:,1),stdBioBasal(:,1),meanBioFree(:,1),stdBioFree(:,1),meanBioPara(:,1),stdBioPara(:,1),meanBioAll(:,1),stdBioAll(:,1)...
                           meanActBasal(:,1),stdActBasal(:,1),meanActFree(:,1),stdActFree(:,1),meanActPara(:,1),stdActPara(:,1),meanActAll(:,1),stdActAll(:,1)];

    matrixSaveSmallPara = [fParAll',meanPerAll(:,2),stdPerAll(:,2),meanPerPara(:,2),stdPerPara(:,2),meanPerFree(:,2),stdPerFree(:,2),...
                           meanBioBasal(:,2),stdBioBasal(:,2),meanBioFree(:,2),stdBioFree(:,2),meanBioPara(:,2),stdBioPara(:,2),meanBioAll(:,2),stdBioAll(:,2)...
                           meanActBasal(:,2),stdActBasal(:,2),meanActFree(:,2),stdActFree(:,2),meanActPara(:,2),stdActPara(:,2),meanActAll(:,2),stdActAll(:,2)];

    
    fileName = sprintf('%s-%s-bigPara',modelNames{modelNo},freeNames{freeSize});
    fid = fopen(fileName,'w');
    fprintf(fid,'%s\n',header);
    fprintf(fid,sprintf('%s\n',fileFormat),matrixSaveBigPara');
    fclose(fid);

    fileName = sprintf('%s-%s-smallPara',modelNames{modelNo},freeNames{freeSize});
    fid = fopen(fileName,'w');
    fprintf(fid,'%s\n',header);
    fprintf(fid,sprintf('%s\n',fileFormat),matrixSaveSmallPara');
    fclose(fid);

end
