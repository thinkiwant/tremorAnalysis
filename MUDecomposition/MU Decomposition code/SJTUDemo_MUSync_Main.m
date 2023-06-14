%clear all;clc;
%R = 3;
R = 4;
M = 200;
Fs = 1024;
DataMatrix = readmatrix('3_2021-6-8-16-17-3-142.csv');
DataMatrix = DataMatrix(:,1:end-1);
%DataMatrix = EMG_Reconstruct;
[EMG_extend,W] = SimEMGProcessing(DataMatrix,'R',R,'WhitenFlag','On','SNR','Inf');
[s,B,SpikeTrain] = FastICA(EMG_extend,M,Fs);
[SpikeTrain,GoodIndex] = MUReplicasRemoval(SpikeTrain,s,Fs);
SpikeTrainGood = SpikeTrain(:,GoodIndex);
NumRepetition  = 100;  % Number of repetitions of calculation. Using higher values gives more accurate results, but requires longer computation time
NumPooledMUST = 4;  % How many MUs you want to pool together for each MU spike train
% Within-muscle coherence, CSTcohere to calculation the coherence if it is one muscle from decomposed MU spike trains
TimeIndex = 1/Fs:1/Fs:length(SpikeTrainGood)/Fs;
Fir1 = [TimeIndex' SpikeTrainGood];
[MeanCo_Within,SteCo_Within,F_Within, ~] = CSTcohere (Fir1,NumPooledMUST,NumRepetition);
figure(1)
plot(F_Within,MeanCo_Within)
axis([0 60 0 1])
xlabel('Frequency /Hz');
ylabel('Coherence Values');