function [FR] = calFirngRate(sp, avgN)
%calculate the Firing Rate along sp's column vectors
if nargin == 2
    windowSize = avgN;
else
    windowSize = 1;
end
fs = 2000;
dt = 1/fs;
[~,n] = size(sp);
FR=[];
t = 1:length(sp)-1;
t = t / fs;
%figure
cp=make_colors(n);
for i = 1:n
    firingID = find(sp(:,i)>0);
    interSpikeInterval = diff(firingID);
    fireTemp = zeros(size(sp(:,i)));
    fireRate = fs * interSpikeInterval.^(-1);
    if(isempty(fireRate))
        continue;
    end
    edgeL = floor(windowSize-1);
    fireRate = [ones(edgeL,1) * fireRate(1); fireRate;ones(edgeL,1)*fireRate(end)];
    b = (1/windowSize)*ones(1,windowSize);
    a=1;
    avgFR = filter(b,a,fireRate);
    fireTemp(firingID(1:end-1)) = avgFR(edgeL+1:end-edgeL);
    FR = [FR,fireTemp];
%     fireTemp(firingID(1:end-1)) = fireRate;
%     FR = [FR,fireTemp];
    x = t(firingID(1:end-1));
    y = fireTemp(firingID(1:end-1));
    if(nargout==0)
        %plot(x,y,'o','MarkerFaceColor',cp{i},'MarkerSize',8,'MarkerEdgeColor','none');
        s = scatter(x,y,50,cp{i},'filled','MarkerFaceAlpha',.7);

        t1 = find(y>0&y<100);
        x1 = x(t1);
        y1 = y(t1);
        hold on
        p = polyfit(x1,y1,5);
        y1 = polyval(p,x1);
        %plot(x1,y1,'Color',cp{i},'LineWidth',7);
    end
end
if(nargout==0)
    if n==1
        fr = FR(FR>0); 
        plot([0,100],[[1;1]*mean(fr(fr>0))],'LineWidth',1.5)
        plot([0,100],[[1;1]*(mean(fr(fr>0))+std(fr(fr>0))),[1;1]*(mean(fr(fr>0))-std(fr(fr>0)))],'g--')
    end
    %hold off
    xlabel('Time (s)');
    ylabel('Firing Rate (pps)')
    title(sprintf('MU Firing Rate (window length = %d)', windowSize));
    set(gca, 'FontSize', 18)
    axis([0,t(end),-inf,inf])
    for i = 1:n
        lgc{i} = strcat('MU',num2str(i));
        %lgc{i*2} = '';
    end
    legend(lgc);
end
end
