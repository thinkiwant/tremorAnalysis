function [CohereList, f] = calCohe(SP1, SP2)
%[CoherenList, f, meanIPDiff, diffList] = calMeanIPDiff(SP1, SP2)

fs = 2000;

N1 = size(SP1,2);
N2 = size(SP2,2);
N = min(N1,N2)+1;
halfN = floor(N/2);

id1 = nchoosek(1:N1,halfN);
id2 = nchoosek(1:N2,halfN);

n=0;
for i = 1:size(id1,1)
    for j = 1:size(id2,1)
        cst1 = PoolCST(SP1(:,id1(i,:)));
        cst2 = PoolCST(SP2(:,id2(j,:)));
        n = n + 1;
        [CohereList(:,n),f,confidenLvl] = Coher(cst1,cst2);
    end
end

%figure
% iterN = 100;
% for i = 1:iterN
%     id = randperm(N);
%     cst1 = PoolCST(SP1(:,id(1:halfN)));
%     size(SP2)
%     cst2 = PoolCST(SP2(:,id(halfN+1:halfN*2)));
%     %[CohereList(:,i),f] = mscohere(cst1,cst2,[],0,[],2000);
%     [CohereList(:,i),f,confidenLvl] = Coher(cst1,cst2);
% end

alpha = 0.95;
plot(f,CohereList(:,1:N1:n),'Color',[169,169,169]/256,'LineWidth',0.05);
hold on;
meanCohr = mean(CohereList,2);
plot(f,meanCohr,'b',f,ones(size(f))*confidenLvl,'r--','LineWidth',2);
tremorFreqId = find(f>=3&f<=15); % choose peaks within 4~15Hz to display
[v,p] = findpeaks(meanCohr(tremorFreqId),'MinPeakHeight',confidenLvl);
peakID = tremorFreqId(p);
peaksf = f(peakID);
plot(peaksf,v,'ok');
str={};
format = '%.2f';
for i = 1:length(peakID)
    str{i} = strcat('(',num2str(peaksf(i),format),',',num2str(v(i),format),')');
end
text(f(peakID),v,str,'FontSize',12,'color','b')
hold off
ax = gca;
set(ax,'FontSize',16)
title(strcat('n=',num2str(n)));
%xlabel('Frequency (Hz)')
%ylabel('Coherence')
axis([0,20,0,1])

end


