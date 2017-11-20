%It isn't at all clear what you load here. So:
%out.mat contains extct and TS. 
%  extct is a cell array with nSims cells. Each cell contains a 41xn array. (1,:) slices the event times (including start and end). (2:end,ii) slices the biomasses of all species at the ii-th extinction event.
%  TS is a 3-d array of size 40x1000xnSims. This is the last 1000 time steps of the biomasses for all species. This should be useful for analyzing the equilibrium state (check for oscillations, fft,etc.)
%
%simParams
%.mat contains the cell array simParams. each element of the cell array is a structure. This is the structure:
%{
          web: 1                 %This is the index of tyhe niche web used
         fPar: 0                 %This is the fraction of parasites 
        kFree: 1                 %This is exponent  on free-living BSR
        kPara: -3                %This is exponent on parasite BSR
     fracFree: 0                 %This is host refuge identifier   
     fracPara: 0                 %This is the concomittant identifier
    modelCode: [0 0]             %This is redundant.
         para: [40×1 logical]    %This tells which species are parasites
           LL: [250×2 double]    %This is the link list
           B0: [40×1 double]     %THis is the initial Biomass.
           gr: [40×1 double]     %Growth rates of basal species
     parOrder: [1×33 double]     %This is the order of parasites.
           TL: [40×1 double]     %This is nothing.
         patl: [40×1 double]     %This is the prey-averaged trophic level.
%}
if ~exist('simParams')
    load 'rawOutputs.mat'
    load 'simParams.mat'
    load 'metaSimData.mat'
end

%The goal of this code is to convert the contents of rawoutputs.mat to complicated 
%multi-dimensional arrays that I can plot.

finalBiomasses = nan(S,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));
meanBiomasses = nan(S,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));
stdBiomasses = nan(S,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));

meanTotalBiomasses = nan(4,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));
stdTotalBiomasses = nan(4,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));


abcSLopes = nan(2,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));
abcRSquares = nan(2,nWeb,numel(fParAll0),nFacts(1),nFacts(2),nFacts(3),nFacts(4));

nSims = numel(extcts);

fParAll = fParAll0;

for ii = 1:nSims
    
    webNo = simParams{ii}.web;
    fact1Level = simParams{ii}.kFree == kFrees;
    fact2Level = simParams{ii}.kPara == kParas;
    fact3Level = simParams{ii}.fracFree;
    fact4Level = simParams{ii}.fracPara;
    fParLevel = simParams{ii}.fPar == fParALll0;
 
    meanBiomasses(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = mean(TS(:,:,ii),2);
    finalBiomasses(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = TS(:,end,ii);
    stdBiomasses(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = std(TS(:,:,ii),0,2);

    para = simParams{ii}.para;
    basal = simParams{ii}.gr>0;
    

    paras(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = para;
    basals(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = basal;
    frees(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = free;
    
    abcSlopes(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = bs(simNo,:);
    abcRSquares(:,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = rs(simNo,:);

    
    %Total biomass is weird to me. Why? -glad you asked. It's because the scale of species biomasses
    %varies geometrically. So simply summing up to get a total biomass ends up being skewed by a 
    %few very abundant species, with the last few decimals changing slightly because of most of 
    %the rest - the rest that have a profound impact on the overall state we are in. AT least, they
    %have a profound impact on the persistence metric! 
    
    %this has 4 rows in first dimensino. These correspond to all, basal, free, and parasitic biomasses
    meanTotalBiomasses(1,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = mean(sum(TS(:,:,ii)));
    stdTotalBiomasses(1,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = std(sum(TS(:,:,ii)));

    meanTotalBiomasses(2,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = mean(sum(TS(basal,:,ii)));
    stdTotalBiomasses(2,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = std(sum(TS(basal,:,ii)));
    
    meanTotalBiomasses(3,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = mean(sum(TS(free,:,ii)));
    stdTotalBiomasses(3,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = std(sum(TS(free,:,ii)));
    
    meanTotalBiomasses(4,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = mean(sum(TS(para,:,ii)));
    stdTotalBiomasses(4,webNo,fParLevel,fact1Level,fact2Level,fact3Level,fact4Level) = std(sum(TS(para,:,ii)));
end

save('out.mat','meanBiomasses','finalBiomasses','stdBiomasses','meanTotalBiomasses','stdTotalBiomasses','abcSlopes','abcRSquares','paras','basals','frees');
