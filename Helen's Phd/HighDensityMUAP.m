function MUAP = HighDensityMUAP(EMG, MUST, Fs, varargin)
% EMG: N by M Matrix. N is the sample number of the signal,M is the
% number channels;
% MUST: Motor unit spike train, N by K Matrix with 0 or 1 only. N is the 
% sample number of the signal, K is the number of motor unit decomposed. 
% Fs: sampling frequency
% varargin: 'BiPolar' or 'MonoPolar'. Default is 'BiPolar' STA.

[~, NumCh] = size(MUST);
NeedleType = 'BiPolar';
WinPrior=-0.02; WinPost =0.02;


for i = 1:2:length(varargin)
    switch varargin{i}
        case 'NeedleType'
            NeedleType = varargin{i+1};
    end
end
color = ['r';'y';'b';'g';'k';'m';'c'];
for j = 1:NumCh
N = length(MUST);
Time = (1/Fs:1/Fs:N/Fs)';
Fir = [Time MUST(:,j)];
WSyn=findsuperimposecount(Fir);
[Len,NumCh] = size(EMG);
if strcmp(NeedleType,'MonoPolar')==1
    [Temp, ~, ~] = STAmuWH128(Fir(:,2),EMG , WinPrior, WinPost,1/Fs,0,WSyn{1},NumCh);
else if strcmp(NeedleType,'BiPolar')==1
        DiffEMG = zeros(Len,NumCh-8);
        for k = 1:NumCh-8
            DiffEMG(:,k) = EMG(:,k)-EMG(:,k+8);
        end
        NumCh = NumCh-8;
        [Temp, ~, ~] = STAmuWH128(Fir(:,2),DiffEMG , WinPrior, WinPost,1/Fs,0,WSyn{1},NumCh);
    end
end
if nargout == 0
    axisrange = max(max(Temp)-min(Temp));
    figure;
    for n = 1:NumCh %Plot Motor unit templates for each bipolar channel
        set(gca, 'xtick', []);set(gca, 'ytick', []);
        subplot(NumCh/8,8,n)
        p = randperm(7,1);
        plot(Temp(:,n),color(3),'linewidth',2);
        axis([0 205 -0.7*axisrange 0.7*axisrange])
        box off;
        set(gca,'Visible','off');
    end
end
MUAP{j} = Temp;
end
end