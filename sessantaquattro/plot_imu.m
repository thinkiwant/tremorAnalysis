fs1=200;
fs = 2000; %freq of EMG
emg_ch=27;
data = importdata('210714151041.txt');
data1 = data.data(:,1:6);
trigger = data.data(:,end-1);
clear data;
jtrial_num=1;

[sL_imu,eL_imu,~,~]=findInterval(trigger,fs1);
figure;
t=sL_imu(jtrial_num):1:eL_imu(jtrial_num);
t=t/fs1;
y_temp = data1(sL_imu(jtrial_num):eL_imu(jtrial_num),:);
iax(1) = subplot(311);
plot(t,y_temp(:,4));
xlabel('t (s)');
ylabel('Anglar velocity of X axiz (degree/s)');

iax(2) = subplot(312);
plot(t,y_temp(:,5));
xlabel('t (s)');
ylabel('Anglar velocity of Y axiz (degree/s)');

iax(3) = subplot(313);
plot(t,y_temp(:,6));
xlabel('t (s)');
ylabel('Anglar velocity of Z axiz (degree/s)');
linkaxes(iax,'x');

for i = 1:length(eL)
    id = sL_imu(i):(eL_imu(i)-sL_imu(i))/(eL(i)-sL(i)):eL_imu(i);
    imu_interp_data{i} = interp1(sL_imu(i):eL_imu(i),data1(sL_imu(i):eL_imu(i),:),id,'linear');
end

t=0:length(sig(1,:))-1;
t=t/fs;
%j=5;%to display jth trials
inter_emg = sL(jtrial_num):eL(jtrial_num);

y = checkSignal(sig(emg_ch,1000:end),fs);
%checkSignal(sig(emg_ch,inter_emg),fs);
%close all;
figure;
ax(1) = subplot(311);
plot(t(inter_emg),y(inter_emg),'r');
xlabel('time/(s)');
ylabel('EMG signal/(mv)');

ax(2) = subplot(312);
plot(t(inter_emg),imu_interp_data{jtrial_num}(:,4),'b');
xlabel('time/(s)');
ylabel('Anglar velocity of X axiz (degree/s)');

ax(3) = subplot(313);
stem(t(inter_emg),mu_list(:,:),'|','LineStyle','none','MarkerSize',14);
ylim([1,2]);
xlabel('time/(s)');
ylabel('MUSP firing');

linkaxes(ax,'x');
