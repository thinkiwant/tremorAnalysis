function decomposeAndSaveMU(data, seg)
% decompose the segment of emg signal into MUs according to seg. seg
% consists of 2 * the number of segmentation pairs, with each pair of segment
% being the begainning and ending index.e.g seg = [s1, e1, s2, e2, ...] If
% the parameter seg is not provided the who data will be decomposed without
% segmentation processing. data is the emg signal with each column
% corresponding to channel and row to continuous samples.
[m,n] = size(data);
if m<n
    data = data';
end

if nargin == 2
    pair_num2 = max(size(seg));
    group_num = min(size(seg));
    if rem(pair_num2,2)~=0
        error("seg should contain index of even number.");
    elseif group_num~=1
        error("seg should satisfy the format of 1 x (2*pairs).");
    else
        for i = 1:pair_num2/2
            if seg(i*2-1)>=seg(i*2)
                error(strcat("Invalid segment index", num2str(i)));
            else
                tempData{i} = data(seg(i*2-1):seg(i*2),:);
            end
        end
    end
elseif nargin == 1
    tempData{1} = data;
end 
    
tic

n = length(tempData);
sprintf('the number of trials: %d', n)

trialStartIdx=1:128:256;

for i = 1:n % i th trial
    idx = [seg(i*2-1),seg(i*2)];
    trialData = tempData{i};
    fileName = "MU210909";
    fileName = fileName + 't' + num2str(i);
    for j = 1:length(trialStartIdx) % module
        fileName1 = fileName + 'm' + num2str(j);
        moduleData = trialData(:,trialStartIdx(j):trialStartIdx(j)+127);
        size(moduleData)
        DataMatrix = moduleData;
        s = sum(DataMatrix,1);
        id_del = find(s==0);
        DataMatrix(:,id_del) = [];
        SJTUDemo_MARemoval_Main();
        
        SJTUDemo_Decomp_Main();
        save(fileName1,'SIL','SpikeTrainGood','sGood','id_del','idx');
        display(strcat(fileName1," is saved"))
        toc
        display("****************************")
    end
end

end