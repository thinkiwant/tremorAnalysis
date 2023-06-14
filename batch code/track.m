%% track
fs = 2000;
Mi =4;
data1 = sprintf("M%dOn1",Mi);
data2 = sprintf("M%dOff3",Mi);
cmd = sprintf("[s1, s2] = traceBetween(%s, %s);", data1, data2)
eval(cmd);
if(any(s1))
    ST1 = source2Spike(s1);
    [ST1, indexGood1] = MUReplicasRemoval(ST1, s1, fs);
    STgood1 = ST1(:,indexGood1);
    sGood1 = s1(:,indexGood1);
    SIL1 = SILCal(sGood1, fs);
    if(any(SIL1))
        plotSources(sGood1,'SIL',SIL1);
        sgtitle(sprintf("Reconstructed sources of %s (by %s, S12)", data1,data2), "FontSize", 20)
    end
end
if(~isempty(s2))
    ST2= source2Spike(s2);
    [ST2, indexGood2] = MUReplicasRemoval(ST2, s2, fs);
    STgood2 = ST2(:,indexGood2);
    sGood2 = s2(:,indexGood2);
    SIL2 = SILCal(sGood2, fs);
    if(any(SIL2))
        plotSources(sGood2,'SIL',SIL2)
        sgtitle(sprintf("Reconstructed sources of %s (by %s, S12)", data2,data1), "FontSize", 20)
    end
end

%% batch track
tic
sub = "sub5"
filepath=sprintf("D:\\experimentdata\\PD-DBS\\%s\\trace", sub);

slist={"On","On"};
if(slist{1}==slist{2})  %N is the # of groups
    N=1;
else
    N=2;
end

