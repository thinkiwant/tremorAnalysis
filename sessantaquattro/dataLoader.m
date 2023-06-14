function [out_raw_data, out_M1, out_M2, out_M3, out_M4] = dataLoader(subjectID, condition, trialID)
% subjectID: the original ID of subjects. condition: 1 for pre; 2 for
% post-ON; 3 for post-OFF. trialID is the index of the trial in its
% directory.
%   此处显示详细说明
out_raw_data = [];
out_M1 = [];
out_M2 = [];
out_M3 = [];
out_M4 = [];

subjectDataPath = "D:\experimentdata\PD-DBS\sub";
conditions = ["pre", "post\on", "post\off"];

curpath = sprintf("%s%d\\%s\\mu\\spiketrain", subjectDataPath, subjectID, conditions(condition));
path = sprintf("%s\\*Session*",curpath);
files = dir(path);

if(isempty(files))
    warning("invalid file path: %s\n", path);
end

if trialID > length(files)
    warning("trial ID is beyond the scope of valid trials");
else
    cur_file = files(trialID).folder + "\" + files(trialID).name;
    load(cur_file)
    [r, c] = size(rawData);

    if(r >= c)
        out_raw_data = rawData;
    else
        out_raw_data = rawData';
        [c, r] = size(rawData);
    end

    ls = 0:64:c;
    out_raw_data(:, ls(end)+[1:3]) = out_raw_data(:, ls(end)+[1:3]) * 9.8;

    if(subjectID == 3)
    out_M1 = M3;
    out_M2 = M1;
    out_M3 = M2;
    out_M4 = M4;
    else
    out_M1 = M1;
    out_M2 = M2;
    out_M3 = M3;
    out_M4 = M4;
    end

end


end
