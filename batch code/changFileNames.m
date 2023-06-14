subjects = [14, 15];
conditions = ["Pre", "Post"];
file_path = 'C:\Users\admin\Desktop\14&15 subject data\数据整合\';
i = 0;
for subject = subjects
    for condition = conditions
        cd(file_path);
        dir_files = dir(sprintf("%sMU_S%d%s*",file_path, subject, condition));
        for id = 1:length(dir_files)
            dir_file = dir_files(id);
            old_name = dir_file.name;
            session_str = regexp(old_name, "Se[0-9]{1,10}", 'match');
            session_str = session_str{1};
            session_num = session_str(isstrprop(session_str, 'digit'));
            trial_str = regexp(old_name, "Tri[0-9]{1,1}", 'match');
            trial_str = trial_str{1};
            trial_num = trial_str(isstrprop(trial_str, 'digit'));
            if condition == "Pre"
                sub_cond = "";
            else
                post_cond = regexp(old_name, "frst", 'match');
                if(isempty(post_cond))
                    sub_cond = "On";
                else
                    sub_cond = "Off";
                end
            end 
            new_name = sprintf("sub%d%s%sRestingSession%sTrial%spart1.mat", subject, condition, sub_cond, session_num, trial_num);
            fprintf("%s --> %s\n", old_name, new_name);
            i = i+1;
            eval(sprintf("!rename %s %s", old_name, new_name));
        end
    end
end
i