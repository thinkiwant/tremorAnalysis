%clear all;clc; %运动伪迹去除代码
%DataMatrix = readmatrix('5_2021-6-27-18-48-47-764.csv');
%DataMatrix = DataMatrix(:,1:end-1);
R = 1;
M = 200;
Fs = 2000;
EMG_Reconstruct = MotionArtifactRemoval(DataMatrix,Fs);

