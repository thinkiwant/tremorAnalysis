% Demo
% Plot the motor unit action potential for 8*8 high-density EMG signal
clear all;clc;
Fs = 2048;
load('EMG.mat');
load('MUST.mat');
[muap]=HighDensityMUAP(EMGRaw, SpikeTrain, Fs);