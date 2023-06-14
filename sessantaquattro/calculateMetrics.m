function [metrics] = calculateMetrics(filename)
% metrics include power of acceleration, maximum intramuscular and intermuscular
% coherence and its freq, # of MUs in each muscle
load(filename);
% find valid MU by SIL
SILth = 0.75;
fs=2000;
 for i =1:4
%     eval(sprintf("s=whos('M%d');",i));
%     if(isempty(s))
%         break;
%     end
%     eval(sprintf('M = M%d;',i));
%     eval(sprintf('M{4} = find(M{1}>=SILth);'));
%     invalidL = [];
%     thresh = 20/(1/fs);
%     for j = 1:length(M{4})
%         id = M{4}(j);
%         tempSPT = M{3}(:,id);
%         onID = find(tempSPT==1);
%         diffonID = diff(onID);
%         if(~isempty(find(diffonID>thresh)))||(onID(1)>thresh)||(length(tempSPT)-onID(end)>thresh)
%             invalidL = [invalidL,j];
%         end
%     end
%     M{4}(invalidL)=[];
%     eval(sprintf('M{5} = M{3}(:,M{4});'));
%     eval(sprintf('MUSPGroup{1}{%d} = M{5};',i))
     eval(sprintf('MUSPGroup{1}{%d} = M%d;',i, i))
%     eval(sprintf('M%d = M;',i));
 end


ChanList=[27,31,36,24,45,9,43,13,52,8,63];
cList={	'#0072BD',	'#D95319', '#77AC30','#EDB120',	'#7E2F8E'};

data = rawData;
NModule = (size(data,2)-6)/64;
imu = data(:,(NModule*64+1):(NModule*64+3));    % get acceleration(x,y,z axis) 
t = 0:length(data)-1;
t=t/2000;
dataf = Filter(data,2000,'LowPass2',7);
N = 3;
inter = 0:64:(NModule-1)*64;
ch = [1:inter:NModule*64];%old configuration
shift1 = std(data(:,1))*8;
shift2 = std(dataf(:,1))*N;
onearr = [0:N*NModule-1];
x(1)=subplot(211);
ch = (inter+ChanList(1:N)');
ch = reshape(ch,[1,N*NModule]);
temp = data(:,ch)+onearr*shift1;

for i = 1:NModule
    %plot(t,temp(:,[(i-1)*N+1]),'Color',cList{i});%,grid on
    %g(i)=gca;
    plot(t,temp(:,[(i-1)*N+1:i*N]),'Color',cList{i})
    hold on
end
hold off
legend({'FCU','FCR','ECR','ECU'},'Orientation','horizontal')
set(gca,'Position',[0.1,0.46,0.8,0.45]);
%xlabel('Time/(s)');
xticks([])
ylabel('Amplitude/(mV)')
title('EMG in 4 modules(each with 1st, 17th, 33th and 49th channels, Sub1 pre-operation, resting tremor)');
%title('EMG in 4 modules(each with thr 1st channel, imitating postural tremor)');
set(gca,'FontSize',18);
x(2)=subplot(212);
[imuID, imuP] = findMaxVar(imu);
plot(t,data(:,NModule*64+imuID))%,grid on
%xlabel('Time/(s)');
%xticks([])
ylabel('Acceleration/(g/s)')
title(strcat("Kinematics ",char(87+imuID)," axis"))
set(gca,'FontSize',18);
set(gca,'Position',[0.1,0.1,0.8,0.3]);
%set(gca,'Position',[0.1,0.40,0.8,0.2])

% plot(t,dataf(:,ch)+onearr*shift2),legend
grpS=[];
N = length(MUSPGroup{1});

for i = 1:N
    grpS=[grpS, size(MUSPGroup{1}{i},2)];
end
mu = cell2mat(MUSPGroup{1});
%x(3)=subplot(313);
figure;
x(3)=gca;
disp(grpS)
MUSP_bars(mu,grpS)
title('Motor Unit Spike Trains')
set(gca,'FontSize',18);
set(gca,'Position',[0.1,0.2,0.8,0.7]);
axis([10 12 2 inf+1])
linkaxes(x,'x')

% intra\inter\partial Coherence
i=1;
m=3;
mu = cell2mat(MUSPGroup{1});
Nflex = size(MUSPGroup{1}{1},2)+size(MUSPGroup{1}{2},2);
flex=mu(:,1:Nflex);
ext=[mu(:,Nflex+1:end)];
figure
%calCoherLong(flex,ext);
tiledlayout('flow')
ax(1)=nexttile;
if(size(flex,2)>=3)
[Fc, Ff, Fl] = calCoherLong(flex);

[mFc, mFf] = findNCoherPeaks(Fc, Ff);
[drF, stdF] = calDischargeRate(flex);
cvF = stdF/drF*100;
else
    Fl=0;
    mFc=zeros(m,1);
    mFf=zeros(m,1);
end
title('Intra-Muscular Coherence(Flexor)');

ax(2)=nexttile;
if(size(ext,2)>=3)
    [Ec, Ef, El] = calCoherLong(ext);
    [mEc, mEf] = findNCoherPeaks(Ec, Ef);
else
    El=0;
    mEc=zeros(m,1);
    mEf=zeros(m,1);
end
title('Intra-Muscular Coherence(Extensor)');

if((size(flex,2)>=3)&&(size(ext,2)>=3))
ax(3)=nexttile;
[Xc, Xf, Xl] = calCoherLong(flex,ext);
[mXc, mXf] = findNCoherPeaks(Xc, Xf);
title('Inter-Muscular Coherence(Extensor vs. Flexor)');
ax(4)=nexttile;
calCoherLong(flex,flex,ext);
title('Partial Coherence(Flexor)');
s=sgtitle('S1, After Operation (DBS-on), Resting');
s.FontSize=20;
linkaxes(ax,'y')
else
    Xl=0;
    mXc=zeros(m,1);
    mXf=zeros(m,1);
end
metrics{1} = imuP *9.8^2;     % acc power
metrics{2} = grpS;      % # of MUs
metrics{3} = Fl;        % coherence confidence level of flexor
metrics{4} = mFc';       % maximum coherence for flexor
metrics{5} = mFf';       % freq in maximum coherence of flexor
metrics{6} = El;        % coherence confidence level of extensor
metrics{7} = mEc';       % maximum coherence for extensor
metrics{8} = mEf';       % freq in maximum coherence of extensor
metrics{9} = Xl;        % conherence confidence level of inter-muscles
metrics{10} = mXc';      % intermuscular coherence
metrics{11} = mXf';      % freq in maximum intermuscular coherence
metrics{12} = drF;
metrics{13} = cvF;

end

function [mc, mf] = findNCoherPeaks(c,f)
fs=2000;
lowFreq = 3;
highFreq = 12;
l = length(f);
interv = [floor(lowFreq*2*l/fs):floor(highFreq*2*l/fs)];
ff = f(interv);
[pc,pf] = findpeaks(c(interv),ff);
[~, id] = sort(pc,'descend');
hold on
m=3;
mc = pc(id(1:m));
mf = pf(id(1:m));
end

function [v, STD] = calDischargeRate(must)
fs = 2000;
l = length(must);
nMU = size(must,2);
s = sum(must);
ds = s*fs/l;
v = mean(ds);
STD= std(ds);
end