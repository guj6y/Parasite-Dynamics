if ~exist('simParams')
    load 'out.mat'
    load 'simParams.mat'
    load 'metaSimData.mat'
end

nFPar = numel(fParAll0);
alive = meanBiomasses>0;

subAlive = nan(size(alive));
alivePara  = subPers;
aliveFree  = subPers;
aliveBasal = subPers;

alivePara(paras)   = alive(paras);
aliveFree(frees)   = alive(free);
aliveBasal(basals) = alive(basals);

perAll   = squeeze(mean(alive,'omitnan'));
perPara  = squeeze(mean(alivePara,'omitnan'));
perFree  = squeeze(mean(aliveFree,'omtinan'));
perBasal = squeeze(mean(aliveBaasal,'omitnan'));

dims = size(perAll);

factorSelector = cell(numel(dims),1));
factorSelector{:} = deal(':');
alpha = 0.05;

%This needs to be a function; input an array of a predictable size. output
%processed data/ the function writes it to a file. 
for ii = 1:4

    nFact = nFcats(ii);
    nExtra = nFact -2;
    nFact = 2;

    perAllToSave   = nan(nFPar,2,nFact);
    perParaToSave  = nan(nFPar,2,nFact);
    perFreeToSave  = nan(nFPar,2,nFact);
    perBasalToSave = nan(nFPar,2,nFact);
    

    %make the split data (for the main guys)
    for jj = 1:nFact
        factorSelector{ii+2} = jj;
        %Persistences
        perAllThisFactor   = permute(perAll(factorSelector{:}),[1 3 4 5 6 2]);
        perParaThisFactor  = permute(perPara(factorSelector{:}),[1 3 4 5 6 2]);
        perFreeThisFactor  = permute(perFree(factorSelector{:}),[1 3 4 5 6 2]);
        perBasalThisFactor = permute(perBasal(factorSelector{:}),[1 3 4 5 6 2]);

        perAllThisFactor   = reshape(perAll(factorSelector{:}),[],nFPar);
        perParaThisFactor  = reshape(perPara(factorSelector{:}),[],nFPar);
        perFreeThisFactor  = reshape(perFree(factorSelector{:}),[],nFPar);
        perBasalThisFactor = reshape(perBasal(factorSelector{:}),[],nFPar);
        
        meanPerAllToSave(:,1,jj)   = mean(perAllThisFactor,'omitnan');
        meanPerParaToSave(:,1,jj)  = mean(perParaThisFactor,'omitnan');
        meanPerFreeToSave(:,1,jj)  = mean(perFreeThisFactor,'omitnan');
        meanPerBasalToSave(:,1,jj) = mean(peBasalThisFactor,'omitnan');
        
        %Bonferroni corrections:
        m = [sum(isfinite(perAllToSave(:,1,jj)));
                 isfinite(perParaToSave(:,1,jj)));
                 isfinite(perFreeToSave(:,1,jj)));
                 isfinite(perBasalToSave(:,1,jj)))];

        df = [sum(isfinite(perAllThisFactor);
              sum(isfinite(perParaThisFactor);
              sum(isfinite(perFreeThisFactor);
              sum(isfinite(perBasalThisFactor)]-1;
       
        tCrit = invt(1-alpha./m,df);
        meanPerAllToSave(:,2,jj)   = std(perAllThisFactor)./sqrt(sum(isfinite(perAllThisFactor)))*tCrit(1);
        meanPerParaToSave(:,2,jj)  = std(perParaThisFactor)./sqrt(sum(isfinite(perParaThisFactor)))*tCrit(2);
        meanPerFreeToSave(:,2,jj)  = std(perFreeThisFactor)./sqrt(sum(isfinite(perFreeThisFactor)))*tCrit(3);
        meanPerBasalToSave(:,2,jj) = std(perBasalThisFactor)./sqrt(sum(isfinite(perBasalThisFactor)))*tCrit(4);
        factorSelector{ii+2} = ':';
    end
    
    %make diff data

    %make split data (for the extras)
%persistenceAll

%persistenceBasal

%persistenceFree

%persistencePara

%cvAll

%cvBasal

%cvPara

%cvBasal

end
