function [diffList] = calIPDiff(SP1, SP2)

N1 = size(SP1,2);
N2 = size(SP2,2);
N = min(N1,N2);
halfN = floor(N/2)
fs = 2000;

diffList=[];

for i = 1:20
    id = randperm(N);
    cst1 = PoolCST(SP1(:,id(1:halfN)));
    cst2 = PoolCST(SP2(:,id(halfN+1:halfN*2)));
        
    [c,f] = Coher(cst1,cst2);
    res = length(f)/(fs/2);
    lowLimitid = floor(1*res);
    upLimitid = floor(3*res);
    [~,maxid] = max(c(lowLimitid:upLimitid));
    singleFreq(i) = f(lowLimitid+maxid-1);

    if1 = calInstantaneousPhase1(cst1,'Freq',singleFreq);
    hold on;
    if2 = calInstantaneousPhase1(cst2,'Freq',singleFreq);
    hold off;

    legend('CST1','CST2');

    set(gca,'FontSize',20);

    %difference = abs(mean(unwrap(if1)-unwrap(if2)));
    df = if1-if2;
    PhaseDifference = abs(mean(df));

    diffList(i) = PhaseDifference;
%     if PhaseDifference >1000
%         i
%         %plot([if1',if2'])
%         plot([if1,if2,if1-if2])
%         
%         figure
%         title('large phase difference')
% 
%         break
%     end
end
plot(singleFreq);
xlabel('Degree')
end