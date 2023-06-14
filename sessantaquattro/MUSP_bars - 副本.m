function MUSP_bars(musp, grpid)
% this function draws the MUSP in the form of series of bars. Each column
% correspinds to an MU while row is for length of signals.
cList={'#0072BD','#D95319','#EDB120','#7E2F8E'};
N = size(musp,2);
if nargin>1
    groupN = length(grpid);
    if sum(grpid)~=N
        error("unmatched group partition and the amount of musps\n");
    end
else
    groupN=1;
    grpid=[N];
end

t=0:length(musp)-1;
t=t/2000;

for i = 1:N
    id = find(musp(:,i));
    Lvl{i} = ones(length(id))*i*0.3;
    FireT{i} = t(id);
    
end

c = 1;
for gi = 1:groupN
    for mi = 1:grpid(gi)
        stem(FireT{c},Lvl{c},'|','LineStyle','none','MarkerSize',14,'LineWidth',1.5,'Color',cList{gi});
        hold on;
        c = c + 1;
    end
end


%stem(t,musp,'|','LineStyle','none','MarkerSize',14,'LineWidth',1.5)
xlabel('Time / (s)');
%grid on;
for j = 1:N
    lgd{j} = strcat("M",num2str(j));
end
legend({'FCU','FCR','ECR','RCU'},'Orientation','horizontal');
yl=[0:0.3:(N+1)*0.3];
ylim([yl(1),yl(end)])
yticks(yl(2:end-1))
yticklabels(lgd)
set(gca,'FontSize',16)