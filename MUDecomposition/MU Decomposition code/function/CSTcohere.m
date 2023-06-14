function [MeanCo,SteCo,F, CMFR] = CSTcohere (Fir0,NumMUSelected,N)
% FirMU(N*M): First column is the time index;(M-1) motor units data are ordered in the corresponding time series
% NumMUSelected(Scalar): Ramdomly pick number of motor units selected to be anaylzed
% N(Scalar): Number of random combination to be analyzed
FirMU = Fir0(:,2:end);
[Numsamples,NumMU] = size (FirMU);     %Find the total samples of each channel and total number of motor units
Fs = round(Numsamples/(max(Fir0(:,1))-min(Fir0(:,1))));
for i = 1:N   
    p1 = randperm(NumMU);     %Ramdomly pick motor units from the entire motor units pool
    Group = p1<=NumMUSelected;
    FirSelected = FirMU(:,Group);
    FirSelected = full(FirSelected);
    p2 = randperm(NumMUSelected);     %Ramdonly separate motor units analyzed into two groups
    Group1 = p2<=NumMUSelected/2;
    Group2 = p2>NumMUSelected/2;
    FirGroup1 = FirSelected(:,Group1);
    FirGroup2 = FirSelected(:,Group2);
    D = Fs/1000;
    FirSumGroup1 = sum(FirGroup1,2);
    FirSumGroup2 = sum(FirGroup2,2);
    FirSumGroup = sum(FirSelected,2);
%     FirSumGroupDec1 = FirSumGroup1;
%     FirSumGroupDec2 = FirSumGroup2;
    FirSumGroupDec1 = decimate(FirSumGroup1,round(D));
    FirSumGroupDec2 = decimate(FirSumGroup2,round(D));
    [Cototal(:,i),F] = mscohere(FirSumGroupDec1,FirSumGroupDec2,hanning(1024),768,1024,1000);
    Index = find(FirSumGroup==1);
    T = (Index(end)-Index(1))/Fs;
    CMFRTemp(i) = length(Index)/T;
end
% MeanCo = mean(Cototal,2);

MeanCotemp = mean(Cototal,2);
% MeanCo = MeanCotemp - mean(MeanCotemp(300:500));
MeanCo = MeanCotemp;
MeanCo(MeanCo<0)=0;
SteCo = std(Cototal,0,2)/sqrt(N);
CMFR = mean(CMFRTemp);
end



