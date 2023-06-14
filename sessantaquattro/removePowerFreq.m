function dataFiltered = removePowerFreq(data,fs)

if nargin == 1
    fs = 2000
end

EMG_BSpf = Filter(data,fs, "BandStop",50);
for i = 2:7
    EMG_BSpf = Filter(EMG_BSpf,fs,"BandStop", 50*i);
end

dataFiltered = EMG_BSpf;
end

