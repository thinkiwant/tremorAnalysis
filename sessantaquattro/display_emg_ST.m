close all;
fs = 1000;
chan_num = 256;
plot_row = 3;
plot_col = 1;
data_length = length(DataMatrix);
t = 1/fs:1/fs:(data_length/fs);
chan1 = 1;
chan2 = 128;
chan_list = 1: floor(chan_num/10): chan_num;
emg_chan1 = DataMatrix(:,chan1);
emg_chan2 = DataMatrix(:,chan2);
show_window=[0.3,0.3+0.018]*data_length/fs;
ax(1) = subplot(plot_row,plot_col,1);
list = [1 2 3];
for i = 1:length(list)
    plot(t, SpikeTrainGood(:,list(i))+i*2,'LineWidth',5);
    hold on ;
end
xlabel('Time / (Second)');
ylabel('Spike Train');
axis([show_window,2 12]);

ax(2) = subplot(plot_row,plot_col,2);
plot(t, emg_chan1);
axis([show_window,min(emg_chan1),max(emg_chan1)]);
xlabel('Time / (Second)');
ylabel('EMG / (mV)');

ax(3) = subplot(plot_row, plot_col,3);
plot(t, emg_chan2);
axis([show_window,min(emg_chan2),max(emg_chan2)]);
xlabel('Time / (Second)');
ylabel('EMG / (mV)');


figure;
for j = 1:length(chan_list)
    ax(4) = plot(t,DataMatrix(:,j)+j*0.5);
    hold on;
end
axis([show_window,min(DataMatrix(:,chan_list(1))),1+length(chan_list)*0.5]);
xlabel('Time / (Second)');
ylabel('EMG / (mV)');

linkaxes(ax,'x');