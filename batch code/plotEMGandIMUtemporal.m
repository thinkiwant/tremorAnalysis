    %% To plot emg and kinematics signals
i = 1;
figure
%data = experiment8{i};
data = rawData;
data = data';
ModuleN = (size(data,2)-6)/64;
t = [0:length(data)-1]/2000;
ax(1) = subplot(211);
emg = data(:,[0:64:(ModuleN-1)*64]+27);
shft = std(emg(:,1))*10;
emg = emg+ones(size(emg,1),1)*shft  * [0:size(emg,2)-1];
plot(t,emg)
set(gca,'FontSize',18)
ylabel('Voltage (mV)')
legend('  (Ch27)','M2 (Ch27)','M3 (Ch27)','M4 (Ch27)');
trialT = '(Sub3, DBS-on, Resting 2)';
title(strcat("EMG ",trialT))
ax(2) = subplot(212)
linkaxes(ax,'x')
plot(t,data(:,[257:259]-64*(4-ModuleN)))
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Acceleration (g)')
legend('X axis','Y axis','Z axis');
title(strcat("Kinematics ",trialT)) 