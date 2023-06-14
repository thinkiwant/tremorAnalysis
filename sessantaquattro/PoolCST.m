function [CST] = PoolCST(SpikeTrains,pt)
if nargin ~= 1
[r,c] = size(SpikeTrains);
l = max(r,c);
n = min(r,c);
if c>r
    SpikeTrains = SpikeTrains';
end
CST = zeros(l,1);
for i = 1:n
    CST = CST|SpikeTrains(:,i);
    ax(i) = subplot(n+1,1,i);
    plot(SpikeTrains(:,i));
    ylim([-1,2]);
end

ax(n+1) = subplot(n+1,1,n+1);
plot(CST);
ylim([-1,2]);
linkaxes(ax,'x');

else
    [r,c] = size(SpikeTrains);
l = max(r,c);
n = min(r,c);
if c>r
    SpikeTrains = SpikeTrains';
end
CST = zeros(l,1);
for i = 1:n
    CST = CST|SpikeTrains(:,i);
end

CST = double(CST);

end
end


