%% original codes
imu = experiment1{2}(257,:);

[b,a] = butter(2,[4/1000,7/1000],'bandpass');
imu_f = filtfilt(b,a,imu);
x(1)=subplot(211);
plot(imu);
hold on
plot(imu_f,'LineWidth',2)

width = 2000;
hwidth = width/2;

tran_p=zeros(length(imu),1);
tol = 3;


for idx = hwidth+1:20:length(imu_f)-hwidth
    left_std = std(imu_f(idx-hwidth:idx-1));
    right_std = std(imu_f(idx:idx+hwidth));
    less_std = min(left_std, right_std);
    diff_std = abs(left_std - right_std);
%     if(diff_v/less_std>tol)
%         tran_p = [tran_p , idx];
%     end
    %tran_p(idx) = diff_v/less_std;
    tran_p(idx) = left_std;
end

% plot(tran_p,imu_f(tran_p),'ro')
x(2)=subplot(212);

% spectrogram(imu_f,1024,[],[],2000,'yaxis')
plot(tran_p);

linkaxes(x,'x')

%% Tang Xin's version

% imu = experiment3{1}(257,:);
% imu1 需要分段
% imu2 需要分段
% imu3 可以不分段
% imu4 不需要分段
% imu4 不需要分段
%% load signal
load("C:\Users\admin\Desktop\imu\imu1.mat")
%% filtering
[b,a] = butter(2,[4/1000,7/1000],'bandpass');
imu_f = filtfilt(b,a,imu);
%% Plot the signal
figure,subplot(211),plot(imu);
hold on
imuabs = abs(imu_f);
plot(imuabs,'LineWidth',2)
% spectrogram(imu_f,1024,[],[],2000,'yaxis')
plot(diff(imuabs));
%% Sliding Window Operation
% Tell the sinal type
%移位窗均值STD：反映信号不同区段均值的波动情况。窗宽大比较好
% 信号态1的值最大，meanstd*100>20
% 信号态2的值最小 meanstd*100> 12
% 信号态3的值中等 20> meanstd*100> 12 需要手动查看
width = 1000;
hwidth = width/2;
meantemp = [];
stdtemp = [];
meanimu = [];
upbound = 20;
lowbound = 12;
for idx = 1:width:length(imuabs)-width
    imumean = mean(imu(idx:idx+width));
    Totalmean = mean(imuabs(idx:idx+width));
    Totalstd = std(imuabs(idx:idx+width));
    
    meanimu = [meanimu, imumean];
    meantemp = [meantemp, Totalmean];
    stdtemp = [stdtemp, Totalstd];
end
meanstd = std(meanimu)*1000;
if meanstd >= upbound
    flag = 1;
elseif meanstd <= lowbound
    flag = 2;
else
    flag = 3;
end
%% Trancate the signal
if flag == 1
    [tol,stdidx] = min(meantemp);
    tolstd = stdtemp(stdidx);
    lastpeak = 0;
    peakidx = [];
    for idx = 1:length(imuabs)-1
        grad = imuabs(idx+1)-imuabs(idx);
        if -1e-4 < grad && grad < 0 && (idx-lastpeak)>100 %% 一阶差分小于0，同时距离上次峰值小于50ms.
            lastpeak = idx;
            peakidx= [peakidx,lastpeak];
        end
    end
    stem(peakidx,imuabs(peakidx));
    sigtemp = imuabs(peakidx);
    sigtemp2 = zeros(size(sigtemp));
    sigtemp2(sigtemp>50*tol)=1;
    plot(peakidx,sigtemp2);
else
    disp(['The signal is type',num2str(flag),'! Please check it !',])
end