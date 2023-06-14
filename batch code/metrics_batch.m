%% part trial
rawData = rawData_cut;
l=length(rawData);
[m,n] = size(rawData);
if(m<n)
    rawData= rawData';
end
variable = {['M1'],['M2'],['M3'],['M4'],['rawData']};
PartN = 1;  % how many parts the data is to be divided into
t = 1:floor(length(rawData)/PartN)-1:length(rawData);
fileName = "Sub4PostOffRestingSession1Trial2Segment4Sifted";

var2save=""; 
for i = variable
    eval(sprintf("%s_dup = %s;", i{1}, i{1}));
    var2save = var2save + sprintf(",'%s'",i{1});
end
for s = 1:PartN
    for i = 1:4
        if(eval(sprintf("length(%s_dup)>=5 && ~isempty(%s_dup{5})",variable{i},variable{i})))
            cmd = sprintf("%s = %s_dup{5}(%d:%d,:);",variable{i}, variable{i}, t(s), t(s+1));
        else
            cmd = sprintf("%s = [];",variable{i});
        end
        cmd
        eval(cmd);
    end
    j = 5;
    eval(sprintf("%s = %s_dup(%d:%d,:);",variable{j}, variable{j}, t(s), t(s+1)));
    eval(sprintf("save('%s'%s);",strcat(fileName,"part",num2str(s)),var2save));
end

%%
MUSPGroup{1}={M1{5},M2{5},M3{5},M4{5}};

%% pick MU Spike Trains

for i =1:4
    if(~eval(sprintf("isempty(M%d{1})",i)))
        eval(sprintf("M%d{5} = M%d{3}(:,M%d{4});",i,i,i));
    else
        eval(sprintf("M%d{5}=[];",i));
    end
end
MUSPGroup{1}={M1{5},M2{5},M3{5},M4{5}};

%% save files

save("D:\experimentdata\PD-DBS\sub13\post\mu\Sub13PostResting2Trial2part1trimmed.mat","M1","M2","M3","M4","rawData","nullCell");

%% switch directory
filePath = "D:\experimentdata\PD-DBS\sub4\trimmed\post\on";
eval(strcat("cd ",filePath))
f = dir(strcat(filePath,"\S*"));
filenames = {f.name};
for i = 1:size(filenames,2)
    fprintf("%d: %s \n",i, filenames{i});
end

%%  calculate metrices
fileid=[1:6];
pre=[];
for i = fileid
    pre=[pre; calculateMetrics(filenames{i})];
end
pre = cell2table(pre);
metrics = pre{:,1:13};
close all

%% plot individual point
Sl = [3]
itx = 9;
ity = 1;
m = "b*";
hold on
for S = Sl
    eval(strcat("Metrics = sub",num2str(S),"PostOffRestingMetrics;")); 
    eval(sprintf("x = Metrics(:,%d);", itx));
    eval(sprintf("y = log10(Metrics(:,%d));", ity));
    plot(x,y,m,'MarkerSize',10);

    xbar = mean(x);
    ybar = mean(y);
    plot(xbar, ybar, m, 'MarkerSize',20)
end

%% plot metrics
fileSuffix=["PreRestingMetrics", "PostOnRestingMetrics", "PostOffRestingMetrics"];
Sl = [3,4,6,7,10,11,12,13],li=[1],c = "b";
Sl = [3,4,7,8,11,12,13],li=[2],c = "g";
Sl = [3,4,8,11,12,13], li = [3],c = "r";
markersColor=[c, c, c];
markers=["s","o","^"];
itx = 1;
ity = 23;
hold on
mx=[];
my=[];
for S = Sl
    verticesX = [];
    verticesY = [];
%    for i = 2:length(fileSuffix)-1
    for i = li
        eval(strcat("Metrics = sub",num2str(S),fileSuffix(i),";")); 
        eval(sprintf("x = log10(Metrics(:,%d));", itx));
        eval(sprintf("y = Metrics(:,%d);", ity));
        %plot(x,y,'MarkerSize',10, 'Marker',markers(i),'MarkerEdgeColor', markersColor(i), 'LineStyle', 'none');
        xbar = mean(x);
        ybar = mean(y);
        verticesX=[xbar, verticesX];
        mx=[xbar, mx];
        verticesY=[ybar, verticesY];
        my=[ybar, my];
        plot(xbar, ybar,'MarkerSize',15, 'MarkerFaceColor', markersColor(i), 'Marker',markers(i), 'MarkerEdgeColor', markersColor(i))
    end
    plot(verticesX, verticesY, 'LineWidth', 2);
end
%legend({"Pre-operation", "Post-operation-On", "Post-operation-Off"})
ylabel("Coherence")
xlabel("Tremor Power")
title("Coherence v.s. Tremor Power")
set(gca, "FontSize",20);
%hold off

