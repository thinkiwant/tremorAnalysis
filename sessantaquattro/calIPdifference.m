function [diffList] = calIPdifference(SP1, SP2)
%[CoherenList, f, meanIPDiff, diffList] = calMeanIPDiff(SP1, SP2)

fs = 2000;

N1 = size(SP1,2);
N2 = size(SP2,2);
N = min(N1,N2)+1;
halfN = floor(N/2);

id1 = nchoosek(1:N1,halfN);
id2 = nchoosek(1:N2,halfN);

n=0;
for i = 2:size(id1,1)
    for j = 2:size(id2,1)
        cst1 = PoolCST(SP1(:,id1(i,:)));
        cst2 = PoolCST(SP2(:,id2(j,:)));
        n = n + 1;
        [c,f] = Coher(cst1,cst2);
        res = length(f)/(fs/2);
        lowLimitid = floor(1*res);
        upLimitid = floor(3*res);
        [~,maxid] = max(c(lowLimitid:upLimitid));
        %singleFreq(i) = f(lowLimitid+maxid-1);
        singleFreq = 1;

        if1 = calInstantaneousPhase1(cst1,'Freq',singleFreq);
        hold on;
        if2 = calInstantaneousPhase1(cst2,'Freq',singleFreq);
        hold off;

        legend('CST1','CST2');

        set(gca,'FontSize',20);

        %difference = abs(mean(unwrap(if1)-unwrap(if2)));
        df = if1-if2;
        PhaseDifference = abs(mean(df));

        diffList(n) = PhaseDifference;

    end
end

end
