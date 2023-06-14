function phandler = plotSources(s,varargin)
    sil=[];
    fs = 2000;

    for i =1:2:length(varargin)
        switch varargin{i}
            case 'fs'
                fs = varargin{i+1};
            case 'SIL'
                sil = varargin{i+1};
        end 
    end

N = size(s,2);

for i=0:20:N
    hfig = figure;
    if N-i>=20
        for j=0:3
            for k =1:5
              subplot(5,4,j*5+k);
              id = i+j*5+k;
              source = s(:,id);
              t = 0:length(source)-1;
              t = t/fs;
              if sil(id)>0.8
                  c='b';
              elseif sil(id)>0.75
                  c='g';
              else
                  c='r';
              end
              f = plot(t,source,c);
              %xlabel('time / (s)');

              tstr = strcat(num2str(id));
              if ~isempty(sil)
                  tstr = strcat(tstr, " (", num2str(sil(id),'%.2f'),')');
              end
              title(tstr)
              set(gca, 'FontSize', 14)
              set(hfig, 'position', get(0,'ScreenSize'));
            end
        end
    elseif N-i >=10
        for j=i+1:N
            subplot(5,4,j-i)
            id = j;
            source = s(:,id);
            t = 0:length(source)-1;
            t = t/fs;

            if sil(id)>0.8
                c='b';
            elseif sil(id)>0.75
                c='g';
            else
                c='r';
            end
            f = plot(t,source,c);
            %xlabel('time / (s)');
            tstr = strcat(num2str(id));
            if ~isempty(sil)
                tstr = strcat(tstr, " (", num2str(sil(id),'%.2f'),')');
            end
            title(tstr)
            set(gca, 'FontSize', 14)
            set(hfig, 'position', get(0,'ScreenSize'));
        end
    else
        tiledlayout('flow');
        for j=i+1:N
            nexttile();
            id = j;
            source = s(:,id);
            t = 0:length(source)-1;
            t = t/fs;
            if sil(id)>0.8
                c='b';
            elseif sil(id)>0.75
                c='g';
            else
                c='r';
            end
            f = plot(t,source,c);
            %xlabel('time / (s)');
            tstr = strcat(num2str(id));
            if ~isempty(sil)
                tstr = strcat(tstr, " (", num2str(sil(id),'%.2f'),')');
            end
            title(tstr)
            set(gca, 'FontSize', 14)
            set(hfig, 'position', get(0,'ScreenSize'));
        end
    end
end
phandler = f;
end