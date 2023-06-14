function sign = Convert_BIO_File_new(file_path,destiny_dir)
%对数据文件进行合并（自动根据trigger通道来从session中划分trial，之后对四个模块各自的trial对应地进行拼接，使用时要保证trigger通道信号有效）
% convert bio file to .mat file or .csv file
if nargin == 1
    destiny_dir = "C:\Users\admin\Desktop\";    %合并数据生成的目录，默认在桌面
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
%imu_file = dir(strcat(file_path,'\imu\*','.txt'));  % imu文件的目录
% 寻找文件数字开始
imu_available = 1;
%是否有IMU数据 1有 0无
fs = 2e3;
NamePrefix='rest';  %要合并的文件的前缀名,如对“resta.bio”、“restb.bio”等文件进行合并则设置为“rest”
%使用时文件目录应如下所示
%   ~/file
%         |----/emg
%         |     |-------/a
%         |     |       |----resta001.bio
%         |     |
%         |     |-------/b
%         |     |       |----restb001.bio
%         |     |
%         |     |-------/c
%         |     |       |----restc001.bio
%         |     |
%         |     |-------/d
%         |             |----restd001.bio
%         |
%         |----/imu
%                 |------rest001.txt

emgFileid = [4];   %要合并的emg文件的编号
%如:在\emg\a\
%           |------resta2.bio
%           |------resta4.bio
%           |------resta6.bio
%上述的目录和文件结构下，取编号[1,3]则只会对resta2.bio和resta6.bio分别进行合并

imuFileid = [4];   %同上

emg_modules_all = 1:4;  % all modules are integrated in shape
emg_modules = [1,3,4];  % real modules from which data are to be intergrated
emg_module_tag = ["A","B","C","D"];

if(length(emgFileid)~=length(imuFileid))
    error("unequal ID numbers!")
end
for t = 1:length(emgFileid)
    fprintf("processing %dth %s data\n", t, NamePrefix);
    eID = emgFileid(t);
    iID = imuFileid(t);
    
    lastTrialNum = -1;
    for m = emg_modules
        fprintf("loading EMG data of module %d\n", m);
        tempPath = strcat(file_path,"\emg\",lower(emg_module_tag(m)),"\",NamePrefix,emg_module_tag(m),"*",".BIO");
        d = dir(tempPath);
        loadFile = sprintf("%s\\%s",d(eID).folder, d(eID).name);
        cmd = sprintf("[device%d,trialNum%d] = Open_sessa_bio_file(loadFile);", m, m);
        eval(cmd);
        eval(sprintf("curTrialNum = trialNum%d;",m));
        if(lastTrialNum==-1)
            lastTrialNum = curTrialNum;
        elseif(lastTrialNum~=curTrialNum)
            error("unmatched trial numbers: current trial number=%d, previous trial number=%d\n", curTrialNum, lastTrialNum);
        end
    end
    
    trialNum = lastTrialNum;
    
    % if IMU is available then interpolate new data into imu
    if imu_available == 1
        %imu = loadIMUdata(strcat(imu_file(iID).folder,"\",NamePrefix,imu_file(iID).name));
        imuPath = strcat(file_path,"\imu\",NamePrefix,"*",".txt");
        d = dir(imuPath);
        imuFile = sprintf("%s\\%s",d(iID).folder, d(iID).name);
        imu = loadIMUdata(imuFile);
        fprintf("loading IMU date\n");
        [sL_imu,eL_imu,~,~] = findInterval(imu(:,end),200);% Fs of IMU is 200 set as deault.
    end
    
    eval(strcat("experiment",num2str(emgFileid(t)),"=cell(trialNum,1);"));
    itpIMU = cell(trialNum,1);
    
    for trial_i = 1:trialNum
        
        dataLength = 1e10;
        for m = emg_modules
            
            eval(sprintf("curLength = length(device%d{%d});", m, trial_i));
            dataLengthDiff = abs(dataLength-curLength);
            if(dataLength<1e10 && dataLengthDiff>10*(fs/1000))
                error("dataLength difference is huge: %f ms (trial %d, module %d)", abs(dataLength-curLength),trial_i, m);
            end
            dataLength = min(dataLength, curLength);
        end
        
        targetFileName = sprintf("experiment%d{%d}", emgFileid(t), trial_i);
        eval(sprintf("%s=[];", targetFileName));
        
        eval(sprintf("[r, c] = size(device%d{%d});", emg_modules(1), trial_i));
        for m = emg_modules_all
            if(any(emg_modules==m))
                eval(sprintf("%s = [%s,device%d{%d}(:,1:dataLength)'];", targetFileName, targetFileName, m, trial_i));
            else
                eval(sprintf("%s = [%s,zeros(r, dataLength)'];", targetFileName, targetFileName));
            end
        end
        
        if imu_available == 1
            id = sL_imu(trial_i):(eL_imu(trial_i)-sL_imu(trial_i))/(dataLength-1):eL_imu(trial_i);
            %itpIMU{j} = interp1(sL_imu(j):eL_imu(j),imu(sL_imu(j):eL_imu(j),1:end-1),id,'linear');
            itpIMU{trial_i} = interp1(sL_imu(trial_i):eL_imu(trial_i),imu(sL_imu(trial_i):eL_imu(trial_i),1:end-1),id,'spline');
            eval(sprintf("%s = [%s itpIMU{%d}];", targetFileName, targetFileName, trial_i));
        end
        
    end
    
    fileTag = strcat(destiny_dir,"\",NamePrefix,num2str(emgFileid(t)),".mat");
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
    length(trigger);
    disp("trigger rectified.")
    [startList , endList, ~, ~] = findInterval(trigger)
end


trialNum = length(startList);
for i = 1:trialNum
    trial{i} = sig(1:end-4,startList(i):endList(i));
end
trialInfo.dataSource = file_name;

end


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