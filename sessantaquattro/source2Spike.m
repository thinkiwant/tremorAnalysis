function [SpikeTrain,C] = source2Spike(source)
% transform souce into SIL and corresponding spike trains
fs = 2000;    
N = size(source,2);
SpikeTrain = zeros(size(source));
for i = 1:N
    [pks,loc] = findpeaks(source(:,i).^2);   
    [idx,C] = kmeansplus(pks',2);
    %     [idx,~] = myCluster2(pks);      
    if sum(idx==1)<=sum(idx==2)
        SpikeLoc = loc(idx==1);
    else
        SpikeLoc = loc(idx==2);
    end
    SpikeTrain(SpikeLoc,i) = 1;
end

% plot(source)
% hold on 
% id1 = find(SpikeTrain==1);
% id2 = find(SpikeTrain==0);
% plot(id1, source(id1),'ro');
% plot(id2, source(id2),'g*');
% plot([1,length(source)],ones(1,2)*sqrt(C(1)),'b-','LineWidth',2)
% plot([1,length(source)],ones(1,2)*sqrt(C(2)),'b-','LineWidth',2)