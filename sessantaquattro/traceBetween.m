function [reconstructSource1, reconstructSource2] = traceBetween(M1, M2, varargin)
% order of variables in M1 and M2: 1:SIL 2:sGood 3:SpikeTrainGood 4:B
% 5:GoodIndex 6:EMG_extend 7: NullChan
needPlot = false;
if(nargin==3)
    needPlot = varargin{3};
end
if(size(M1{4},1) ~= size(M2{4},1))
    warning("channel numbers don't match.");
    return
end
fs = 2000;
threshHold = 0.75;
SIL1 = M1{1};
SIL2 = M2{1};
GoodIndex1 = M1{5};
GoodIndex2 = M2{5};
id1 = GoodIndex1(find(SIL1>=threshHold));
id2 = GoodIndex2(find(SIL2>=threshHold));

B1 = M1{4}(:,id1);
B2 = M2{4}(:,id2);


reconstructSource1 = (B2' * M1{6})';
reconstructSource2 = (B1' * M2{6})';



if(~isempty(reconstructSource1) && needPlot)
    figure;
    tiledlayout('flow');
    t1 = 0:1/fs:(length(reconstructSource1)-1)/fs;
    for i = 1:length(id2)
        nexttile();
        plot(t1, reconstructSource1(:,i));
        xlabel("Time (second)");
    end
    sgtitle(sprintf("Reconstructed sources (%s)", inputname(1)), 'FontSize',20);
    set(gca, 'FontSize', 20)
end
    
if(~isempty(reconstructSource2) && needPlot)
    figure;
    tiledlayout('flow');
    t2 = 0:1/fs:(length(reconstructSource2)-1)/fs;
    for i = 1:length(id1)
        nexttile();
        plot(t2, reconstructSource2(:,i));
        xlabel("Time (second)");
    end
    sgtitle(sprintf("Reconstructed sources (%s)", inputname(2)), 'FontSize',20);
    set(gca, 'FontSize', 20)
end


end
