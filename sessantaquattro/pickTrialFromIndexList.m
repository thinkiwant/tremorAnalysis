function [sLn, eLn] = pickTrialFromIndexList(sL,eL)

sLn = [];
eLn = [];
newTrial = 0;
[srtList, cls] = sort([sL,eL]);
clsS = length(sL);

for i = 1:length(srtList)
    if cls(i) <= clsS
        sti = i;
        newTrial = 1;
    elseif newTrial == 1
        sLn = [sLn, srtList(sti)];
        eLn = [eLn, srtList(i)];
        newTrial = 0;
    end
    i = i + 1;
end

end