data = [mx', my']

% Calculate the eigenvectors and eigenvalues
covariance = cov(data);
[eigenvec, eigenval ] = eig(covariance);

% Get the index of the largest eigenvector
[largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

% Get the largest eigenvalue
largest_eigenval = max(max(eigenval));

% Get the smallest eigenvector and eigenvalue
if(largest_eigenvec_ind_c == 1)
    smallest_eigenval = max(eigenval(:,2))
    smallest_eigenvec = eigenvec(:,2);
else
    smallest_eigenval = max(eigenval(:,1))
    smallest_eigenvec = eigenvec(1,:);
end

% Calculate the angle between the x-axis and the largest eigenvector
angle = atan2(largest_eigenvec(2), largest_eigenvec(1));

% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(angle < 0)
    angle = angle + 2*pi;
end

% Get the coordinates of the data mean
avg = mean(data);

% Get the 95% confidence interval error ellipse
chisquare_val = 2.4477;
theta_grid = linspace(0,2*pi);
phi = angle;
X0=avg(1);
Y0=avg(2);
a=chisquare_val*sqrt(largest_eigenval);
b=chisquare_val*sqrt(smallest_eigenval);

% the ellipse in x and y coordinates 
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );

%Define a rotation matrix
R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];

%let's rotate the ellipse to some angle phi
r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;

% Draw the error ellipse
plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-','Color',markersColor(1))
hold on;

% Plot the original data
plot(data(:,1), data(:,2), '.');
mindata = min(min(data));
maxdata = max(max(data));
xlim([mindata-3, maxdata+3]);
ylim([mindata-3, maxdata+3]);
hold on;

% Plot the eigenvectors
%quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
%quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
%hold on;

% Set the axis labels
%hXLabel = xlabel('x');
%hYLabel = ylabel('y')

%%  collect MU in mat files
filepath = 'D:\\experimentdata\\PD-DBS\\sub7\\post\\off\\mu';
cd(filepath)
files = dir(strcat(filepath, "\\spikeSub7*"))
N = length(files);
mu = cell(N, 2);
imu = cell(N,1);
for s = 1 : N
    s
%     load(files(s).name,'rawData');
    load(files(s).name);

    flx = []; ext = []; for m = 1:4
        eval(sprintf("M = M%d;", m)); if(m<3)
            flx = [flx, M];
        else
            ext = [ext, M];
        end
    end
    mu{s,1} = flx; 
    mu{s,2} = ext;
    figure; 
    if(size(flx,2)>=3)
        subplot(311)
        calCoherLong(flx);
    end
    if(size(ext,2)>=3)
        subplot(312)
        calCoherLong(ext);
    end
    if(size(flx,2)>=3 && size(ext,2)>=3)
        subplot(313)
        calCoherLong(flx, ext);
    end
% [r,c] = size(rawData);
% if(r<c)
%     rawData = rawData';
% end
% imu{s} = rawData(:,257:262);
%clear rawData
end
%%  calculate coherence for MU groups
g=2;
inter =0;
c=[];
figure
subplot(211)
s = 11
eval(sprintf("preMu = preMu%d;",s));
eval(sprintf("postMu = postOnMu%d;",s));

for i = 1:size(preMu,1)
    if(inter==0)
        if(size(preMu{i,g},2)>=3)
            [ctemp,f,~] = calCoherLong(preMu{i,g});
            c=[c,ctemp];
        end
    else
        if(size(preMu{i,1},2)>=3 && size(preMu{i,2},2)>=3)
            [ctemp,f,~] = calCoherLong(preMu{i,1}, preMu{i,2});
            c=[c,ctemp];
        end
    end
end
color = '#D95319';
cstd1 = std(c,0,2);
plot(f,mean(c,2),'LineWidth',5,'Color',color);
plot(f,mean(c,2)+cstd1,'LineWidth',3, 'LineStyle','-.','Color',color);
plot(f,mean(c,2)-cstd1,'LineWidth',3, 'LineStyle','-.','Color',color);

subplot(212)
c2=[];
for i = 1:size(postMu,1)
    if(inter==0)
        if(size(postMu{i,g},2)>=3)
         [ctemp,~,~] = calCoherLong(postMu{i,g});
         c2=[c2,ctemp];
        end
    else
        if(size(postMu{i,1},2)>=3 && size(postMu{i,2},2)>=3)
            [ctemp,~,~] = calCoherLong(postMu{i,1}, postMu{i,2});
            c2=[c2,ctemp];
        end
    end
