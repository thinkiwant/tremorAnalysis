%%  
function sign = Convert_BIO_File(file_path,destiny_dir)
% convert bio file to .mat file or .csv file
if nargin == 1
    destiny_dir = "C:\Users\admin\Desktop\";
    sign = Convert_File(file_path, destiny_dir);
elseif nargin == 2
    sign = Convert_File(file_path, destiny_dir);
end

% if mod(fileNum, 4) ~= 0
%     warning("文件数目不是4的整数倍，文件可能有遗漏")
% end
% expNum = fileNum / 4;
% for i = 1 : expNum
%     for j = 1 : 4
%         [allTrial{i}, trialNum] = Open_sessa_bio_file(strcat(file_path,"\", fileInfo(i+2).name));
%     end
% end

end
function success = Convert_File(file_path, destiny_dir)
imu_file = dir(strcat(file_path,'\imu\*','.txt'));
% 寻找文件数字开始
imu_available = 1; 
%是否有IMU数据 1有 0无

emgFileid = [2, 3]
imuFileid = [2, 3]

for t = 1:length(emgFileid)
    eID = emgFileid(t);
    iID = imuFileid(t);
%     regex = strcat(file_path,"\emg\m",num2str(m),"*F*", num2str(t),".BIO");
%     temp = dir(regex);
%     if isempty(temp)
%         continue
%     else
%         regexA = strcat(file_path,'\emg', "\*OA*",num2str(t),".BIO");
%         regexB = strcat(file_path,'\emg', "\*OB*",num2str(t),".BIO");
%         regexC = strcat(file_path,'\emg', "\*OC*",num2str(t),".BIO");
%         regexD = strcat(file_path,'\emg', "\*OD*",num2str(t),".BIO");
%         fileAInfo = dir(regexA);
%         fileBInfo = dir(regexB);
%         fileCInfo = dir(regexC); 
%         fileDInfo = dir(regexD);
%         if isempty(fileAInfo) == 1
%             warning(["**A0",num2str(t),".BIO 文件缺失，请确认"]);
%         end
%         if isempty(fileBInfo) == 1
%             warning(["**B0",num2str(t),".BIO 文件缺失，请确认"]);
%         end
%         if isempty(fileCInfo) == 1
%             warning(["**C0",num2str(t),".BIO 文件缺失，请确认"]);
%         end
%         if isempty(fileDInfo) == 1
%             warning(["**D0",num2str(t),".BIO 文件缺失，请确认"]);
%         end
        disp(1)
        tempPath = strcat(file_path,"\emg\a\*A*",".BIO");
        d = dir(tempPath);
        [device1,trialNum] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device1,trialNum] = Open_sessa_bio_file('sig1.mat','sigFile',1);

        disp(2)
        tempPath = strcat(file_path,"\emg\b\*B*",".BIO");
        d = dir(tempPath);
        [device2,trialNum2] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device2,trialNum2] = Open_sessa_bio_file('sig2.mat','sigFile',1);
        
        disp(3)
        tempPath = strcat(file_path,"\emg\c\*C*",".BIO");
        d = dir(tempPath);
        [device3,trialNum3] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device3,trialNum3] = Open_sessa_bio_file('sig3.mat','sigFile',1);
        
        disp(4)
        tempPath = strcat(file_path,"\emg\d\*D*",".BIO");
        d = dir(tempPath);
        [device4,trialNum4] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device4,trialNum4] = Open_sessa_bio_file('sig4.mat','sigFile',1);%Use trigger channel of Module 3 to rectify Module 4

        if imu_available == 1
                imu = loadIMUdata(strcat(imu_file(iID).folder,'\',imu_file(iID).name));
            disp(5)
            [sL_imu,eL_imu,~,~] = findInterval(imu(:,end),200);% Fs of IMU is 200 set as deault.


             if trialNum == trialNum2 && trialNum2 == trialNum3 && trialNum3 == trialNum4 && trialNum4 == length(sL_imu)

                disp('trial numbers match with each other');
            else
                warning('trial numbers do not match');
                 trialNum = min([trialNum,trialNum2,trialNum3,trialNum4]) % Only the several frontal communal trials are concatenated
            end
            eval(strcat("experiment",num2str(emgFileid(t)),"=cell(trialNum,1);"));
            for j = 1:trialNum
                j
                dataLength = min([length(device1{j}),length(device2{j}),length(device3{j}),...
                    length(device4{j})]);
                id = sL_imu(j):(eL_imu(j)-sL_imu(j))/(dataLength-1):eL_imu(j);
                itpIMU = interp1(sL_imu(j):eL_imu(j),imu(sL_imu(j):eL_imu(j),1:end-1),id,'linear');
                disp(dataLength)
                disp(length(itpIMU))

                eval(strcat("experiment",num2str(emgFileid(t)),"{j} = [device1{j}(:,1:dataLength);",...
                    "device2{j}(:,1:dataLength);device3{j}(:,1:dataLength);device4{j}(:,1:dataLength);itpIMU'];"));
                whos device1
                whos experiment5{1}
            end
        else
             if trialNum == trialNum2 && trialNum2 == trialNum3 && trialNum3 == trialNum4
                disp('trial numbers match with each other');
            else
                warning('trial numbers do not match.');
                trialNum = min([trialNum,trialNum2,trialNum3,trialNum4]); % Only the several first communal trials are concatenated
                Order = input(' Please choose asending or descending order alignment A/D [A]','s');               
                
            end
            eval(strcat("experiment",num2str(emgFileid(t)),"=cell(trialNum,1);"));
            for j = 1:trialNum
                j
                dataLength = min([length(device1{j}),length(device2{j}),length(device3{j}),...
                    length(device4{j})]);
                eval(strcat("experiment",num2str(emgFileid(t)),"{j} = [device1{j}(:,1:dataLength);",...
                    "device2{j}(:,1:dataLength);device3{j}(:,1:dataLength);device4{j}(:,1:dataLength)];"));
                whos device1
                whos experiment5{1}
            end
        end
            
    
        
        fileTag = strcat(destiny_dir,"\","experiment",num2str(emgFileid(t)),".mat");
        save(fileTag,strcat("experiment",num2str(emgFileid(t))));
%     end
end
success = 1;
end
function [trial, trialNum, trialInfo] = Open_sessa_bio_file(file_name, varargin)
% modified from codes from bio lab

% Example scrip to open and plot signals recorded on a SD card
% by sessantaquattro. The script read all the necessary information
% from the file header (Sampling frequency, number of channels, gain ...)
%
% E. Merlo
% 9 maggio 2019
% v.1.1
%
    sigFlag = 0;
    refFileName=[];
for i = 1:2:length(varargin)


    switch varargin{i}
        case 'refFilePath'
            refFileName = varargin{i+1};
        case 'sigFile'
            sigFlag = varargin{i+1}
    end
end



% Initialization ----------------------------------------------------------
if(sigFlag==0)
    % File open ---------------------------------------------------------------
    % Ask the user to select a file
    hh=fopen(file_name,'r');
    % Read and decode the information in the file header ----------------------
    FirmVersion = fgetl(hh);
    FirmDate = fgetl(hh);
    Fsamp = str2num(fgetl(hh));

    i = 0;
    [Value,IsANumber] = str2num(fgetl(hh));
    while(IsANumber)
        i = i + 1;
        ConvFact{i} = Value;
        Offset{i} = str2num(fgetl(hh));
        Resolution{i} = str2num(fgetl(hh));
        NumChan{i} = str2num(fgetl(hh));
        MeasUnit{i} = fgetl(hh);
        RangeMin{i} = str2num(fgetl(hh));
        RangeMax{i} = str2num(fgetl(hh));
        Mode{i} = str2num(fgetl(hh));

        [Value,IsANumber] = str2num(fgetl(hh));
    end

    NumTypeSig = i;
    TotNumChan = 0;
    for i = 1 : NumTypeSig
        TotNumChan = TotNumChan + NumChan{i};
    end

    fclose all;

    % Read and discard the file header ----------------------------------------
    hh=fopen(file_name,'r');
    sig = fread(hh,512,'char');
    clear sig;

    % Reads data from the file ------------------------------------------------
    if(Resolution{1} == 2)
        sig = fread(hh,[TotNumChan,inf],'int16','b');
    else
        %sig = fread(hh,[TotNumChan,inf],'bit24');

        ChInd = (1:3:TotNumChan*3);
        Temp = fread(hh, [TotNumChan * 3, inf], 'uint8');
        sig = Temp(ChInd,:)*65536 + Temp(ChInd+1,:)*256 + Temp(ChInd+2,:);
        ind = find(sig >= 8388608);
        sig(ind) = sig(ind) - (16777216);
    end

    fclose all;

    % Convert data in the correct unit ----------------------------------------
    FirstCh = 1;
    for j = 1 : NumTypeSig
        sig(FirstCh:FirstCh+NumChan{j}-1,:) = (sig(FirstCh:FirstCh+NumChan{j}-1,:)*ConvFact{j})-Offset{j};
        FirstCh = FirstCh + NumChan{j};
    end
else
    load(file_name,'sig','Fsamp');
end
% Estimate the acquisition length -----------------------------------------
sig_dur = length(sig(1,:));

% Time vector in seconds --------------------------------------------------
t = linspace(0, sig_dur/Fsamp, sig_dur);

% Separate signals to different trials
% 某次记录可能包含很多次trial，根据设计，trigger通道有2次连续电位下降标记为trial的开始
% 连续三次电位下降标记为trial的结束    --bai
trigger = sig(66,:);
%手动修正
[startList , endList, ~, ~] = findInterval(trigger)
if(isempty(startList))
    if(isempty(refFileName))
        error("please enter a file path for rectification.");
    end
    if(sigFlag==0)
        sigRef = return_sessa_bio_file(refFileName);
    else
        sigStruct = load(refFileName,'sig');
        sigRef = sigStruct.sig;
    end
    
    trigger = rectifiyTrigger(sig,sigRef);
    figure
    plot(trigger)
    length(trigger)
    disp("trigger rectified.")  
    [startList , endList, ~, ~] = findInterval(trigger)
end
% 
% trig_diff = diff(trigger);
% neg_index = find(trig_diff < -500);
% pos_index = find(trig_diff > 500);
% % trig_time = [];
% points = diff(neg_index);
% bi = [];
% tri = [];
% N = 1;
% % 这个算法的思想是先对原始trigger信号进行一次差分，差分后求小于-500的的点的
% % 横坐标neg_index，然后对neg_index求一次差分，可以得到trigger信号出现的点位差points
% % 如果是双trigger信号，points就会出现200-800之内的一个数据，因为双trigger信号
% % 中间相隔0.1 - 0.4s * 2000Hz = 200 - 800的点位差，这里假设按下两次信号的间隔在
% % 0.1s - 0.4s之间，因此操作的时候要注意
% % 如果是三trigger信号，points就会出现两个连续的200-800之内的点位差数据，这里的连续
% % 并不是严格连续，因为中间可能会有 1 2 等数据出现，比如三trigger数据可能是这样的
% % 202800 202801 //一次trigger可能会有两个点 202800+500 202800+500+1
% % //500个点后出现第二次trigger
% % 203300+400 203300+400+2 //400个点后出现第三次trigger
% % 这样点位差序列就变成了1 500 1 400 2 下面算法就是识别这种模式的
% while N < length(points)
%     % 阈值设置的较宽，200对应0.1s 800对应0.4s
%     if points(N)>150 && points(N)<800
%         step = 0;
%         while points(N+1)<5
%             N = N + 1;
%             step = step + 1;
%         end
%         if points(N+1)>150 && points(N+1)<800
%             tri = [tri, N - step];
%             N = N + 2;
%         % 按下两次trigger 和 三次trigger之后，2s之内不要再打任何trigger标记
%         % 4000代表设置了2s的阈值
%         elseif points(N+1) > 4000
%             bi = [bi, N - step];
%             N = N + 1;
%         else
%             error("点位差出现异常值, 请手动检查")
%         end
%     else
%         N = N + 1;
%     end
% end
% bi_set = neg_index(bi);
% tri_set = neg_index(tri);
% if length(bi_set) ~= length(tri_set)
%     error("biTrigger 与 triTrigger 元素数目不相等")
% end
% trialNum = length(bi_set);
% trial = cell(trialNum,1);

trialNum = length(startList);
for i = 1:trialNum
    trial{i} = sig(1:end-4,startList(i):endList(i));
end
trialInfo.dataSource = file_name;
        
end            
        

% 两次按下trigger的时间点差大概是400个点左右，这里设置阈值为300-800
% 寻找点位差为阈值范围里的值
% bi_set = find(points>300 && points<800);
% N = length(bi_set);
% bi = [bi, bi_set(1)];
% ind = 1;
% for i = 1:N
%     
% points_dup = points;
% points_dup(points<5) = [];
% tri_set = find(points_dup>300 && points_dup<800);
% N = [];
% for i = 1:lenght(tri_set)-1
%     d = tri_set(i+1)-tri_set(i);
%     if d == 1
%         N = [N, i];
%     end
% end


% 
% for i = 1 : length(neg_index)
%     if flag 
%         if neg_index(i) - neg_index(i-1) < 50
%             continue
%         
%     for j = 1 : lenght(pos_index)
%         points = pos_index(j) - neg_index(i);
%         % points设置为300个点，在采集频率为2000Hz下，这个值代表允许操作者有0.15s
%         % 的反应时间。一般连续两次点击trigger中间间隔时间应该不超过0.1s
%         % 如果出现两次trigger且中间间隔不超过0.15s，视为一次trial的开始
%         if points < 200 && points > 0
%             trialNum = trialNum + 1;
%             trig_time = [trig_time, neg_index(i)];
%             flag = 1;
%             

function dataType = matchIMUData(str)
ls = ["ax(g)","ay(g)","az(g)","wx(deg/s)","wy(deg/s)","wz(deg/s)","D2"];
for i = 1:length(ls)
    if strcmp(str,ls(i))
        dataType = i;
        return
    end
end
dataType = 0;
end
    
    


