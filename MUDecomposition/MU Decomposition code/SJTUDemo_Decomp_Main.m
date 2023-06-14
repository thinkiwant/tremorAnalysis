%clear all;clc;

M = 200;
Fs = 2000;
%DataMatrix = readmatrix('2021-6-8-16-10-35-303.csv');
DataMatrix = EMG_Reconstruct;
R = floor(800/size(DataMatrix,2));
[EMG_extend,W] = SimEMGProcessing(DataMatrix,'R',R,'WhitenFlag','On','SNR','Inf');
[s,B,SpikeTrain] = FastICA(EMG_extend,M,Fs);
[SpikeTrain,GoodIndex] = MUReplicasRemoval(SpikeTrain,s,Fs);
SpikeTrainGood = SpikeTrain(:,GoodIndex);
sGood =s(:,GoodIndex);
SIL = SILCal(sGood,Fs);


