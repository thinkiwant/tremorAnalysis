

% STFT
i=1;data = experiment1{i}(27,:);spectrogram(data,2^11,[],2^11,2000,'y');title('Short Time Fourier Transform (Post, DBS-on, Resting)');ax=gca;set(ax,'FontSize',16),axis([0 inf 0 0.03])