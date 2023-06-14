function [c1, f1, c2, f2] = calMeanPeakCoher(cAll)
%This function returns the coherence peaks at tremor and double tremor frequency.
%The tremor frequency is determined by the mean frequency of all coherence profiles.

fs = 2000;
freq = [3.5, 6];  %   frequency for tremor band
windowWidth = 1;    % frequency width for accumulating coherence

peaksId=zeros(1,size(cAll,2));
peaksId2=zeros(size(peaksId));
c1=zeros(1,size(cAll,2));
c2=zeros(size(c1));

pointPerFreq = (length(cAll)/(fs/2));
for i = 1:size(cAll,2)  % locate the peak in frequency scale
    c = cAll(:,i);
    
    freqId = round(freq*pointPerFreq);
    startId = freqId(1);
    [p1, loc1] = findpeaks(c(startId:freqId(2)));
    if(isempty(p1))
        p1 = c(startId);
        loc1 = startId;
    end
    [pv,id1] = maxk(p1,1);    % get the maximum peak
    peakId = loc1(id1) + startId - 1;
    
    peaksId(i) = peakId;
    peakId2 = 2*peakId-1;
    search_width = pointPerFreq/3;
    interval = round(peakId2-search_width): round(peakId2+search_width);
    %     [p2, loc2] = findpeaks(c(interval));
    [p2, loc2] = max(c(interval));
    
    [~, id2] = maxk(p2,1);
    
    peakId2 = loc2(id2) + round(peakId2-search_width) - 1;
    if(isempty(peakId2))
        peakId2 = 2*peakId-1;
    end
    peaksId2(i) = peakId2;
    
end
%             disp(peaksId)
%             disp(peaksId2)

mfId = round(mean(peaksId, 'omitnan'));    % the idx of mean tremor-freq COH
mf2Id = round(mean(peaksId2, 'omitnan'));  % the idx of mean double-tremor-freq COH

for i = 1:size(cAll,2)  % calculate mean coherence in peaks
    c = cAll(:,i);
    
    WinLeftId1 = mfId - round(windowWidth/2*pointPerFreq);
    WinRightId1 = mfId + round(windowWidth/2*pointPerFreq);
    
    WinLeftId2 = mf2Id - round(windowWidth/2*pointPerFreq);
    WinRightId2 = mf2Id + round(windowWidth/2*pointPerFreq);
    
    freqN = round(windowWidth * pointPerFreq);
    
    % mark windows
    %     figure
    %     hold on
    %     plot(cAll(:,i))
    %     plot(WinLeftId1*ones(1,2), [0 100],'r-');
    %     plot(WinRightId1*ones(1,2), [0 100],'r-');
    %     plot(WinLeftId2*ones(1,2), [0 100],'g-');
    %     plot(WinRightId2*ones(1,2), [0 100],'g-');
    
    s1 = sum(c(WinLeftId1:WinRightId1)) /freqN ;
    s2 = sum(c(WinLeftId2:WinRightId2)) /freqN;
    %     s1 = sum(c(WinLeftId1:WinRightId1));
    %     s2 = sum(c(WinLeftId2:WinRightId2));
    c1(i) = s1;
    c2(i) = s2;
end
f1 = peaksId/pointPerFreq;
f2 = peaksId2/pointPerFreq;
end