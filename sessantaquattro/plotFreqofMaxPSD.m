function plotFreqofMaxPSD(sig, fs)
% sig consists of N cells of Ch x L arrays.
clc
if nargin>1
    Fsamp = fs;
else
    Fsamp = 2000;
end
titleList = ["Resting 1","Resting 2","Posture 1","Posture 2","Wrist Abduction 1","Wrist Abduction 2"];
N = length(sig);

clear TrialFreqM;
clear standardError;
chan_list{2} = 1:64;% Correspond to datafile named with letter 'A'
chan_list{3} = 65:128;
chan_list{1} = 129:192;
chan_list{4} = 193:256;
chan_list{5} = 257:259;
chan_list{6} = 260:262;
a = figure();

TrialNum=6;
for trialIdx = 1:TrialNum
    trialIdx
    TrialFreqM=[];
    standardError=[];
    PmM=[];
    PmE=[];
    for mi =1:6 % 6 modules
        mi
        pm=[];
        signal = sig{trialIdx}(chan_list{mi},:)';
        if  mi == 6
            signal = signal *pi / 180; % transform to radian unit
        end
        [pxx,f] = checkSignal(signal(:,:),Fsamp);
        title(strcat("Trial ",num2str(trialIdx)," Module ",num2str(mi)));
        if mi==5
            leg = {'ax','ay','az'};
            legend(leg);
        elseif mi==6
            leg={'wx','wy','wz'};
            legend(leg);
        end
        %pxx = log10(pxx);
        num = floor(length(f)/1000*7);%maximum freq is set to 7 Hz
        [pm1,fm1]=findPeak(pxx,[1,2]);

        [freqList,I] = sort(f(fm1));

        for i = 1:length(I)
            pm1row = pm1(:,i);
            pm=[pm,pm1row(I(:,i))];
        end
        pm=pm';
        size(pm)
%         freqList2 = f(fm2)';
%         freq = [freqList;freqList2
        TrialFreqM = [TrialFreqM;mean(freqList',1)];
        standardError = [standardError;std(freqList',0,1)];
        PmM = [PmM; mean(pm,1)];
        PmE = [PmE; std(pm,0,1)];      
    end
    figure(a);
    subplot(2,TrialNum,trialIdx);
%     bar(TrialFreqM');
%     hold on;
%     %errorbar(TrialFreqM',standardError','k','LineStyle','none','LineWidth',1);
%     errX = [1:5;1:5];
%     errorbar(errX',standardError','k','LineStyle','none','LineWidth',1);
    barwitherr([standardError],[TrialFreqM])  % plot the mean of bar of tremor frequancy
    title(titleList(trialIdx));
    modules={"Module 1","Module 2","Module 3","Module 4","Accelerometer","Gyro"};
    set(gca,'XTickLabel',modules);
    set(gca,'FontSize',14);
    ylabel('Tremor Frequency / (Hz)');
    legend('single frequency','double frequency')
    subplot(2,TrialNum,trialIdx+TrialNum);  %plot the bar of mean of amplitude of PSD at single and double tremor frequency
    barwitherr(PmE,PmM)
    set(gca,'XTickLabel',modules);
    set(gca,'FontSize',14);
    ylabel('PSD / (Au / Hz)');
    title(titleList(trialIdx));
    legend('single frequency','double frequency')
end

end
