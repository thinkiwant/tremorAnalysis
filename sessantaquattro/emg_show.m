function emg_show(data)

close all
%data = csvread(filepath);

md_i = 1;
c_i = 1;
subplot(2,10,1);
rms_list=[];
for md = 0:64:254

    rms_list = [rms_list, mean(rms(data(end-2000:end,md+1:md+64),1))];
    for column = 0:13:64
        subplot(2,10,c_i);
        xlb = sprintf("M %d,Chan %d~%d", floor(md/64)+1, column+1, column+13);
        interval=0;
        c_i = c_i + 1;
            for row = 1:13
                if column > 41 && row == 13
                    continue
                end
                interval = interval + 2;
                plot(data(300:end,md+column+row)+interval);
                title(xlb);
                hold on;
            end
    end

end
rms_list;
end