for sti=1:2 % 2 directions
    filesnamePattern = sprintf("%sPost%s*Segment*", sub, slist{sti});
    items{sti} = dir(filepath+"\"+filesnamePattern);
end


for i = 1:N % create null counting cells
    eval(sprintf("N%d = length(items{%d})", i, i))
end
if(N==1)
    N2=N1;
end

for i = 1:N % create null counting cells
    for m = 1:4
        eval(sprintf("totalCount%d{%d} = zeros(N%d, N%d);",i, m, i, 3-i));
        eval(sprintf("sourceandvector%d{%d} = cell(N%d,N%d);",i, m, i, 3-i));
    end
end

for  i = 1:length(items{1})
    fprintf("\ni:%d |",i);
    load(filepath+"\"+items{1}(i).name);
    for m = 1:4
        renameCmd = sprintf("M%d%s%d = M%d;", m, slist{1},i, m);
        eval(renameCmd);
    end
    for  j = 1:length(items{2})
        fprintf("\n%d ", j);
        load(filepath+"\"+items{2}(j).name);
        for m = 1:4
            renameCmd = sprintf("M%d%s%d = M%d;", m, slist{2},j, m);
            eval(renameCmd);
        end

        fs = 2000;
        for Mi =1:4;
            fprintf("m%d ", Mi);
            data1 = sprintf("M%d%s%d",Mi, slist{1}, i);
            data2 = sprintf("M%d%s%d",Mi, slist{2}, j);
            cmd = sprintf("sign = ~any(%s{1}) || ~any(%s{1});", data1, data2);
            eval(cmd);
            if(sign)
                continue;
            end
            cmd = sprintf("[s1, s2] = traceBetween(%s, %s);", data1, data2);
            eval(cmd);
            if(~isempty(s1))
                [STgood1, SIL1, sGood1, id1] = findGoodSourceID(s1,2);%
                if(any(SIL1))
                    eval(sprintf("totalCount%d{%d}(%d, %d) = length(SIL1);", 1, Mi, i, j))
                    plotSources(sGood1,'SIL',SIL1);%
                    sgtitle(sprintf("Reconstructed sources of %s (by %s, %s)", data1,data2, sub), "FontSize", 20)
                     figName = sprintf("%sBy%s",data1, data2);
                     savefig(strcat(figName,".fig"));
                     save(strcat(figName,".mat"),"STgood1","id1");
                end
            end
            if(~isempty(s2) && N==2)       
                [STgood2, SIL2, sGood2, id2] = findGoodSourceID(s2,2); %      
                if(any(SIL2))
                     eval(sprintf("totalCount%d{%d}(%d, %d) = length(SIL2);", 2, Mi, j, i))
                     plotSources(sGood2,'SIL',SIL2);
                     sgtitle(sprintf("Reconstructed sources of %s (by %s, %s)", data2, data1, sub), "FontSize", 20)
                     figName = sprintf("%sBy%s",data2, data1);
                     savefig(strcat(figName,".fig"));
                     save(strcat(figName,".mat"),"STgood2", "id2");
                end
            end
            
        end
        close all;
    end
end
toc
msgbox("process over.")
%% compute part SIL 
s= sGood1(:,3);
%ST = STgood2(:,2);
x=selectSection(s);
%x=[1:fs*10:length(s)];
plotSources(s,'SIL',1);
hold on;
for i=1:length(x)-1
    if(x(i)==x(i+1))
        continue
    end
    source=s(x(i):x(i+1));
    plot([x(i),x(i)]/fs,[-1,1]/50,'-','LineWidth',2);

    mid = mean([x(i),x(i+1)])/fs;
    sil = SILCal(source,fs);
    ST = source2Spike(source);
    [ST, indexGood1] = MUReplicasRemoval(ST, source, fs);
    fr = sum(ST)/((x(i+1)-x(i))/2000);
    text(mid,s(floor(mid)+1)+0.01,sprintf("%.2f \n %.2f",round(sil,2),fr),'FontSize',20, 'LineWidth',5);
    
end
plot([x(end),x(end)]/fs,[-1,1]/50,'-','LineWidth',2);
%% rename Mudole data
state='off';
for i =1:4
    eval(sprintf("M%d%s = M%d;",i, state, i));
    eval(sprintf("clear M%d;", i));
end

%% find segment with high SIL
fs=2000;
%s=sGood2(:,7);
leastLength = fs*10;
stepLength=fs;

for si = 1:size(sGood1,2)
    s=sGood1(:,si);
    res=[];
    i=1;
    clear sources;
    clear spikeTrains;
    sources{1}=[];
    spikeTrains{1}=[];
    while(i+leastLength<length(s))
        source = s(i:i+leastLength);
        sil = SILCal(source,fs);
        ST = source2Spike(source);
        [ST, indexGood1] = MUReplicasRemoval(ST, source, fs);
        fr = sum(ST)/(leastLength/2000);
        if(sil>=0.75 && fr>3 && fr<35)
            t= find(ST==1);
            t=[1;t];
            t=[t; length(source)];
            dt = diff(t);
            if(sum(maxk(dt,3))<leastLength/10)
                fprintf("[%d, %d]: SIL:%f, fr:%f\n",i,i+leastLength, sil, fr);
                res = [res,[i,i+leastLength]];
                sources{si} = source;
                spikeTrains{si} = ST;
                i=i+leastLength;
            else
                i=i+stepLength;
            end
        else
           i=i+stepLength; 
        end
    end
    res;
    newFileName = sprintf('similarsource%d.mat',si);
    
    if(any(res))
        save(newFileName,'sources','spikeTrains');

        x=res;
        plotSources(s,'SIL',1);
        hold on;
        for i=1:length(x)-1
            source=s(x(i):x(i+1));
            plot([x(i),x(i)]/fs,[-1,1]/50,'-','LineWidth',2);

            mid = mean([x(i),x(i+1)])/fs;
            sil = SILCal(source,fs);
            ST = source2Spike(source);
            [ST, indexGood1] = MUReplicasRemoval(ST, source, fs);
            fr = sum(ST)/((x(i+1)-x(i))/2000);
            if(mod(i,2))
            text(mid,s(floor(mid)+1)+0.01,sprintf("%.2f \n %.2f",round(sil,2),fr),'FontSize',20, 'LineWidth',5);
            end
        end
        plot([x(end),x(end)]/fs,[-1,1]/50,'-','LineWidth',2);
        hold off;
    end
end

%% pick out good sources, SIL, and ST
tic
path = 'C:\Users\admin\Desktop\sub7_lixin\OffByOff\';
cd(path)
files = dir(strcat(path,'M*'))
n = length(files);
for i = 1:n
    fprintf("file %d\n",i)
    load(strcat(path, files(i).name))
    for m = 1:3
        fprintf("module %d\n",m)      
       eval(sprintf("M = M%d;clear M%d;", m, m)); 
       if(any(M{1}))
        [ST, SIL, sGood] = findGoodSourceID(M{2});
       else
           ST=[];
           SIL=[];
           sGood = [];
       end
       eval(sprintf("M%d{1} = SIL;",m));
       eval(sprintf("M%d{2} = sGood;",m));
       eval(sprintf("M%d{3} = ST;",m));
    end
    nametemp = strsplit(files(i).name, '.');
    save(strcat(nametemp{1},"autoPick.mat"), "M1","M2","M3");
end
toc

%% count sources
files = dir("./M*auto*");
n = length(files);
count{1}=[];
count{2}=[];
count{3}=[];

for i = 1:n
    load(files(i).name);
    for m =1:3
        eval(sprintf("num = length(M%d{1});", m));
        eval(sprintf("count{%d} = [count{%d}, %d];",m,m,num));
    end
end

%%
SIL=[],ST=[],s=[];
for i=1:3
    eval(sprintf("M=M%d;",i));
    if(~any(M{1}))
        continue;
    end
    if length(M)==5
        SIL=[SIL, M{1}(:,M{4})];
        s=[s, M{2}(:,M{4})];
        ST=[ST, M{5}];
    else
        SIL = [SIL,M{1}];
        s = [s, M{2}];
        ST = [ST, M{3}];
    end
end
plotSources(s,'SIL',SIL),figure,MUSP_bars(ST)

%%  plot sources and spikes 
i=1;
t =2;
sGood = sGood2(:,1);
[SIL,sil,c] = SILCal(sGood, fs);
size(c)
STgood = source2Spike(sGood);

ss = sGood.^2;
sGood= ss;

plotSources(sGood,'SIL',SIL);
hold on
id = find(STgood==1);
idlow = find(STgood==0);


[pks,loc] = findpeaks(sGood);
%pks = pks.^(1/2);

m = mean(sGood);

mp1 = mean(sGood(id));
c1centroid = max(c);
c2centroid = min(c);

mf = mean(sGood(idlow));
%mf = mean(pks);
stdp = std(sGood(id));
stdf = std(sGood(idlow));
%stdf = std(pks);
fs = 2000;
span = length(sGood)/fs;
plot(loc/2000,sGood(loc), 'y*')
plot(id/2000,sGood(id),'ro');

plot([0,span],[1,1]*c1centroid,'g-','LineWidth',2);
plot([0,span],[1,1]*c2centroid,'k-','LineWidth',2);
%plot([0,span],[1,1]*mf,'m-','LineWidth',2);
%plot([0,span],[1,1]*mp1,'b-','LineWidth',2);

plot([0,span],[1,1]*mf+stdf,'m--','LineWidth',2);
plot([0,span],[1,1]*mp1+stdp,'b--','LineWidth',2);
plot([0,span],[1,1]*mp1-stdp,'b--','LineWidth',2);
legend({"Source squared", "Peaks", "Spikes", "Centroid (Class 1)", "Centroid (Class 2)", "Mean", "Mean+std", "Mean-std"});
disp((mp1/stdp)/(mf/stdf))

%%
M=M3;
[ST1,~,~,id1] = findGoodSourceID(M{2});
wholeSet = 1:length(M{1});
if(length(id1)<3)
    leftSet = setdiff(wholeSet, id1);
    [ST2,SIL2,~,id2] = findGoodSourceID(M{2}(:,leftSet),1);
    [~,id3] = maxk(SIL2,3);
end
finalId = [id1,leftSet(id2(id3))]

%%
s = sGood2(:,3);
ss = s.^2;
m = mean(ss);
for i = 1:30

    [~,loc] = findpeaks(ss,'MinPeakHeight',m+std(ss)*i/3);
    ST = zeros(size(ss));
    ST(loc) = 1;
    sil = silhouette(ss,ST);
    if(mod(i,3)==1)
    figure
    plot(ss);
    hold on;
    title(sprintf("SIL: c1 : %f| c2 : %f \n",mean(sil(ST==1)),mean(sil(ST==0))),'FontSize',20);
    plot(loc,ss(loc),'ro')
    end
    SIL(i) = mean(sil(ST==1));
end

%%  collect summation of tracked MUs

slist = [5, 7,8,10,11,12,13];  % # of subjects
conditions = {"oo","of","ff"};  % 3 conditions
for s = 1:length(slist)
    path = sprintf("D:\\experimentdata\\PD-DBS\\sub%d\\trace",slist(s));
    for cond = [1,2,3]
        file = strcat(path, sprintf("\\%s\\matlab.mat", conditions{cond}))
        load(file);
        collection{s}{cond}{1}{1} = zeros(size(totalCount1{1}));
        collection{s}{cond}{1}{2} = zeros(size(totalCount1{1}));
        for m = 1:4
            grp = floor((m+1)/2);
            collection{s}{cond}{1}{grp} = collection{s}{cond}{1}{grp} + totalCount1{m};
        end
        if(cond == 2)
            collection{s}{cond}{2}{1} = zeros(size(totalCount2{1}));
            collection{s}{cond}{2}{2} = zeros(size(totalCount2{1}));
            for m = 1:4
                grp = floor((m+1)/2);
                collection{s}{cond}{2}{grp} = collection{s}{cond}{2}{grp} + totalCount2{m};
            end
        end
    end
end

%% gether spike train data according to summation
slist = [7,8,[10:13]];
if(isempty(who("collection")))
    error("collection is not defined\n");
end
condition  = {"oo", "of","of","ff"};   %% each for "On By On", "On By Off", "Off By On", "Off By Off"
total =cell(0);
for si = 1:length(slist)
    s = slist(si)
    path = sprintf("D:\\experimentdata\\PD-DBS\\sub%d\\trace",s);
    for ci = 1:length(condition)
        cond = condition{ci}
        cd(strcat(path, sprintf("\\%s\\", cond)));
        if ci ==1
            curClct = collection{si}{ci}{1};
        elseif ci == 4
            curClct = collection{si}{3}{1};
        else
            curClct = collection{si}{2}{ci-1};
        end
        for g = 1:2   
            curClctGrp = curClct{g};
            [row, col] = size(curClctGrp);
            prefix = {'On','Off'};
            prefixid = {[1,1],[1,2],[2,1],[2,2]};
            set = [1:row];
            for ori = set
                total{si}{ci}{ori}{g} = [];
                ST = [];
                if (ci == 1 || ci == 4)
                    others = setdiff(set, ori);
                    % others = [ori];   % used when gathering original
                    % spike trains
                    
                else
                    others = 1:col;
                end
                for v = 1:length(others)
                    if(curClctGrp(ori, others(v))~=0)
                        for m = [g*2-1, g*2]
                            other_name = sprintf("M%d%s%dByM%d%s%d.mat",m, prefix{prefixid{ci}(1)}, ori, m, prefix{prefixid{ci}(2)}, others(v));  % to fit the format of filename e.g. M1On3ByM1Off4.mat
                            if(~isempty(dir(other_name))) 
                                %fprintf("%d %d : %s found\n",v, g, other_name)
                                load(other_name)
                                if ci ~=3
                                    eval(sprintf("newST = STgood%d;", 1));
                                else
                                    eval(sprintf("newST = STgood%d;", 2));
                                end
                                ST = [ST, newST];
                            else
                                continue;
                            end
                        end
                    end
                end
                size(ST,2)
                total{si}{ci}{ori}{g} = ST;
            end
        end
    end
end

%%  Coherence
slist = [7,8,10,11,12,13];
clist=[	'#0072BD',	'#D95319',	'#EDB120',	'#7E2F8E',	'#77AC30',	'#4DBEEE',	'#A2142F'];
c1  = 1; % 1 oo, 2 of, 3 fo, 4 ff
if (c1 == 1)
    c2 = 2;
elseif (c1 == 4)
    c2 = 3;
end

g =1;
        
for s = 1:6
    trials = size(original{s}{c1}, 2);
    figure;
    for trial = 1:trials
        ST1 = original{s}{c1}{trial}{g};
        ST2 = others{s}{c2}{trial}{g};
        N1 = size(ST1,2);
        N2 = size(ST2,2);
        hold on 
        if(N1>=3)
            subplot(311);
            calCoherLong(ST1);
            title("Inherent MU")
        end
        if(N2>=3)
            subplot(312)
            calCoherLong(ST2);
            title("Tracked MU")
        end
        if(N1>=3 && N2>=3)
            subplot(313)
            calCoherLong(ST1, ST2);
            title("Cross coherence")
        end
        sgtitle(sprintf("Coherence (DBS-on, Subject%d)",slist(s)), 'FontSize', 18)
    end
end
            
%% calculate 2D-xcorrelation between two ST groups
    corre = [];
    MP1 = muap2;
    MP2 = muap4;
    if(length(MP1)>length(MP2))
        MP1 = muap2;
        MP2 = muap1;
    end
    for i = 1:length(MP1)
        for j = i:length(MP2)
            x = xcorr2D(MP1{i},MP2{j});
            corre = [corre, x];
        end
    end
    plot(corre,'LineWidth',2)
    ylabel("2D-correlation", "FontSize",20);
    set(gca,'FontSize',20)
    
 %% to count the # of sources in each trial
 data = others;
 for i = 2:length(data)
     fprintf("subject %d\n", i);
     sub = data{i};
     for j = 1:length(sub)
         condData = sub{j};
         fprintf("\tcond %d\n", j);
         if(~isempty(condData))
             g1= [];
             g2= [];
             for trial = 1:length(condData)
                 fprintf("%d ", size(condData{trial}{1},2));
             end
             fprintf("\n");
             for trial = 1:length(condData)
                 fprintf("%d ", size(condData{trial}{2}, 2));
             end
             fprintf("\n");
         end
     end
 end
 
%% save filtered spike train
tic
threshold = 0.75;
sub = "sub5";
filepath=sprintf("D:\\experimentdata\\PD-DBS\\%s\\trace", sub);
cd(filepath)
file = dir(sprintf("%s*Off*.mat", sub));

for t = 1:length(file)
    load(file(t).name);

    for m = 1:4
        valName = sprintf("M%dspikeTrain", m);
        eval(sprintf("%s = M%d{3}(:,(M%d{1}>=threshold));",valName,m,m));
    end
    save(sprintf("Off%dSpikeTrain.mat", t),'-regexp','M[1-4]spikeTrain');
end

%% 
subList=[5,7,8,10,11,12,13];
s = 1;
cl = collection{s}{2}{1}{1} + collection{s}{2}{1}{2};
cd(sprintf("D:\\experimentdata\\PD-DBS\\sub%d\\trace\\of", subList(s)));

[row, col] = find(cl>=3);
for i = 1:length(row)
    ot = row(i);
    ft = col(i);
    offId=[];
    OnSpikeTrains=[];
    OffSpikeTrains=[];
    OffFileName = sprintf("Off%dSpikeTrain.mat",ft);
    load(strcat("..\\", OffFileName));
    for m = 1:4
        OnModuleName = sprintf("M%dOn%dByM%dOff%d.mat", m, ot, m, ft)
        fileObj = dir(OnModuleName);
        if(~isempty(fileObj))
            load(OnModuleName);
            OnSpikeTrains = [OnSpikeTrains, STgood1];
            eval(sprintf("OffSpikeTrains = [OffSpikeTrains, M%dspikeTrain(:,id1)];",m));
        end
    end
    figure
    subplot(211)
    calCoherLong(OnSpikeTrains);
    title(sprintf("DBS-ON (trial %d)", ot));
    subplot(212)
    calCoherLong(OffSpikeTrains);
    title(sprintf("DBS-OFF (trial %d)", ft))
end
        
    
