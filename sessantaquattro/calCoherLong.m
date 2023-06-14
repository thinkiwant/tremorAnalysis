function [c, f, l] = calCoherLong(sig1, sig2, sig3)
%When one single signal is taken as input, the output is the intramusclar
%Coherence. If two signals are taken as input, the output is the
%intermusclar Coherence of the two signals. If three signals are taken as
%input, the output will be the partial Coherence of the first two signals
%with the reference of the third one. c :Coherence f: freqency l:Confidence
%Level

x=[];
y=[];
z=[];
n1 = size(sig1,2);
if(nargin == 1)
    id = nchoosek(1:n1,2);      % traverse all 2-combination of MUs
    for i = 1:size(id,1)
        x = [x;sig1(:,id(i,1))];
        y = [y;sig1(:,id(i,2))];
    end
    [c,f,l] = Coher(x,y);
    titleText = 'Intra-muscle Coherence';
elseif(nargin == 2)
    n2 = size(sig2,2);
    for i = 1:n1
        for j = 1:n2
            x = [x; sig1(:,i)];
            y = [y; sig2(:,j)];
        end
    end
    [c,f,l] = Coher(x,y);
    titleText = 'Inter-muscle Coherence';
elseif(nargin == 3)
    n2 = size(sig2,2);
    zt = PoolCST(sig3);     % to get the composite spike train of the reference signal
    for i = 1:n1
        for j = 1:n2
            x = [x; sig1(:,i)];
            y = [y; sig2(:,j)];
            z = [z; zt];
        end
    end
    [c,f,l] = PCoher(x,y,z);
    titleText = 'Partial Coherence';
end


plot(f,c,'LineWidth',1.5);
[pc,pf] = findpeaks(c,f);
[sortPc, id] = sort(pc,'descend');
hold on
m=3;
% plot(pf(id(1:m)),pc(id(1:m)),'ro');
% plot(f,l*ones(size(f)),'r--','LineWidth',2);
%hold off
set(gca,'FontSize',16);
title(titleText);
axis([0 20 0 1]);