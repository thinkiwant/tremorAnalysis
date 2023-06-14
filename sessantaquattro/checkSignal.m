function [varargout] = checkSignal(inputSignal,fs)
% This funtion preprocess the raw EMG signal with notch filtering at power
% frequency and its harmonic component, abs function as full-wave
% rectification, low pass filter to get evenlope and high pass filter to remove DC component.
% [y] = checkSignal(inputSignal, fs) returns the preprocessed signal with
% steps mentioned above.
% [Pxx, F] = checkSignal(inputSignal, fs) returns PSD and the conrresponding frequency. 
%
% 使用列向量进行计算
if size(inputSignal,1) == 1
    inputSignal = inputSignal';
end
if nargin == 1
    fs = 2000;
end

[r,c] = size(inputSignal);
T = 0:(r-1);
T = T./fs;
% t0 = 1/fs; % sampling interval
% L = r; % L length of the signal
% n = 2^nextpow2(L);
% figure;
% ax1(1) = subplot(2,2,1)
% plot(T,inputSignal)
% xlabel('Time (second)')
% ylabel('Orginal data (mV)')
% ax1(2) = subplot(2,2,2)
if fs>=1000
    outputSignal = singleChannelFilter(inputSignal,fs);
else
    outputSignal = inputSignal;
end
% plot(T,outputSignal)
% xlabel('Time (second)')
% ylabel('Filtered data (mV)')
% linkaxes(ax1,'x');
% 
% ax2(1) = subplot(2,2,3)
% F1 = fft(inputSignal,n);
% P2 = abs(F1/n);
% P1 = P2(1:(n/2+1));
% P1(2:end-1) = 2*P1(2:end-1);
% plot(0:(fs/n):(fs/2-fs/n),P1(1:(n/2)))
% xlabel('Freq of orginal signal (Hz)')
% ax2(2) = subplot(2,2,4)
% F2 = fft(outputSignal,n);
% P3 = abs(F2/n);
% P4 = P3(1:(n/2+1));
% P4(2:end-1) = 2*P4(2:end-1);
% plot(0:(fs/n):(fs/2-fs/n),P4(1:(n/2)))
% xlabel('Freq of output signal (Hz)')
% linkaxes(ax2,'x');

% 整流，取包络，计算psd
EMG_RF = abs(outputSignal);
% 低通40Hz提取包络
EMG_LPwf = Filter(EMG_RF,fs,"LowPass2",40);
EMG_LPwf = Filter(EMG_LPwf,fs,"HighPass",2);
% figure;
% subplot(2,1,1);
% plot(T,EMG_LPwf);
% subplot(2,1,2);
%window = round(2*fs/2);
window = 2^11;
%noverlap = window - 2^3;
noverlap = 0;
nfft=window*2;

%nfft = 2^15;
[Pxx, F] = pwelch(EMG_LPwf,window,noverlap,nfft,fs);

% Conduct a moving average filter on the PSD
% windowSize=15;
% Pxx = filter(ones(1,windowSize)/windowSize,1,Pxx);


part = 1:floor(length(F)*100/1000);% Only display conpoments of less than 30 Hz frequency
% a = figure();
plot(F(part),log10(Pxx(part,:)),'LineWidth',1.5);
xlabel('Frequency / (Hz)');
ylabel("PSD / (dB/Hz)");
set(gca,'FontSize',13);
% y.ISignalFre = P1;
% y.OSignalFre = P4;
y = EMG_LPwf;

if nargout == 1
    varargout = cell(1,1);
    varargout{1} = y;
elseif nargout == 2
    varargout = cell(1,2);
    varargout{1} = Pxx;
    varargout{2} = F;
else
    disp("Please return correct amounts of callback variables of 1 or 2.")
end

end

function outputSignal = singleChannelFilter(EMG,fs)
EMG_BSpf = Filter(EMG,fs, "BandStop",50);
for i = 2:7
    EMG_BSpf = Filter(EMG_BSpf,fs,"BandStop", 50*i);
end
EMG_BPma = Filter(EMG_BSpf,fs,"BandPass", [20, 390]);
outputSignal = EMG_BPma;
end