end
color = 	'#77AC30';
cstd2 = std(c2,0,2);
plot(f,mean(c2,2),'LineWidth',5,'Color',color);
plot(f,mean(c2,2)+cstd2,'LineWidth',3, 'LineStyle','-.','Color',color);
plot(f,mean(c2,2)-cstd2,'LineWidth',3, 'LineStyle','-.','Color',color);
sgtitle(sprintf("Intra-muscular Coherence, S%d",s));
%%  find peaks at tremor and double tremor frequency
% c1 pre, c2 post
tremorFreqCoher=[];  % for tremor freq
doubleTremorFreqCoher=[];  % for double tremor freq
cAll = c;
for i = 1:size(cAll,2)
    c = cAll(:,i);
    fs = 2000;
    freq = [3, 6];  %   frequency for tremor band
    windowWidth = 2;    % frequency width for accumulating coherence
    pointPerFreq = (length(c)/(fs/2));
    freqId = floor(freq*pointPerFreq);
    startId = freqId(1);
    [p1, loc1] = findpeaks(c(startId:freqId(2)));
    [~,id] = maxk(p1,1);
    WinLeftId1 =loc1(id)+startId-1-round(windowWidth/2*pointPerFreq);
    WinRightId1 =loc1(id)+startId-1+round(windowWidth/2*pointPerFreq);

    WinLeftId2 =WinLeftId1+WinRightId1-round(windowWidth/2*pointPerFreq);
    WinRightId2 =WinLeftId1+WinRightId1+round(windowWidth/2*pointPerFreq);
    s1 = sum(c(WinLeftId1:WinRightId1));
    s2 = sum(c(WinLeftId2:WinRightId2));
    tremorFreqCoher=[tremorFreqCoher,s1];
    doubleTremorFreqCoher=[doubleTremorFreqCoher,s2];
    hold on
    plot(f,c)
    plot([WinLeftId1,WinRightId1]/pointPerFreq,[0.1,0.1],'o')
    plot([WinLeftId2,WinRightId2]/pointPerFreq,[0.1,0.1],'o')
    axis([0,20,0,1])
end

%% 统计coherence峰值（单倍、双倍震颤频率）处的峰值

subjects = [11,12,13];
muscleCoherType = ["Intra-muscular","Intra-muscular","Inter-muscular"];
muscle = [" Flexor,"," Extensor,",""];
phases = ["before", "after, DBS-on"];

coherValues = cell(1,length(subjects));

tiledlayout('flow');
for subi = 1:length(subjects)
    s = subjects(subi)
    eval(sprintf("preMu = preMu%d;",s));
    eval(sprintf("postMu = postOnMu%d;",s));
    Mu{1} = preMu;
    Mu{2} = postMu;
    
    for cond = 1 : 3  % flx, ext, and cross
        switch(cond)
            case 1
                g=1;
                inter = 0;
            case 2
                g=2;
                inter = 0;
            case 3
                inter = 1;
        end
    % c1 for pre-opearation, c2 for post-operation dbs-on
        tremorFreqCoher=cell(1, 2);
        doubleTremorFreqCoher=cell(1, 2);
        figure
        for phase = 1:2 % 1 for before,2 for after

            c=[];
            nexttile;
            curMu = Mu{phase};

            for i = 1:size(curMu,1)
                if(inter==0)
                    if(size(curMu{i,g},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,g});
                        c=[c,ctemp];
                    end
                else
                    if(size(curMu{i,1},2)>=3 && size(curMu{i,2},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,1}, curMu{i,2});
                        c=[c,ctemp];
                    end
                end
            end
            title(sprintf("Coherence Curve (%s)", phases(phase)),'FontSize',22);
            xlabel("Frequency (Hz)");
            set(gca,'FontSize',22);

            color = '#D95319';
            cstd1 = std(c,0,2);
            plot(f,mean(c,2),'LineWidth',5,'Color',color);
            plot(f,mean(c,2)+cstd1,'LineWidth',3, 'LineStyle','-.','Color',color);
            plot(f,mean(c,2)-cstd1,'LineWidth',3, 'LineStyle','-.','Color',color);

            % c1 pre, c2 post
            tremorFreqCoher{phase}=[];  % for tremor freq
            doubleTremorFreqCoher{phase}=[];  % for double tremor freq
            cAll = c;
            color = make_colors(size(cAll,2));
            for i = 1:size(cAll,2)
                cur_color = color{i};
                c = cAll(:,i);
                fs = 2000;
                freq = [3, 6];  %   frequency for tremor band
                windowWidth = 1;    % frequency width for accumulating coherence
                pointPerFreq = (length(c)/(fs/2));
                freqId = round(freq*pointPerFreq);
                startId = freqId(1);
                [p1, loc1] = findpeaks(c(startId:freqId(2)));
                [s1,id1] = maxk(p1,1);    % get the maximum peak 
                peakId = loc1(id1) + startId - 2;
                
                peak2Id = 2*peakId-1;
                [p2, loc2] = findpeaks(c(round(peak2Id-pointPerFreq): round(peak2Id+pointPerFreq)));
                [s2, id2] = maxk(p2,1);
                peak2Id = loc2(id2) + peak2Id-pointPerFreq - 1;
