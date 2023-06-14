
chanList = [[0,64,128,192]+27,259,260]; % 4 channels locating in the central position and az, wx

tiledlayout('flow')


for i = 5:6
data = experiment1{i};

nexttile
checkSignal(data(chanList,:)');
legend({'M1','M2','M3','M4','az','wx'},'FontSize',14)
title(strcat("Extension ",num2str(i-4)))
end
% 
% lgd = 
% lgd.Layout.Tile  = 3