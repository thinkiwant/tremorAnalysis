[sL, eL, aL,~] = findInterval(sig(66,:));
for i = 1:length(sL)
    trials{i}=sig(1:64,sL(i):eL(i));
    %EMG_Reconstruct = trials{i}';
    %SJTUDemo_Decomp_Main();
    %file_name = strcat('MU0714A01_t',int2str(i));
    %save(file_name,'sGood','SpikeTrainGood','SIL');
end