%% To plot Coherence between different Modules
moduleName = [
    "FC",
    "FDS",
    "ECR",
    "ED"
    ];
trial1 = 1;
trial2 = trial1;
cln = length(MUSPGroup{trial2});
rw = length(MUSPGroup{trial1});
i=0;
t = tiledlayout('flow');
t.TileSpacing='compact';
t.Padding = 'compact';
for id1 = 1:rw
    for id2 = 1:cln
        %nexttile();
        i=i+1;
        if(id1>id2)
            continue
        end
        subplot(cln,rw,i);
        musp1 = MUSPGroup{trial1}{id1};
        musp2 = MUSPGroup{trial2}{id2};
        %calCohe(musp1,musp2);
        if size(musp1,2)<3 || size(musp2,2)<3
            continue
        end
        if id1 ~= id2
            calCoherLong(musp1,musp2);
        else
            calCoherLong(musp1);
        end
        %colorbar
        title(sprintf('%s vs. %s',moduleName(id1), moduleName(id2)));
        set(gca,'FontSize',18);
        axis([0 20 0 1])
    end
end
s=sgtitle(strcat("Coherence among ",num2str(cln)," Muscles (Sub1, DBS-on, Posture ",num2str(trial1)," )"));
%s=sgtitle(sprintf('Coherene among %d Muscles (DBS-on , Resting %d) V2',rw,trial1));
s.FontSize=20;

%% find valid MU by SIL and length of blank interval
SILth = 0.8
fs=2000;
for i =1:4
    eval(sprintf('M = M%d;',i));
    eval(sprintf('M{4} = find(M{1}>=SILth);'));
    invalidL = [];
    thresh = 30/(1/fs); %for how long an idle period exists to expel such an MU (seconds)
    for j = 1:length(M{4})
        id = M{4}(j);
        tempSPT = M{3}(:,id);
        onID = find(tempSPT==1);
        diffonID = diff(onID);
        if(~isempty(find(diffonID>thresh)))||(onID(1)>thresh)||(length(tempSPT)-onID(end)>thresh)
            invalidL = [invalidL,j];
        end
    end
    M{4}(invalidL)=[];
    eval(sprintf('M{5} = M{3}(:,M{4});'));
    eval(sprintf('MUSPGroup{1}{%d} = M{5};',i))
    eval(sprintf('M%d = M;',i));
end

%% intra\inter\partial Coherence
i=1
mu = cell2mat(MUSPGroup{1});
Nflex = size(MUSPGroup{1}{1},2)+size(MUSPGroup{1}{2},2);
flex=mu(:,1:Nflex);
ext=[mu(:,Nflex+1:end)];
calCoherLong(flex,ext)
tiledlayout('flow')
ax(1)=nexttile,calCoherLong(flex)
title('Intra-Muscular Coherence(Flexor)')
ax(2)=nexttile,calCoherLong(ext)
title('Intra-Muscular Coherence(Extensor)')
ax(3)=nexttile,calCoherLong(flex,ext)
title('Inter-Muscular Coherence(Extensor vs. Flexor)')
 ax(4)=nexttile,calCoherLong(flex,flex,ext)
 title('Partial Coherence(Flexor)')
s=sgtitle('S1, After Operation (DBS-on), Resting');
s.FontSize=20;
linkaxes(ax,'y')
legend({"Coherence","Confidence level"})