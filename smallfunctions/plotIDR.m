function [h] = plotIDR(mu,varargin)
% plot instantaneous discharge rate
mode = 0;   % mode ==0 :plot IDR separately
c='auto';

IDR_low = 0;
IDR_up = 100;

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

binw = 1;
N = size(mu,2);

if(mode == 0)
    idr = calFirngRate(mu);
    for i = 1:N
        curIdr = idr(:,i);
        nexttile;
        h = histogram(curIdr(curIdr>0),'BinWidth',binw,'FaceAlpha',0.4 ,'FaceColor',c, 'Normalization','probability');
    end
elseif(mode ==1)
    idr = calFirngRate(mu);
    h = histogram(idr(idr>0),'BinWidth',binw,'FaceAlpha',0.3 ,'FaceColor',c, 'Normalization','probability');
elseif(mode == 2)
    if(~iscell(mu))
        error("please enter a valid cell");
    end
    t = length(mu);
    idr=[];
    for i = 1:t
        if(isempty(mu{i}))
            continue;
        end
        idr_trial = calFirngRate(mu{i});
        idr_trial = idr_trial(idr_trial>IDR_low & idr_trial<=IDR_up);
        idr=[idr; idr_trial];
    end
    hold on
    h = histogram(idr,'BinWidth',binw,'FaceAlpha',0.4 ,'FaceColor',c, 'Normalization','probability');
end

end