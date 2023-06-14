function [If] = calInstantaneousPhase1(sig, varargin)
fs = 2000;
passband = 2;
if nargin ~=1
    
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
        case 'freq'
            passband = varargin{i+1};
    end
end
end

t=0:length(sig(:,1))-1;
t=t/fs;


[b,a] = butter(3,[passband-1,passband+1]/(fs/2),'bandpass');
%fvtool(b,a,'FrequancyScale','log');
y_filtered = filtfilt(b,a,sig);
%figure
plot(t,y_filtered);
xlabel('Time / (s)');
ylabel('Arbitrary Unit');
legend

%pwelch(y_filtered)
y_al = hilbert(y_filtered);
If = rad2deg(angle(y_al));
end
