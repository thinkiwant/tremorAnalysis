function MUSP_bars(musp, grpid)
% this function draws the MUSP in the form of series of bars. Each column
% correspinds to an MU while row is for length of signals.
cList={	'#0072BD',	'#D95319',		'#77AC30','#EDB120',	'#7E2F8E'};
N = size(musp,2);
if N ==0
    return
end
if nargin>1
    groupN = length(grpid);
    if sum(grpid)~=N
        error("unmatched group partition and the amount of musps\n");
    end
else
    groupN = 1;
    grpid =[N];
end

t=0:length(musp)-1;
t=t'/2000;


for i = 1:N
    id = find(musp(:,i));
    musp(id,i) = -(i*0.3+2);
end

idtemp = [0,cumsum(grpid)];
for gi = 1:groupN
    if grpid(gi) == 0
        continue;
    end
    p(gi) = stem(t,musp(:,idtemp(gi)+1),'|','LineStyle','none','MarkerSize',14,'LineWidth',1.5,'Color',cList{gi});hold on;
    stem(t,musp(:,idtemp(gi)+2:idtemp(gi+1)),'|','LineStyle','none','MarkerSize',14,'LineWidth',1.5,'Color',cList{gi});
end
xlabel('Time / (s)');
%grid on;
for j = 1:N
    lgd{N+1-j} = strcat("M",num2str(j));
end
%legend(p,{'FCU','FCR','ECR','ECU'},'Orientation','horizontal');
lim = [2,2+N*0.3+0.3];
ylim(-lim(end:-1:1))
ticks = [2+0.3:0.3:2+N*0.3];
yticks(-ticks(end:-1:1))
yticklabels(lgd)
set(gca,'FontSize',16)