function [f] = findPeaksWithinBand(x, varargin)

n = size(x,2);
fs = 2000;
lowFreq = 3;
highFreq = 6;

for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
        case 'lowFreq'
            lowFreq = varargin{i+1};
        case 'highFreq'
            highFreq = varargin{i+1};
    end
end

if(highFreq <=lowFreq)
    error("null bandwidth\n");
end


[pxx,f] = pwelch(x);
fn = length(f);
threshID1 = lowFreq/(fs/2)*pi;% PSD of frequency between lowFreq and highFreq (Hz) is considered
threshID2 = highFreq/(fs/2)*pi;
windowId = find(f>=threshID1 & f<=threshID2);
peakId=zeros(1,n);;
for i = 1:n
[ps, id] = findpeaks(pxx(windowId,i));
[~,peaki] = maxk(ps,1);
peakId(i) = windowId(id(peaki));
end
meanPeak = round(mean(peakId));
f =  meanPeak*(fs/2)/fn;

end
