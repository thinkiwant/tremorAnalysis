%% calculate firing rate of different average length
figure
data = M1{3}(:,1:4);
lgL = [1,3,5,10,20];

tiledlayout('flow');
for i = 1:length(lgL)
    nexttile;
    calFirngRate(data,lgL(i));
end

%%
ChanList=[27,31,36,24,45,9,43,13,52,8,63];
cList={	'#0072BD',	'#D95319', '#77AC30','#EDB120',	'#7E2F8E'};
i=1;
%data =experiment1{i}';
data = rawData;
NModule = floor((size(data,2)-6)/64);
imu = data(:,(NModule*64+1):(NModule*64+3));
t = 0:length(data)-1;
t=t/2000;
dataf = Filter(data,2000,'LowPass2',7);
N = 3;  
inter = 0:64:(NModule-1)*64;
%ch = [1:inter:NModule*64];%old configuration
shift1 = std(data(:,1))*8;
%shift2 = std(dataf(:,1))*N;
onearr = [0:N*NModule-1];
x(1)=subplot(211);
%ch = (inter+ChanList([1:N]+1)');
ch = (inter+[1:N]');
ch = reshape(ch,[1,N*NModule]);
temp = data(:,ch)+onearr*shift1;

for i = 1:NModule
    %plot(t,temp(:,[(i-1)*N+1]),'Color',cList{i});%,grid on
    %g(i)=gca;
    plot(t,temp(:,[(i-1)*N+1:i*N]),'Color',cList{i})
    hold on
end
hold off
legend({'FC','FDS','ECR','ED'},'Orientation','horizontal')
set(gca,'Position',[0.1,0.46,0.8,0.45]);
%xlabel('Time/(s)');
xticks([])
ylabel('Amplitude/(mV)')
%title('EMG in 4 modules(each with 1st, 17th, 33th and 49th channels, Sub7 post-operation(DBS-off), resting tremor)');
title('EMG in 4 Muscles (resting tremor,Pre-operation, S11)');

%title('EMG in 4 modules(each with thr 1st channel, imitating postural tremor)');
set(gca,'FontSize',24);
x(2)=subplot(212);
imuID = findMaxVar(imu);
plot(t,data(:,NModule*64+imuID),'LineWidth',1)%,grid on
%xlabel('Time/(s)');
%xticks([])
ylabel('Acceleration/(g/s)')
title(strcat("Kinematics ",char(87+imuID)," axis"))
set(gca,'FontSize',24);
set(gca,'Position',[0.1,0.1,0.8,0.3]);
%set(gca,'Position',[0.1,0.40,0.8,0.2])
linkaxes(x,'x')
%plot(t,dataf(:,ch)+onearr*shift2),legend
grpS=[];
for i = 1:length(MUSPGroup{1})
    grpS=[grpS, size(MUSPGroup{1}{i},2)];
end
mu = cell2mat(MUSPGroup{1});
%x(3)=subplot(313);
figure
x(3)=gca
MUSP_bars(mu,grpS)
title('Motor Unit Spike Trains')
set(gca,'FontSize',24);
set(gca,'Position',[0.1,0.2,0.8,0.7])
axis([10 12 2 inf+1])
linkaxes(x,'x')
