function f = plotMultiChanEMG(data)
% data contains multiple channels of EMG signal, the less on between row
% and column will be taken as the number of channel and the other as the
% number of sample for each channel.

[m,n] = size(data);

if n>m
    data = data';
end

ChanNum = size(data,2);

f = tiledlayout('flow','TileSpacing','none','Padding','none');

for i = 1:ChanNum
    a(i) = nexttile;
    plot(data(:,i));
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    text(0.7,0.13,num2str(i),'Units','normalized')

end

linkaxes(a,'x')

end