%                 
%                 WinLeftId1 = peakId - round(windowWidth/2*pointPerFreq);
%                 WinRightId1 = peakId + round(windowWidth/2*pointPerFreq);
% 
%                 WinLeftId2 =WinLeftId1+WinRightId1-round(windowWidth/2*pointPerFreq);
%                 WinRightId2 =WinLeftId1+WinRightId1+round(windowWidth/2*pointPerFreq);
%                 
%                 freqN = round(windowWidth * pointPerFreq);
%                 s1 = sum(c(WinLeftId1:WinRightId1)) /freqN ;
%                 s2 = sum(c(WinLeftId2:WinRightId2)) /freqN;
                tremorFreqCoher{phase}=[tremorFreqCoher{phase},s1];
                doubleTremorFreqCoher{phase}=[doubleTremorFreqCoher{phase},s2];
                hold on
                plot(f,c)
                plot((peakId)/pointPerFreq,p1(id1),'Marker','o','MarkerFaceColor',cur_color,'MarkerSize',10);
%                 plot([WinLeftId1,WinLeftId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
%                 plot([WinRightId1,WinRightId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
                
%                 plot([WinLeftId2,WinLeftId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
%                 plot([WinRightId2,WinRightId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
                
                axis([0,20,0,1])

            end
            if(length(tremorFreqCoher{phase})>3)
                [p,h] = adtest(tremorFreqCoher{phase});
                fprintf("s %d, cond %d, test result:%d, p-value:%f | ",subjects(subi), cond, p, h);
            end
            if(length(doubleTremorFreqCoher{phase})>3)
                [p,h] = adtest(doubleTremorFreqCoher{phase});
                fprintf("s %d, cond %d, double test result:%d, p-value:%f\n",subjects(subi), cond, p, h);
            end

        end
        sgtitle(sprintf("%s Coherence,%s S%d",muscleCoherType(cond),muscle(cond), s), 'FontSize',24);

        %figure
        %sb3 = subplot(2,2,3);
        nexttile;
        g1 = repmat(phases(1),size(tremorFreqCoher{1}));
        g2 = repmat(phases(2),size(tremorFreqCoher{2}));
        boxplot([tremorFreqCoher{1},tremorFreqCoher{2}]',[g1,g2]');
        set(gca,'FontSize',20);
        title("Mean Coherence (tremor frequency)",'FontSize',22);
        [p1,h1] = ranksum(tremorFreqCoher{1}, tremorFreqCoher{2},'tail','right');
        [p2,h2] = ranksum(doubleTremorFreqCoher{1}, doubleTremorFreqCoher{2},'tail','right');
        fprintf("%f, %d | %f, %d\n",p1,h1, p2, h2)


        %sb4 = subplot(2,2,4);
        nexttile;
        g1 = repmat(phases(1),size(doubleTremorFreqCoher{1}));
        g2 = repmat(phases(2),size(doubleTremorFreqCoher{2}));
        boxplot([doubleTremorFreqCoher{1},doubleTremorFreqCoher{2}]',[g1,g2]');
        set(gca,'FontSize',22);
        title("Mean Coherence (double tremor frequency)",'FontSize',22);
        
        coherValues{subi}{cond}{1} = tremorFreqCoher;
        coherValues{subi}{cond}{2} = doubleTremorFreqCoher;
    end
    
end

%% edited version to calculate mean coherence in tremor and double tremor frequency (similar to the previous code segment, but mean coherence) 

subjects = [11,12,13];
muscleCoherType = ["Intra-muscular","Intra-muscular","Inter-muscular"];
muscle = [" Flexor,"," Extensor,",""];
phases = ["before", "after, DBS-on"];

coherValues = cell(1,length(subjects));


for subi = 1:length(subjects)
    s = subjects(subi)
    eval(sprintf("preMu = preMu%d;",s));
    eval(sprintf("postMu = postOnMu%d;",s));
    Mu{1} = preMu;
    Mu{2} = postMu;
    
    for cond = 1 : 3  % flx, ext, and cross
        figure
        tiledlayout('flow');
        switch(cond)
            case 1
                g=1;
                inter = 0;
            case 2
                g=2;
                inter = 0;
            case 3
                inter = 1;
        end
    % c1 for pre-opearation, c2 for post-operation dbs-on
        tremorFreqCoher=cell(1, 2);
        doubleTremorFreqCoher=cell(1, 2);
        for phase = 1:2 % 1 for before,2 for after

            c=[];
            %sb(phase)= subplot(2,2,phase);
            nexttile;
            curMu = Mu{phase};

            for i = 1:size(curMu,1) % trial
                if(inter==0)
                    if(size(curMu{i,g},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,g});
                        c=[c,ctemp];
                    end
                else
                    if(size(curMu{i,1},2)>=3 && size(curMu{i,2},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,1}, curMu{i,2});
                        c=[c,ctemp];
                    end
                end
            end
            title(sprintf("Coherence Curve (%s)", phases(phase)),'FontSize',22);
            xlabel("Frequency (Hz)");
            set(gca,'FontSize',22);

            % c1 pre, c2 post
            tremorFreqCoher{phase}=[];  % for tremor freq
            doubleTremorFreqCoher{phase}=[];  % for double tremor freq
            cAll = c;
            color = make_colors(size(cAll,2));
            peaksId=zeros(1,size(cAll,2));
            peaksId2=zeros(1,size(cAll,2));
            
            fs = 2000;
            freq = [3, 6];  %   frequency for tremor band
            windowWidth = 1;    % frequency width for accumulating coherence
            
            for i = 1:size(cAll,2)
                cur_color = color{i};
                c = cAll(:,i);

                pointPerFreq = (length(c)/(fs/2));
                freqId = round(freq*pointPerFreq);
                startId = freqId(1);
                [p1, loc1] = findpeaks(c(startId:freqId(2)));
                [~,id1] = maxk(p1,1);    % get the maximum peak 
                peakId = loc1(id1) + startId - 2;
                peaksId(i) = peakId;
                
                peakId2 = 2*peakId-1;
                [p2, loc2] = findpeaks(c(round(peakId2-pointPerFreq): round(peakId2+pointPerFreq)));
                [~, id2] = maxk(p2,1);
                peakId2 = loc2(id2) + round(peakId2-pointPerFreq) - 2;
                peaksId2(i) = peakId2;
            end
            
            disp(peaksId)
            disp(peaksId2)
            
            
            mfId = round(mean(peaksId));
            mf2Id = round(mean(peaksId2));
            
            for i = 1:size(cAll,2)
                c = cAll(:,i);
                
                WinLeftId1 = mfId - round(windowWidth/2*pointPerFreq);
                WinRightId1 = mfId + round(windowWidth/2*pointPerFreq);

                WinLeftId2 = mf2Id - round(windowWidth/2*pointPerFreq);
                WinRightId2 = mf2Id + round(windowWidth/2*pointPerFreq);
                
                freqN = round(windowWidth * pointPerFreq);
                s1 = sum(c(WinLeftId1:WinRightId1)) /freqN ;
                s2 = sum(c(WinLeftId2:WinRightId2)) /freqN;
                tremorFreqCoher{phase}=[tremorFreqCoher{phase},s1];
                doubleTremorFreqCoher{phase}=[doubleTremorFreqCoher{phase},s2];
                hold on
                plot(f,c)
                plot(ones(2,1)*(mfId)/pointPerFreq,[0,1],'--','Color',cur_color,'LineWidth',1.5);
%                 plot([WinLeftId1,WinLeftId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
%                 plot([WinRightId1,WinRightId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)

                plot(ones(2,1)*(mf2Id)/pointPerFreq,[0,1],'--','Color',cur_color,'LineWidth',1.5);
%                 plot([WinLeftId2,WinLeftId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
%                 plot([WinRightId2,WinRightId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5
                
                axis([0,20,0,1])

            end
%             if(length(tremorFreqCoher{phase})>3)
%                 [p,h] = adtest(tremorFreqCoher{phase});
%                 fprintf("s %d, cond %d, test result:%d, p-value:%f | ",subjects(subi), cond, p, h);
%             end
%             if(length(doubleTremorFreqCoher{phase})>3)
%                 [p,h] = adtest(doubleTremorFreqCoher{phase});
%                 fprintf("s %d, cond %d, double test result:%d, p-value:%f\n",subjects(subi), cond, p, h);
%             end

        end
        sgtitle(sprintf("%s Coherence,%s S%d",muscleCoherType(cond),muscle(cond), s), 'FontSize',24);

%         nexttile;
%         g1 = repmat(phases(1),size(tremorFreqCoher{1}));
%         g2 = repmat(phases(2),size(tremorFreqCoher{2}));
%         boxplot([tremorFreqCoher{1},tremorFreqCoher{2}]',[g1,g2]');
%         set(gca,'FontSize',20);
%         title("Mean Coherence (tremor frequency)",'FontSize',22);
%         [p1,h1] = ranksum(tremorFreqCoher{1}, tremorFreqCoher{2},'tail','right');
%         [p2,h2] = ranksum(doubleTremorFreqCoher{1}, doubleTremorFreqCoher{2},'tail','right');
%         fprintf("%f, %d | %f, %d\n",p1,h1, p2, h2)

% 
%         nexttile;
%         g1 = repmat(phases(1),size(doubleTremorFreqCoher{1}));
%         g2 = repmat(phases(2),size(doubleTremorFreqCoher{2}));
%         boxplot([doubleTremorFreqCoher{1},doubleTremorFreqCoher{2}]',[g1,g2]');
%         set(gca,'FontSize',22);
%         title("Mean Coherence (double tremor frequency)",'FontSize',22);
%         
        coherValues{subi}{cond}{1} = tremorFreqCoher;
        coherValues{subi}{cond}{2} = doubleTremorFreqCoher;
    end
    
end

%% plot coherence in different phases
subjectid = [3,4,6:8,10:13];
subjects = mat2cell("S"+subjectid,1,ones(size(subjectid)));
tiledlayout('flow');
muscleCoherType = ["Intra-muscular","Intra-muscular","Inter-muscular"];
muscle = ["Flx, ","Ext, ",""];
phases = ["before", "after, DBS-on","after, DBS-off"];
Frequency = ["tremor", "double tremor"];

for cond = 1:3
    for freq = 1:2
        nexttile
        %subplot(3,2,(cond-1)*2+freq)
        for subi=1:length(subjects)
            for phase = 1:length(phases)
                CoherGrp{phase,subi} = coherValues{subi}{cond}{freq}{phase};
            end
%             [p,h] = ranksum(CoherGrp{1,subi}, CoherGrp{2,subi}, 'tail', 'right');
%             fprintf("%s condition%d freq%d h:%d p-value:%f\n", subjects{subi}, cond, freq, h, p);
        end
%          multiple_boxplot(CoherGrp',subjects)
       multiple_boxplot(CoherGrp,phases)

              
        if(cond == 1)
            m = 1;
        elseif(cond == 2)
            m = 2;
        else
            m = 3;
        end

        title(sprintf("%s (%s%s)",muscleCoherType(cond), muscle(m), Frequency(freq)));
        set(gca,'FontSize',20)
    end
end
% legend(fliplr(phases))
legend(fliplr(subjects))

sgtitle("Peak Coherence","FontSize",22)

%%  plot tremor intensity
subjects = [11,12,13];
sNames = ["S1","S2","S3"];
phases = ["Pre","PostOn"];
tremorPower = cell(length(subjects),2);
DR = cell(size(tremorPower));
for s = 1:length(subjects)
    for phase = 1:length(phases)
        file = sprintf("sub%d%sRestingMetrics",subjects(s),phases(phase));
        eval(sprintf("tremorPower{%d,%d} = 20*log10(%s(:,1));", s, phase, file));
        eval(sprintf("DR{%d, %d} = %s(:,29);", s, phase, file));

    end
    [p,h] = ranksum(tremorPower{s,1},tremorPower{s,2}, 'tail', 'right');
    fprintf("%s H: %d, P: %f\n",sNames(s), h, p);
end

c=make_colors(10);
colors = [c{11};c{10}];
colors = [colors, ones(2,1)*0.5];
multiple_boxplot(tremorPower,sNames, phases, colors)
ylabel("tremor intensity (dB)")
set(gca,"FontSize",24)

figure
multiple_boxplot(DR,sNames, phases, colors)
ylabel("Mean Discharge Rate")
set(gca,"FontSize",24)

%%  plot IDR
subjects = [11,12,13];
sNames = ["S1","S2","S3"];
phases = ["Pre","PostOn"];
tiledlayout('flow');
hold on;
for s = 1:length(subjects)
    nexttile;
    eval(sprintf("isiPre = reshape(preMu%d,1,[]);", subjects(s)));
    eval(sprintf("isiPost = reshape(postOnMu%d,1,[]);", subjects(s)));
    plotIDR(isiPre,'mode',2,'color','g');
    plotIDR(isiPost,'mode',2,'color','b');
    axis([0,35,-inf,inf]);
    title(sprintf("S%d",subjects(s)));
    xlabel("Instantaneous MU Discharge Rate (pps)")
    set(gca,'FontSize',22);
    
end
legend(phases,'Location','bestoutside');

hold off

%% extract spike train
filepath = "D:\experimentdata\PD-DBS\sub7\post\off\mu";
cd(filepath);
files = dir("D:\experimentdata\PD-DBS\sub7\post\off\mu\S*");
n = length(files);
for i = 1:n
    load(files(i).name);
    for m = 1:4
        eval(sprintf("M = M%d;",m));
        st=[];
        if(~isempty(M) && ~isempty(M{1}))
            [st] = findGoodSourceID(M{2});
        end
        eval(sprintf("M%d = st;",m));
    end
    save(strcat("spike",files(i).name),"M1","M2","M3","M4");
end
msgbox("ended")

%% edited version to calculate mean coherence in tremor and double tremor frequency (similar to the previous code segment, but mean coherence) 

subjects = [3,4,6:8,10:13];
muscleCoherType = ["Intra-muscular","Intra-muscular","Inter-muscular"];
muscle = [" Flexor,"," Extensor,",""];
phases = ["before", "after, DBS-on","after, DBS-off"];
phaseVar=["preMu","postOnMu","postOffMu"];

coherValues = cell(1,length(subjects));


for subi = 1:length(subjects)
    s = subjects(subi)
    
    for cond = 1 : 3  % flx, ext, and cross
        figure
        tiledlayout('flow');
        switch(cond)
            case 1
                g=1;
                inter = 0;
            case 2
                g=2;
                inter = 0;
            case 3
                inter = 1;
        end
        tremorFreqCoher=cell(1, 2);
        doubleTremorFreqCoher=cell(1, 2);
        for phase = 1:length(phases) % 1 before,2 after dbs-on, 3 after dbs-off
            curPhVar = phaseVar(phase);
            eval(sprintf("est = exist('%s%d');", curPhVar, s));
            if(est)
                eval(sprintf("Mu{%d} = %s%d;", phase,curPhVar, s));
            else
                Mu{phase} = cell(1,2);
            end
            
            c=[];
            nexttile;
            curMu = Mu{phase};

            for i = 1:size(curMu,1) % trial
                if(inter==0)
                    if(size(curMu{i,g},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,g});
                        c=[c,ctemp];
                    end
                else
                    if(size(curMu{i,1},2)>=3 && size(curMu{i,2},2)>=3)
                        [ctemp,f,~] = calCoherLong(curMu{i,1}, curMu{i,2});
                        c=[c,ctemp];
                    end
                end
            end
            title(sprintf("Coherence Curve (%s)", phases(phase)),'FontSize',22);
            xlabel("Frequency (Hz)");
            set(gca,'FontSize',22);

            tremorFreqCoher{phase}=[];  % for tremor freq
            doubleTremorFreqCoher{phase}=[];  % for double tremor freq
            cAll = c;
            color = make_colors(size(cAll,2));
            peaksId=zeros(1,size(cAll,2));
            peaksId2=zeros(1,size(cAll,2));
            
            fs = 2000;
            freq = [3, 6];  %   frequency for tremor band
            windowWidth = 0.1;    % frequency width for accumulating coherence
            
            for i = 1:size(cAll,2)  % locate the peak in frequency scale
                cur_color = color{i};
                c = cAll(:,i);

                pointPerFreq = (length(c)/(fs/2));
                freqId = round(freq*pointPerFreq);
                startId = freqId(1);
                [p1, loc1] = findpeaks(c(startId:freqId(2)));
                [~,id1] = maxk(p1,1);    % get the maximum peak 
                peakId = loc1(id1) + startId - 2;
                peaksId(i) = peakId;
                
                peakId2 = 2*peakId-1;
                [p2, loc2] = findpeaks(c(round(peakId2-pointPerFreq): round(peakId2+pointPerFreq)));
                [~, id2] = maxk(p2,1);
                peakId2 = loc2(id2) + round(peakId2-pointPerFreq) - 2;
                peaksId2(i) = peakId2;
            end
%             disp(peaksId)
%             disp(peaksId2)
            
            mfId = round(mean(peaksId));
            mf2Id = round(mean(peaksId2));
            
            for i = 1:size(cAll,2)  % calculate mean coherence in peaks
                c = cAll(:,i);
                
                WinLeftId1 = mfId - round(windowWidth/2*pointPerFreq);
                WinRightId1 = mfId + round(windowWidth/2*pointPerFreq);

                WinLeftId2 = mf2Id - round(windowWidth/2*pointPerFreq);
                WinRightId2 = mf2Id + round(windowWidth/2*pointPerFreq);
                
                freqN = round(windowWidth * pointPerFreq);
                s1 = sum(c(WinLeftId1:WinRightId1)) /freqN ;
                s2 = sum(c(WinLeftId2:WinRightId2)) /freqN;
                tremorFreqCoher{phase}=[tremorFreqCoher{phase},s1];
                doubleTremorFreqCoher{phase}=[doubleTremorFreqCoher{phase},s2];
%                 hold on
%                 plot(f,c)
%                 plot(ones(2,1)*(mfId)/pointPerFreq,[0,1],'--','Color',cur_color,'LineWidth',1.5);
% %                 plot([WinLeftId1,WinLeftId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
% %                 plot([WinRightId1,WinRightId1]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
% 
%                 plot(ones(2,1)*(mf2Id)/pointPerFreq,[0,1],'--','Color',cur_color,'LineWidth',1.5);
% %                 plot([WinLeftId2,WinLeftId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5)
% %                 plot([WinRightId2,WinRightId2]/pointPerFreq,[0,1],'Color',cur_color,'LineWidth',1.5
%                 
%                 axis([0,20,0,1])

            end
%             if(length(tremorFreqCoher{phase})>3)
%                 [p,h] = adtest(tremorFreqCoher{phase});
%                 fprintf("s %d, cond %d, test result:%d, p-value:%f | ",subjects(subi), cond, p, h);
%             end
%             if(length(doubleTremorFreqCoher{phase})>3)
%                 [p,h] = adtest(doubleTremorFreqCoher{phase});
%                 fprintf("s %d, cond %d, double test result:%d, p-value:%f\n",subjects(subi), cond, p, h);
%             end

        end
        %sgtitle(sprintf("%s Coherence,%s S%d",muscleCoherType(cond),muscle(cond), s), 'FontSize',24);

        coherValues{subi}{cond}{1} = tremorFreqCoher;
        coherValues{subi}{cond}{2} = doubleTremorFreqCoher;
    end
    
end
%%
subjects=[3,4,6:8,10:13];
datapath = "D:\experimentdata\PD-DBS\sub";
phasepath = ["pre", "post\on", "post\off"];

items = [ "subject_id", "phase_id", "trial_id", "tremor_intensity",... % 4
    "mu_flx", "mu_ext",... % 6
    "coher_single_flx", "coher_single_ext",... % 8
    "coher_single_inter", "coher_double_flx",... % 10
    "coher_double_ext", "coher_double_inter"]; % 12

trail_n = 0;
for s = 1:length(subjects)  %traverse to count trials
    for phase = 1:length(phasepath)
        curpath = sprintf("%s%d\\%s\\mu\\spiketrain", datapath, subjects(s), phasepath(phase));
        path = sprintf("%s\\*Session*",curpath);
        files = dir(path);
        if(~isempty(files))
            fprintf("%s : %d\n",path, length(files));
            for fi = 1:length(files)    % trial
                trial_n = trail_n+1;
            end
        end
    end
end


data = ones(trail_n, length(items))*(-1);

cur_trail = 1;
        
for s = 1:length(subjects)  %traverse to calculate indices
    for phase = 1:length(phasepath)
        curpath = sprintf("%s%d\\%s\\mu\\spiketrain", datapath, subjects(s), phasepath(phase));
        path = sprintf("%s\\*Session*",curpath);
        files = dir(path);
        if(~isempty(files))
            fprintf("\nsubject %d:\n",subjects(s));
            for fi = 1:length(files)    % trial
                fprintf("%d ", fi);
                load(sprintf("%s\\%s",curpath, files(fi).name));
                data(cur_trail, 1) = subjects(s);
                data(cur_trail, 2) = phase;
                data(cur_trail, 3) = fi;
                
                if(exist('rawData'))
                    col = size(rawData,2);
                    [id,tremor_intensity] = findMaxVar(rawData(:,end-5:end-3));
                    data(cur_trail, 4) = tremor_intensity(id);
                end
                    
                
                mu_flx = [M1, M2];
                mu_ext = [M3, M4];
                data(cur_trail, 5) = size(mu_flx,2);
                data(cur_trail, 6) = size(mu_ext,2);
                
                if(size(mu_flx,2) >= 3)
                    coher_flx = calCoherLong(mu_flx);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_flx);
                    data(cur_trail, 7) = c1;
                    data(cur_trail, 10) = c2;
                end
                if(size(mu_ext,2) >= 3)
                    coher_ext = calCoherLong(mu_ext);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_ext);
                    data(cur_trail, 8) = c1;
                    data(cur_trail, 11) = c2;
                end
                if(size(mu_flx,2) >= 3 && size(mu_ext,2) >= 3)
                    coher_inter = calCoherLong(mu_flx, mu_ext);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_inter);
                    data(cur_trail, 9) = c1;
                    data(cur_trail, 12) = c2;
                end
                
                cur_trail = cur_trail+1;
                clear rawData;
                
            end
        end
    end
end
fprintf("\n");
msgbox("over");
writematrix(items,'data_mean_w1.txt');
writematrix(data,'data_mean_w1.txt','WriteMode','append');
