fs=2000;
chanList = [6, 27, 56+1];
data = rawData';
ModuleN = (size(data,2)-6)/64;
emgId = [chanList, chanList+64, chanList+128];
shift = 64*(4-ModuleN);
accId = [257:259]-shift;
gyroId = [260:262]-shift;


f1 = figure(1);
subplot(2,2,[1,2]);
t = [0:length(data)-1]/fs;
yyaxis left;
plot(t,data(:,27));
ylabel('EMG (mV)');

yyaxis right
plot(t,data(:,accId(end)))

xlabel('time (sec)');
ylabel('acc (Z axis) (g)');

title('Temporal Signal');
ax = gca;
set(ax,'FontSize',16)

subplot(223);
plotPSDofEMG(data(:,accId),'linear','on');
ylabel('PSD of Acceleration (g^2/Hz)')

subplot(224);
plotPSDofEMG(data(:,gyroId),'linear','on');
ylabel('PSD of Angular Velocity ((deg/s)^2/Hz)')
legend('X axis','Y axis','Z axis');


f2 = figure(2);
set(f1,'WindowState','maximized');
set(f2,'WindowState','maximized');

for i = 1:ModuleN
    subplot(2,2,i);
    plotPSDofEMG(data(:,chanList+64*(i-1)),'linear','on');
    title(strcat("PSD of EMG (Module ",num2str(i),")"))
end
lgd = legend({'CH6','CH27','CH57'})
%lgd.Position=[0.5 0.5 2 2]

