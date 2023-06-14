subjects=[3,4,6:8,10:13];
datapath = "D:\experimentdata\PD-DBS\sub";
phasepath = ["pre", "post\on", "post\off"];

% colum name
items = [ "subject_id", "phase_id", "trial_id", "tremor_intensity",... % 4
    "mu_flx", "mu_ext",... % 6
    "coher_single_flx", "coher_single_ext",... % 8
    "coher_single_inter", "coher_double_flx",... % 10
    "coher_double_ext", "coher_double_inter"]; % 12

trail_n = 0;
for s = 1:length(subjects)  %traverse to count trials
    for phase = 1:length(phasepath)
        curpath = sprintf("%s%d\\%s\\mu\\spiketrain", datapath, subjects(s), phasepath(phase));
        path = sprintf("%s\\*Session*",curpath);
        files = dir(path);
        if(~isempty(files))
            fprintf("%s : %d\n",path, length(files));
            for fi = 1:length(files)    % trial
                trial_n = trail_n+1;
            end
        end
    end
end


data = ones(trail_n, length(items))*(-1);

cur_trail = 1;
        
for s = 1:length(subjects)  %traverse to calculate indices
    for phase = 1:length(phasepath)
        curpath = sprintf("%s%d\\%s\\mu\\spiketrain", datapath, subjects(s), phasepath(phase));
        path = sprintf("%s\\*Session*",curpath);
        files = dir(path);
        if(~isempty(files))
            fprintf("\nsubject %d:\n",subjects(s));
            for fi = 1:length(files)    % trial
                fprintf("%d ", fi);
                load(sprintf("%s\\%s",curpath, files(fi).name));
                data(cur_trail, 1) = subjects(s);
                data(cur_trail, 2) = phase;
                data(cur_trail, 3) = fi;
                
                if(exist('rawData'))
                    col = size(rawData,2);
                    [id,tremor_intensity] = findMaxVar(rawData(:,end-5:end-3));
                    data(cur_trail, 4) = tremor_intensity(id);
                end
                    
                
                mu_flx = [M1, M2];
                mu_ext = [M3, M4];
                data(cur_trail, 5) = size(mu_flx,2);
                data(cur_trail, 6) = size(mu_ext,2);
                
                if(size(mu_flx,2) >= 3)
                    coher_flx = calCoherLong(mu_flx);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_flx);
                    data(cur_trail, 7) = c1;
                    data(cur_trail, 10) = c2;
                end
                if(size(mu_ext,2) >= 3)
                    coher_ext = calCoherLong(mu_ext);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_ext);
                    data(cur_trail, 8) = c1;
                    data(cur_trail, 11) = c2;
                end
                if(size(mu_flx,2) >= 3 && size(mu_ext,2) >= 3)
                    coher_inter = calCoherLong(mu_flx, mu_ext);
                    [c1,~,c2,~] = calMeanPeakCoher(coher_inter);
                    data(cur_trail, 9) = c1;
                    data(cur_trail, 12) = c2;
                end
                
                cur_trail = cur_trail+1;
                clear rawData;
                
            end
        end
    end
end
fprintf("\n");
msgbox("over");
writematrix(items,'data_mean_w1.txt');
writematrix(data,'data_mean_w1.txt','WriteMode','append');