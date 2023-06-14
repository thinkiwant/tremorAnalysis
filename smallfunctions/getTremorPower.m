function [id, P, psd, f, f_low_id, f_up_id] = getTremorPower(sig,varargin)
% s is an M-by-N matrix, each column corresponding to a signal.
% this function returns the id of column(out of N) vector which has the
% greatest variance in the matrix, while s being the accumulated power. 

fs = 2000;

lowFreq = 3;    % the default lower edge for the window
highFreq = 7;  % the default upper edge ...
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
            break;
        case 'lowFreq'
            lowFreq = varargin{i+1};
            break;
        case 'highFreq'
            highFreq = varargin{i+1};
            break;
    end
end

[b,a] = butter(1,1/1000,'high');
sigfilt = filtfilt(b,a,sig);

[psd, f] = pwelch(sigfilt, fs*2, [], fs*4,fs);

f_id = find(f>=lowFreq & f<=highFreq);
f_low_id = f_id(1);
f_up_id = f_id(end);
P = sum(psd(f_id, :));

[~, id] = max(P);


end