function [If] = calInstantaneousPhase(sig, varargin)
tremor = 1;
fs = 2000;
if nargin ~=1
    
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
        case 'vol'
            tremor = 0;
    end
end
end

t=0:length(sig(:,1))-1;
t=t/fs;
windowsWidth = 2000;
noverlap = 0.1*windowsWidth;

[b,a] = butter(3,1/fs*2,'high');
sig1 = filtfilt(b,a,sig);

[pxx,f] = pwelch(sig1, windowsWidth, noverlap,2^13, fs);
% 
% plot(f,10*log10(pxx));
% xlabel('Freq /(Hz)');
% ylabel('Power/Freq /(dB/Hz)');
% str = strcat("the PSD of ", inputname(1));
% title(str);

if tremor == 1
    l = length(f);
    % find the tremor frequency1
    lower_limit = floor(4/fs*2*l);
    upper_limit = floor(8/fs*2*l);
    %[~,n] = max(pxx);
    [~,n1] = findPeak(pxx(lower_limit:upper_limit,:),1);
    n = min(n1+lower_limit-1);
    
    fMax = f(n)
    strTitle = strcat("CST Bandpass-filtered around Tremor Frequency (",num2str(fMax-1),"-",num2str(fMax+1)," Hz)");
else
    fMax = 2;
    strTitle = 'CST Bandpass-filtered around Voluntary Drive Frequency(1-3Hz)';
end

[b,a] = butter(2,[fMax-1,fMax+1]/(fs/2),'bandpass');
%fvtool(b,a,'FrequancyScale','log');
y_filtered = filtfilt(b,a,sig);
%figure
plot(t,y_filtered);
xlabel('Time / (s)');
ylabel('Arbitrary Unit');
title(strTitle);
%pwelch(y_filtered)
y_al = hilbert(y_filtered);
If = unwrap(rad2deg(angle(y_al)));
%If = rad2deg(angle(y_al));
end
