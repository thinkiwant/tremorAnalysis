function [id, s] = findMaxVar(sig,varargin)
% s is an M-by-N matrix, each column corresponding to a signal.
% this function returns the id of column(out of N) vector which has the
% greatest variance in the matrix, while s being the accumulated power. 

fs = 2000;
lowFreq = 2;    % the default lower edge for the window
highFreq = 12;  % the default upper edge ...
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
            break;
        case 'lowFreq'
            lowFreq = varagin{i+1};
            break;
        case 'highFreq'
            hightFreq = varagin{i+1};
            break;
    end
end

[pxx,f] = pwelch(sig);
n = length(f);
threshID1 = lowFreq/fs*pi;% PSD of frequency between lowFreq and highFreq (Hz) is considered
threshID2 = highFreq/fs*pi;
p=pxx(find(f>threshID1&f<threshID2),:);
plot(p);
s = sum(p);
[~,id]=max(s);
end