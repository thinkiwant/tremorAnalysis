function [ISI, h] = calculateISI(mu, varargin)
% plot inter-spike interval histogram

fs = 2000;
mode = 0;   % mode ==0 :plot ISI separately
c='auto';
need_plot = false;
if(nargout ~= 1)
    need_plot = true;
end

IDR_low = 0;
ISI_up = 300;

for i = 1:2:length(varargin)
    switch varargin{i}
        case "mode"
            mode = varargin{i+1};
        case "color"
            c = varargin{i+1};
        case "low"
            IDR_low = varargin{i+1};
        case "up"
            IDR_up = varargin{i+1};
    end
end

binw = 10;
N = size(mu,2);

if(mode == 0)
    ISI = cell(N, 1);
    for i = 1:N
        cur_spike_id = find(mu(:, i)~=0);
        cur_ISI = diff(cur_spike_id)*(1000/fs);
        ISI{i}  = cur_ISI;
        if(need_plot)
            nexttile;
            h = plotISI(cur_ISI);
        end
    end
elseif(mode ==1)
    ISI = calculateISI(mu);
    ISI = cell2mat(ISI);
    h = plotISI(ISI);
elseif(mode == 2)
    if(~iscell(mu))
        error("please enter a valid cell");
    end
    t = length(mu);
    ISI = cell(t, 1);
    for i = 1:t
        if(isempty(mu{i}))
            continue;
        end
        ISI{i} = calculateISI(mu{i}, 'mode', 1);
    end
    ISI = cell2mat(ISI);
    h = plotISI(ISI);
end

    function [h] = plotISI(in_ISI)
        if(need_plot)
            h = histogram(in_ISI,'BinWidth',binw,'FaceAlpha',0.4 ,'FaceColor',c, 'Normalization','probability');
            xlim([0, ISI_up]);
            xticks(0:100:ISI_up)
        else
            h = [];
        end
    end
end
