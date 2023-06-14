function [p, f] = plotPSDofEMG(data, varargin)
% plot the power spectral dencity of the input data. For multi-channel
% data, the psd of each culomn is plotted respectively. Paired parameters:
% ('fs',eg.:1000), ('tremor','on')


fs = 2000;
tremor = false;
linear = false;
singleFreqRange = [4,7];
doubleSearchWidth = 1;

if nargin~=1

    for j = 1:2:length(varargin)
        switch lower(varargin{j})
            case 'fs'
                fs = varargin{j+1};
            case 'tremor'
                if varargin{j+1} == 'on'
                    tremor = true;
                end
            case 'linear'
                if varargin{j+1} == 'on'
                    linear = true;
                end
            case 'singlefreqrange'
                singleFreqRange = varargin{j+1};
        end
    end
end
Nx = length(data);
nsc = floor(Nx/4.5);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));
[pxx,f] = pwelch(data,nsc,nov,nff,fs);

if linear ~= true
    y = log10(pxx);
    ylab = 'Power Spectral Density (dB/Hz)';
else
    y = pxx;
    ylab = 'Power Spectral Density (mV^2/Hz)';
end
y = movmean(y,3); % moving average

plot(f,y,'LineWidth',1.5);

l = length(f);
upFreq = 20; % the upper limit of the frequency to be displayed
dcid = round(1*l/(fs/2));
id1 = dcid:round(upFreq*l/(fs/2));
x = f(id1);
y_front = y(id1,:);
lowP = min(min(y_front))*1.05;
highP = max(max(y_front))*1.05;
xlabel('Frequency (Hz)');
ylabel(ylab)
title(strcat("PSD (Freqency Resolution: ",num2str(fs/nsc)," Hz)"));
set(gca,'FontSize',16)
axis([0,upFreq,lowP,highP]);
hold on;
halfid = round(size(y_front,1)); % Only the lower half of the frequency band is taken

for i = 1:size(data,2)
    
    [psor, lsor] = findpeaks(y_front(dcid:halfid,i),x(dcid:halfid),'SortStr','descend');
    withId = find(lsor>singleFreqRange(1) & lsor<singleFreqRange(2));
    [v1, id1] = max(psor(withId));
    singleFreqId = withId(id1);
    singleFreq = lsor(singleFreqId);
    withId2 = find(lsor>singleFreq*2-doubleSearchWidth & lsor<singleFreq*2+doubleSearchWidth);
    [v2,id2] = max(psor(withId2));
    doubleFreqId = withId2(id2);
    doubleFreq = lsor(doubleFreqId);
    p{i} = [v1, v2];
    freq{i}= [singleFreq, doubleFreq];
%     for j = 1:length(p{i})
%         loc{j} = strcat('(',num2str(freq{i}(j)),', ',num2str(p{i}(j)),')');
%     end
    text(freq{i} +.02, p{i}, {num2str(freq{i}(1)),num2str(freq{i}(2))},'FontSize',12,'color','b');
end
end





                
