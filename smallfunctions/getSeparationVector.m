function [SPvector] = getSeparationVector(subjectID, filename, MUid)
% return the separation vectors of assigned data.
% filename is formed like "M1Off1ByM1On5.mat", and source files are placed
% at D:\experimentdata\PD-DBS\sub#\trace\ directory

m = regexpi(filename,'(?<=ByM)\d+','match');    %get module/muscle
m = str2num(m{1});
cond = regexpi(filename,'(?<=ByM\d+)\D+','match');  %get condition of vectors (on/off)
cond = cond{1};
fileid = regexpi(filename,'(?<=ByM\d+\D*)\d+','match');
fileid = str2num(fileid{1});
filepath = sprintf("D:\\experimentdata\\PD-DBS\\sub%d\\trace",subjectID);
temp = strcat(filepath,sprintf("\\Sub%dPost%s*",subjectID, cond))
files = dir(temp);
sourceName = files(fileid).name;
load(strcat(filepath,"\\", sourceName),sprintf("M%d",m));
eval(sprintf("SIL = M%d{1};",m));
eval(sprintf("GoodIndex = M%d{5};",m));
eval(sprintf("B = M%d{4};",m));

threshold = 0.75;
id = GoodIndex(find(SIL>=threshold));
id = id(MUid);
SPvector = B(:,id);
end