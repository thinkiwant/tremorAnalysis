function [Fr] = CalMeanFiringRate(musp, fs)
if size(musp,2) ~= 1
    error('input should be a 1 column array');
end

samplingRate = 2000;

if nargin == 2
    samplingRate = fs;
end
firingPoint = find(musp);
l = firingPoint(end)-firingPoint(1);
f = length(find(musp));
interval = l/f;
Fr = samplingRate / interval;
end