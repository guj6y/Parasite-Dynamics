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
header = 'yPerAll,sPerAll,yPerPara,sPerPara,yPerFree,sPerFree,yBioBasal,sBioBasal,yBioFree,sBioFree,yBioPara,sBioPara';
fileFormat = repmat('%.9e,',12);
fileFormat = fileFormat(1:end-1);

for plotNo = 1:4;    
    
    modelNo = selector(plotNo,1);
    freeSize = selector(plotNo,2);

    perAll = squeeze(persistences.all(:,:,modelNo,modelNo,freeSize,:));
    perPara = squeeze(persistences.para(:,:,modelNo,modelNo,freeSize,:));
    perFree = squeeze(persistences.free(:,:,modelNo,modelNo,freeSize,:));

    bioPara = squeeze(biomasses.para(:,:,modelNo,modelNo,freeSize,:));
    bioFree = squeeze(biomasses.free(:,:,modelNo,modelNo,freeSize,:));
    bioBasal = squeeze(biomasses.basal(:,:,modelNo,modelNo,freeSize,:));


    meanPerAll = squeeze(mean(perAll));
    meanPerPara = squeeze(mean(perPara));
    meanPerFree = squeeze(mean(perFree));

    stdPerAll = squeeze(std(perAll));
    stdPerPara = squeeze(std(perPara));
    stdPerFree = squeeze(std(perFree));
    
    meanBioBasal = squeeze(mean(bioBasal));
    meanBioPara = squeeze(mean(bioPara));
    meanBioFree = squeeze(mean(bioFree));

    stdBioBasal = squeeze(std(bioBasal));
    stdBioPara = squeeze(std(bioPara));
    stdBioFree = squeeze(std(bioFree));
    
    matrixSaveBigPara = [meanPerAll(:,1),stdPerAll(:,1),meanPerPara(:,1),stdPerPara(:,1),meanPerFree(:,1),stdPerFree(:,1),...
                           meanBioBasal(:,1),stdBioBasal(:,1),meanBioFree(:,1),stdBioFree(:,1),meanBioPara(:,1),stdBioPara(:,1)];

    matrixSaveSmallPara = [meanPerAll(:,2),stdPerAll(:,2),meanPerPara(:,2),stdPerPara(:,2),meanPerFree(:,2),stdPerFree(:,2),...
                           meanBioBasal(:,2),stdBioBasal(:,2),meanBioFree(:,2),stdBioFree(:,2),meanBioPara(:,2),stdBioPara(:,2)];

    
    fileName = sprintf('%s-%s-bigPara',modelNames{modelNo},freeNames{freeNo});
    fid = fopen(fileName);
    fprintf(fid,'%s\n',header);
    fprintf(fid,sprintf('%s\n',fileFormat),matrixSaveBigPara');
    fclose(fid);

    fileName = sprintf('%s-%s-smallPara',modelNames{modelNo},freeNames{freeNo});
    fid = fopen(fileName);
    fprintf(fid,'%s\n',header);
    fprintf(fid,sprintf('%s\n',fileFormat),matrixSaveSmallPara');
    fclose(fid);

end
