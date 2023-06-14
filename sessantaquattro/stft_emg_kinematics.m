t= 0:length(data)-1;
t=t/2000;
ax(1) = subplot(411);
spectrogram(data(64+27,:),hamming(2^8),[],[],2000,'yaxis')
ylim([0,0.02]);
title("Short Time Fourier Transform of Extensor (Freq Resolution: 7.8125(Hz), Time Resolution: 0.128(s), 0 overlaping) ")
ax(1).Title.FontSize = 14;
ax(1).XLabel.String="";
ax(1).YLabel.FontSize=13;
ax(2) = subplot(412);
plot(t,data(64+27,:));
% xlabel("time / (second)");
ylabel("voltage / (mV)")
ax(2).Title.FontSize = 14;
ax(2).YLabel.FontSize=13;
title("EMG of Extensor")
ax(3) = subplot(413);
% plot(t,data(64*2+27,:));
% xlabel("time / (second)");
MUSP_bars(SpikeTrainGood(:,muList));
ylabel("voltage / (mV)")
%title("EMG of Flexor")
title("MU Spike Train")
ax(3).Title.FontSize = 14;
ax(3).YLabel.FontSize=13;
ax(4) = subplot(414);
plot(t,data(64*4+3,:));
% xlabel("time / (second)");
ylabel("acceletation / (g)")
title("Acceleration along z axis")
ax(4).Title.FontSize = 14;
ax(4).XLabel.String="Time / (Second)";
ax(4).XLabel.FontSize=12;
ax(4).YLabel.FontSize=13;
linkaxes(ax,'x')

