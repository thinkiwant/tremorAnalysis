function [ST, SIL, sGood, indexGood]= findGoodSourceID(s, mode)
% s is the source matrix with individual source aligned along the column.
% This program pikes out good sources by
% applyting restrictions to  SIL, discharge rate and length of idle interval.
% mode = 0 standard 1, mode = 1 standard 2, mode = 2 conbines mode 1 and mode 2 
if(nargin==1)
    mode = 0;
end
ST=[];
SIL=[];
sGood=[];
indexGood=[];
if(isempty(s))
    return
end
fs = 2000;
ST = source2Spike(s);
if(~any(ST))
    return;
end
[ST, indexGood] = MUReplicasRemoval(ST, s, fs);
if(~any(indexGood))
    return;
end
m = length(ST);
firstState = ST(1,:);
lastState = ST(end,:);
STgood = ST(:,indexGood);
STgood(1,:) = 1;
STgood(end,:) = 1;
sGood = s(:,indexGood);
SIL = SILCal(sGood, fs);
if(mode==0)
%     fprintf("case 1\n");
    idx = find(SIL <= 0.99 & SIL>=0.75); % setting SIL restriction
    STgood = STgood(:,idx);
    sGood = sGood(:,idx);
    SIL=SIL(idx);
    indexGood = indexGood(idx);
    
    dischargeRate = calFiringRate(STgood);
    idx = find(dischargeRate>3 & dischargeRate<35); % setting discharge rate
    STgood = STgood(:,idx);
    sGood = sGood(:,idx);
    SIL=SIL(idx);
    indexGood = indexGood(idx);

    idleMaxLength = floor(m*0.5);  % setting idle length
    newIdx=[];
    for i = 1:length(idx)
        curSP = STgood(:,i);
        dischargeTime = find(curSP);
        sourcePeak = sGood(dischargeTime,i);

        deltaT = diff(dischargeTime);
        sumMax = sum(maxk(deltaT,3));
        if(sumMax>idleMaxLength)    %ignore spike train with long idle period
            continue;
        end
        meanmaxpeak = mean(maxk(sourcePeak,3));
        meanpeak = mean(sourcePeak);
        if(meanmaxpeak>=5*meanpeak)  %ignore spike train with too high spike
            %fprintf("maxpeak: %f, meanpeak: %f\n\n;",meanmaxpeak,meanpeak);
            continue;
        end
        numoflowpeak = length(find(sourcePeak<mean(sGood(:,i))));

        if(numoflowpeak>0.1*length(dischargeTime))  %ignore spike train with a few peaks below the mean 
            %fprintf("num of low peaks: %d is more than 0.05 of total peaks: %d\n\n;",numoflowpeak,0.05*length(dischargeTime));
            continue;
        end
        newIdx=[newIdx,i];
    end
    sGood = sGood(:,newIdx);
    ST = STgood(:,newIdx);
    SIL = SIL(newIdx);
elseif(mode == 1)
%     fprintf("case 2\n");
    idx = find(SIL <= 0.99 & SIL>=0.70); % setting SIL restriction
    STgood = STgood(:,idx);
    sGood = sGood(:,idx);
    SIL=SIL(idx);
    indexGood = indexGood(idx);
    
    dischargeRate = calFiringRate(STgood);
    idx = find(dischargeRate>3 & dischargeRate<35); % setting discharge rate
    STgood = STgood(:,idx);
    sGood = sGood(:,idx);
    SIL=SIL(idx);
    indexGood = indexGood(idx);

    idleMaxLength = floor(m*0.7);  % setting idle length
    newIdx=[];
    %disp(idx)
    for i = 1:length(idx)
        curSP = STgood(:,i);
        dischargeTime = find(curSP);
        sourcePeak = sGood(dischargeTime,i);

        deltaT = diff(dischargeTime);
        sumMax = sum(maxk(deltaT,3));
        if(sumMax>idleMaxLength)    %ignore spike train with long idle period
            continue;
        end
        meanmaxpeak = mean(maxk(sourcePeak,3));
        meanpeak = mean(sourcePeak);
        if(meanmaxpeak>=5*meanpeak)  %ignore spike train with too high spike
            %fprintf("maxpeak: %f, meanpeak: %f\n\n;",meanmaxpeak,meanpeak);
            continue;
        end
%        numoflowpeak = length(find(sourcePeak<mean(sGood(:,i))));
% 
%         if(numoflowpeak>0.1*length(dischargeTime))  %ignore spike train with a few peaks below the mean 
%             fprintf("num of low peaks: %d is more than 0.05 of total peaks: %d\n\n;",numoflowpeak,0.05*length(dischargeTime));
%             continue;
%         end
        newIdx=[newIdx,i];
    end
    sGood = sGood(:,newIdx);
    ST = STgood(:,newIdx);
    SIL = SIL(newIdx);

elseif(mode == 2)
%     fprintf("case 3\n");
    id2=[];
    id3=[];
    leftSet = [];
    [~,~,~,id1] = findGoodSourceID(sGood);
    wholeSet = 1:size(sGood,2);
    if(length(id1)<3)
        leftSet = setdiff(wholeSet, id1);
        if(any(leftSet))
            [~,SIL2,~,id2] = findGoodSourceID(sGood(:,leftSet),1);
            [~,id3] = maxk(SIL2,3);
        end
    end
    newIdx = [id1,leftSet(id2(id3))];
    ST = STgood(:,newIdx);
    SIL = SIL(newIdx);
    sGood = sGood(:,newIdx);
end

indexGood = indexGood(newIdx);
if(any(ST))
    ST(1,:) = firstState(indexGood);
    ST(end,:) = lastState(indexGood);
end
end
    
function fr = calFiringRate(ST, fs)
    if(nargin==1)
        fs = 2000;
    end
    [l,col] = size(ST);
    fr=zeros(1,col);
    times = sum(ST); 
    for i = 1:col
        curST = ST(:,i);
        t= find(curST~=0);
        d = sum(maxk(diff(t),3));
        curFr = times(i)/(l-d)*fs;
        fr(i) = curFr;
    end
end