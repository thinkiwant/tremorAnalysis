function EMG_Reconstruct = MotionArtifactRemoval(Data,Fs)
[N,NumCh] = size(Data);
[EMG1,W1] = SimEMGProcessing(Data,'R',0,'WhitenFlag','On','SNR','Inf');
[B3,~,~,~,~,~,~,~] = ext_infomax_runica(EMG1,'stop',10^-4,'verbose','off');
s3 = EMG1'*B3';
for j = 1:NumCh
    [pxx,f] = pwelch(s3(:,j),[],[],[],Fs);
    Gain = round(length(f)/(Fs/2));
    PowerMA = mean(pxx(1:50*Gain));
    PowerEMG = mean(pxx(100*Gain:200*Gain));
    if PowerMA > PowerEMG
        s3(:,j) = zeros(N,1);
    end
end
EMG_Denoise = inv(B3)*s3';
EMG_Reconstruct = (inv(W1)*EMG_Denoise)';
end