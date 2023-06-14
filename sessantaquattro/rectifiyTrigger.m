function rectifiedTrig = rectifiyTrigger(sig,refSig)
ChB = 25;
ChD = 34;
trigCh = 66;

[b,a] = butter(2,[1,45]/1000,'bandpass');


sprintf('Load the data file of module 4')
%Open_sessa_bio_file_v1_1;
sigD = sig;
%[sLD,eLD,~,~]=findInterval(sigD(trigCh,:),Fsamp);
sprintf('Load the data file of module 3')
% Open_sessa_bio_file_v1_1;
sigB = refSig;
%[sLB,eLB,~,~]=findInterval(sigB(trigCh,:),Fsamp);
refD = sigD(ChD,:);
refD = filtfilt(b,a,refD);

pwelch(refD)

refB = sigB(ChB,:);
refB = filtfilt(b,a,refB);
min_length = min(length(refB),length(refD));
[c,lags] = xcorr(refD(1:min_length),refB(1:min_length),'normalized');
figure
stem(lags,c);
[~,lag] = max(c);
lag=lags(lag);
sprintf('lag = %d',lag)


shifted_trigger = sigB(trigCh,:);
high = max(shifted_trigger);
N = max([length(refD),length(refB)])+lag;
ones_trigger=ones(1,N)*high;
shifted_trigger(1:20)=high;
shifted_trigger(end-20:end)=high;
if(lag>=0)
    ones_trigger(1,lag+1:length(refB)+lag) = shifted_trigger;
    shifted_trigger = ones_trigger(1:length(refD));
else
    ones_trigger(1,end-length(refB)-lag+1:end-lag) = shifted_trigger;
    shifted_trigger = ones_trigger(end-length(refD)+1:end);
end
figure
plot(shifted_trigger)

%sigD(trigCh,:) = shifted_trigger;
rectifiedTrig = shifted_trigger;


% for i = 1:length(sL)
% refB = sigB(ChB,sL(i):eL(i));
% refB = filtfilt(b,a,refB);
% %refB = [diff(refB),0]./refB;
% [c,lags] = xcorr(refD,refB);
% figure
% stem(lags(id),c(id));
% [~,lag] = max(c);
% lag=lags(lag);
% sprintf('lag = %d',lag-sL(i)+sL(1))
% end

