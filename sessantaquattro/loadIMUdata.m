function ImuData = loadIMUdata(filePath)
% The input argment should be the path of the imu data.

imu = importdata(filePath);
columnName = imu.textdata(1,:);
matchResult = cellfun(@(x) matchIMUData(x),columnName);
columnId = find(matchResult);
disp(columnId)
ImuData = imu.data(:,columnId);


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
    