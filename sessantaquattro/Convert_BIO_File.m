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

NamePrefix='test';
emgFileid = [2:3]
imuFileid = [2:3]

for t = 1:length(emgFileid)
    eID = emgFileid(t);
    iID = imuFileid(t);
    
        tempPath = strcat(file_path,"\emg\a\",NamePrefix,"A*",".BIO");
        d = dir(tempPath);
        [device1,trialNum1] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device1,trialNum] = Open_sessa_bio_file('sig1.mat','sigFile',1);

        disp(2)
        tempPath = strcat(file_path,"\emg\b\",NamePrefix,"B*",".BIO");
        d = dir(tempPath);
        [device2,trialNum2] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device2,trialNum2] = Open_sessa_bio_file('sig2.mat','sigFile',1);
        
        disp(3)
        tempPath = strcat(file_path,"\emg\c\",NamePrefix,"C*",".BIO");
        d = dir(tempPath);
        [device3,trialNum3] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device3,trialNum3] = Open_sessa_bio_file('sig3.mat','sigFile',1);
        
        disp(4)
        tempPath = strcat(file_path,"\emg\d\",NamePrefix,"D*",".BIO");
        d = dir(tempPath);
        [device4,trialNum4] = Open_sessa_bio_file(strcat(d(eID).folder,'\',d(eID).name));
        %[device4,trialNum4] = Open_sessa_bio_file('sig4.mat','sigFile',1);%Use trigger channel of Module 3 to rectify Module 4

        % To determine the # of trials in this session

        if trialNum1 == trialNum2 && trialNum2 == trialNum3 && trialNum3 == trialNum4
            disp('trial numbers match with each other');
        else
            warning('trial numbers do not match');
        end       
        
        trialNum = min([trialNum1,trialNum2,trialNum3,trialNum4]);
        MInitTrial=[];
        for i = 1:4
            MInitTrial(i) = eval(sprintf("trialNum%d - trialNum",i));
        end 
        
        % if IMU is available then interpolate new data into imu
        if imu_available == 1
                %imu = loadIMUdata(strcat(imu_file(iID).folder,"\",NamePrefix,imu_file(iID).name));
                imu = loadIMUdata(strcat(file_path,"\imu\",NamePrefix,num2str(iID),".txt"));
            disp(5)
            [sL_imu,eL_imu,~,~] = findInterval(imu(:,end),200);% Fs of IMU is 200 set as deault.
        end            

        eval(strcat("experiment",num2str(emgFileid(t)),"=cell(trialNum,1);"));
        itpIMU = cell(trialNum,1);
        for j = 1:trialNum
            j
            dataLength = min([length(device1{j+MInitTrial(1)}),
                length(device2{j+MInitTrial(2)}),
                length(device3{j+MInitTrial(3)}),
                length(device4{j+MInitTrial(4)})]);
            if imu_available == 1
                id = sL_imu(j):(eL_imu(j)-sL_imu(j))/(dataLength-1):eL_imu(j);
                %itpIMU{j} = interp1(sL_imu(j):eL_imu(j),imu(sL_imu(j):eL_imu(j),1:end-1),id,'linear');
                itpIMU{j} = interp1(sL_imu(j):eL_imu(j),imu(sL_imu(j):eL_imu(j),1:end-1),id,'spline');

                disp(dataLength)
                disp(length(itpIMU))
            end

            eval(strcat("experiment",num2str(emgFileid(t)),"{j} = [device1{j+MInitTrial(1)}(:,1:dataLength);",...
                "device2{j+MInitTrial(2)}(:,1:dataLength);device3{j+MInitTrial(3)}(:,1:dataLength);device4{j+MInitTrial(4)}(:,1:dataLength);itpIMU{j}'];"));

            whos device1

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
    length(trigger)
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