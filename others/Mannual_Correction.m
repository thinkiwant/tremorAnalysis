function [startList, endList] = Mannual_Correction(trigger,fs)
% Trigger Auto-recognition
% If some triggers were distorted, mannually set trial begin and end
% fs = 2000;
% trigger = sig(66,:);
% trigger通道后100个点有可能出现异常，删去
trigger(end-99:end) = [];
trigger(1:100) = max(trigger);
fig = figure;
plot(trigger);
threshold = 10; % set the threshold for low voltage (mV）
N = 1; % trial number
neg_index = find(trigger<threshold);
index_diff = diff(neg_index);
len = length(neg_index);
j = 1;
if neg_index(1) == 1
    c = neg_index(1)-1;
else
    fList(1) = neg_index(1);
    c = neg_index(2)-1;
end
singleClickDuration = 5;
dur = 0;
while j < len
    if index_diff(j) < singleClickDuration
        dur = dur + 1;
    else
        rList(N) = neg_index(j);
        fList(N+1) = neg_index(j+1);
        clickDuration(N)  = dur+1;
        dur = 0;
        N = N + 1;
    end
    j = j + 1;
end
if trigger(end) > 1
    rList(N) = neg_index(end);
    clickDuration = rList(end) - fList(end) + 1;
end
% 识别double triggers 信号
trialNum3 = 0;
trialNum2 = 0;
trigIndex2 = [];
trigIndex3 = [];
startList = []; % double trigger信号的索引
endList = [];  % triple trigger 信号的索引
checkPoint = []; % 检查点 单信号 的索引
singleTrigNum = length(fList);
clickInterval = 0.2 * fs;
i = 1;
while i < singleTrigNum
    interval = rList(i) - fList(i);
    if interval < 0.2 * fs && interval > 1
        doubleClickInterval1 = fList(i+1)-fList(i);
        doubleClickInterval2 = rList(i+1)-rList(i);
        % double click trigger feature
        if doubleClickInterval1<0.4*fs && doubleClickInterval2<0.4*fs
            triClickInterval1 = fList(i+2)-fList(i+1);
            triClickInterval2 = rList(i+2)-rList(i+1);
            % triple clicks trigger feature
            if triClickInterval1<0.4*fs && triClickInterval2<0.4*fs
                trialNum3 = trialNum3 + 1;
                endList = [endList,fList(i)];
                trigIndex3 = [trigIndex3, i];
                i = i + 3;
            elseif triClickInterval1>10*fs && triClickInterval2>10*fs
                trialNum2 = trialNum2 + 1;
                startList = [startList,fList(i)];
                trigIndex2 = [trigIndex2,i];
                i = i + 2;
            end
        else
            checkPoint = [checkPoint,fList(i)];
            i = i + 1;
        end
    % 如果信号不满足持续时间小于0.2fs，可能这个信号有问题，有有问题的信号手工标注    
    else 
        if trialNum2 ~= trialNum3
            trialNum = min([trialNum2,trialNum3]);
            startList(trialNum:end) = [];
            % 有问题的trigger前后的信号索引选出来手动标注
            % 最后一个完好的triple trigger信号的索引
%             qIndex1 = rList(trigIndex3(trialNum));
%         else
%             qIndex1 = rList(trigIndex3(trialNum3));
        end
        fprintf("请点选有问题的区域\n");
        [x,~] = ginput(2);
        fig1 = figure;
        plot(trigger(x(1):x(2)-1))
        fprintf("选择开始点附近的两个区域以放大\n");
        [x1,~] = ginput(2);
        xlim([x1(1),x1(2)])
        [q_start,~] = ginput(1);
        startList = [startList,x(1)+q_start-1];
        xlim([0 x(2)-x(1)-1]);
        fprintf("选择结束点附近的两个区域以放大\n");
        [x2,~] = ginput(2);
        xlim([x2(1),x2(2)]);
        [q_end,~] = ginput(1);
        endList = [endList,x(1)+q_end-1];
        close(fig1);
        while rList(i)<x(2)
            i = i + 1;
        end
    end
end
close(fig)
end






        
