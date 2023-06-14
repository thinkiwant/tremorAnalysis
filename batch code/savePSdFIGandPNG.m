i=3;
prefix = "on posture2 ";
data = experiment1{i};
x = selectSection(data(259,:)');
data=data(:,x(1):x(2))';
tremorEMGandIMUPSD;
saveas(1,strcat(prefix, "imu psd.png"))
saveas(1,strcat(prefix, "imu psd.fig"))
saveas(2,strcat(prefix, "emg psd.png"))
saveas(2,strcat(prefix, "emg psd.fig"))

