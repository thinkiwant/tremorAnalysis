fr=cell(4,1);
for i = 1:4
    MUM = MUSPGroup{1}{i};
    for j = 1:size(MUM,2)
        fr{i}(j) = CalMeanFiringRate(MUM(:,j));
    end
end

flxRate = [fr{1},fr{2}];
extRate = [fr{3},fr{4}];

disp(sprintf("Mean Firing Rate:Flexor: %.2f±%.2f, Extensor: %.2f±%.2f pps",...
    mean(flxRate), std(flxRate), mean(extRate), std(extRate)));
emg = rawData(1:256,:)';
imu = rawData(257:259,:)';
fimu = Filter(imu,2000,'HighPass',1);

fs = 2000;
nfft = 2^13;
[pxx,f] = pwelch(emg,2^12,0,nfft,fs);
fmax = 50;
[idx,~]=find(f<fmax);
mf = mean(pxx(idx,:),2);
plot(f(idx),mf,'LineWidth',2,'Color','b')
hold on;
[peaks, locs]=findpeaks(mf,f(idx),'NPeaks',5,'SortStr','descend')
plot(locs,peaks,'or')
xlabel('频率 (Hz)')
ylabel('功率密度 (mV^2/Hz)')
title('肌电功率谱密度图');
set(gca,'FontSize',16)

figure
fs = 2000;
nfft = 2^13;
[pxx,f] = pwelch(fimu,2^12,0,nfft,fs);
fmax = 50;
[idx,~]=find(f<fmax);
mf = mean(pxx(idx,:),2);
plot(f(idx),mf,'LineWidth',2)
hold on;
[peaks, locs]=findpeaks(mf,f(idx),'NPeaks',5,'SortStr','descend')
plot(locs,peaks,'or')
xlabel('频率 (Hz)')
ylabel('功率密度 (g^2/Hz)')
title('加速度传感器功率谱密度图');
set(gca,'FontSize',16)