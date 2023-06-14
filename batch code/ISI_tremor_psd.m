%% display ISI (inter-spike interval) of different muscles (position adjusted)
subjects_all = [3:5, 8, 10:13, 14, 15];
subjects_g1 = [3, 8, 11, 12];
subjects_g2 = [4, 5, 10, 13, 15];
subjects_g1 = [8, 11, 12, 15];
subjects_g2 = [3, 4, 5, 10, 13];
subjects = [subjects_g1, subjects_g2];
% subjects = subjects_all;
% subjects = subjects_g2;
% subjects = 3;
subjects = sort(subjects);
subjectN = length(subjects);

need_individual_plot = true;
need_ensemble = false;

RGBPre = cbrewer('seq', 'Greys', 5, 'linear');
RGBPost_off = cbrewer('seq', 'Reds', 5, 'linear');
RGBPost_on = cbrewer('seq', 'Blues', 5, 'linear');

c_i1 = 5; c_i2 = 3;
colors{1} = {RGBPre(c_i1, :), RGBPost_off(c_i1, :), RGBPost_on(c_i1, :)};
colors{2} = {RGBPre(c_i2, :), RGBPost_off(c_i2, :), RGBPost_on(c_i2, :)};

plot_column = 3;

threshold_lower = 3;
threshold_upper = 7;
conditions = [1, 2, 3]; % pre, post-ON, post-OFF
condition_map = [1, 3, 2];
conditionName = {"Pre", "Post-ON", "Post-OFF"};
conditionN = length(conditions);

tremor_ISI_proportion = nan(subjectN, 2, conditionN);

tremor_PSD_proportion = nan(subjectN, conditionN);

% declare bounding box of positions
posi_outter = [0.04, 0.04, 0.93, 0.96];
itv_condi = 0.03;
wid_condi = (1 - itv_condi  * conditionN*2)/conditionN;
posi_condi = {[itv_condi, 0, wid_condi, 1], [itv_condi*3+wid_condi, 0, wid_condi, 1], [itv_condi*5+wid_condi*2, 0, wid_condi, 1]};
posi_metric = {[0, 0.55, 1, 0.40],...
                %[0, 0.05, 1, 0.25],...
                [0, 0.06, 1, 0.3]};
posi_isi = {[0, 0, 0.4, 0.6], [0.6, 0, 0.4, 0.6]};

STTotal_flx = cell(1, 1);
STTotal_ext = cell(1, 1);

IMUTotal =cell(conditionN, 1);
Phase_diff_total = cell(conditionN, 1);

fs = 2000;
[b, a] = butter(1, 1/(fs/2), 'high');

trialTotal_i = [0, 0, 0];

for subject_i = 1:subjectN
    cur_subject = subjects(subject_i);
    intermuscular_phase_diff = cell(1, 3);
    if(need_individual_plot)
        figure
        has_ylabel_ISI = false;
        has_ylabel_PSD = false;
    end
    for condition_i = conditions
        ST = cell(1, 1);
        trialN = 0;
        IMU = [];
        cur_condi_posi = getInnerBoundingBox(posi_outter, posi_condi{condition_i});

        for trial_i = 1:30
            [data, M1, M2, M3, M4] = dataLoader(cur_subject, condition_map(condition_i), trial_i);
            [rows, cols] = size(data);

            if isempty(data)
                trialN = trial_i - 1;
                break
            end

            % extract MU data
            flx_st = [M1, M2];
            ext_st = [M3, M4];
            ST{1}{trial_i} = flx_st;
            ST{2}{trial_i} = ext_st;
            trialTotal_i(condition_i) = trialTotal_i(condition_i) + 1;
            STTotal_flx{condition_i}{trialTotal_i(condition_i)} = [M1, M2];
            STTotal_ext{condition_i}{trialTotal_i(condition_i)} = [M3, M4];

            % extract IMU data
            channelN = size(data, 2);
            cur_imu = data(:, (channelN-5):(channelN-3)) * 9.8;
            imu_max_dir = getTremorPower(cur_imu);
            IMU = [IMU; cur_imu(:, imu_max_dir)];

            % extract phase difference
            if (~isempty(flx_st) && ~isempty(ext_st))
                inst_phase_diff = InstPhaseFactory;
                cur_trial_phase_diff = inst_phase_diff.getTremorPhaseDiff(flx_st, ext_st, cur_imu);

                intermuscular_phase_diff{condition_i} = [intermuscular_phase_diff{condition_i}; cur_trial_phase_diff];
            end
        end
        if(need_individual_plot)
            if(trialN>0) % plot figures

                % ISI
                muscles = {"Flx", "Ext"};
                cur_isi_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{1});


                for muscle_i = 1 :2
                    cur_isi_muscle_posi = getInnerBoundingBox(cur_isi_posi, posi_isi{muscle_i});
                    % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column+muscle_i);
                    subplot("Position", cur_isi_muscle_posi);

                    [~, h] = calculateISI(ST{muscle_i}, 'mode', 2, 'color', colors{muscle_i}{condition_i});
                    hist_id = find(h.BinEdges>=150 & h.BinEdges<=250);
                    cur_tremor_ISI_proportion = sum(h.Values(hist_id));
                    tremor_ISI_proportion(subject_i, muscle_i, condition_i) = cur_tremor_ISI_proportion;

                    if(~has_ylabel_ISI && muscle_i == 1)
                        has_ylabel_ISI = true;
                        ylabel("Probability Density Function", "FontSize", 16)
                    end
                    set(gca, "FontSize", 14)
                    set(gca, "xla")

                    xlabel("Inter-spike Interval (ms)", "FontSize", 14)
                    title(sprintf("%s, %s\ntrial: %d, MU:%d\n tremor ISI p: %.2f",...
                        conditionName{condition_map(condition_i)}, muscles{muscle_i}, trialN, MU_count(ST{muscle_i}), cur_tremor_ISI_proportion), 'FontSize', 14);   
                end

                % tremor PSD
                cur_psd_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{2});
                if(condition_i == 1)
                    % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                    subplot('Position', cur_psd_posi);

                else
                    % y(condition_i-1) = subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                    y(condition_i-1) = subplot('Position', cur_psd_posi);

                end
                
                [m_id, P, pxx, f, f_low_id, f_up_id] = getTremorPower(IMU); 

                n = find(f<=30);
                freq_to_plot = f(n);
                pxx_to_plot = pxx(n);
                plot(freq_to_plot, pxx_to_plot, 'Color', colors{1}{condition_i}, 'LineWidth', 2.5);
                if(~has_ylabel_PSD)
                    ylabel("Power Spectrum Density", "FontSize", 16)
                    has_ylabel_PSD = true;
                end
                cur_tremor_proportion = P(m_id) / sum(pxx_to_plot);
                tremor_PSD_proportion(subject_i, condition_i) = cur_tremor_proportion;
                title(sprintf("Tremor proportion: %.2f", cur_tremor_proportion))
                idx_color = f_low_id:f_up_id;
                x_color = f(idx_color);
                x_color = [x_color; x_color(end); x_color(1)];
                y_color = pxx(idx_color);
                y_color = [y_color; 0; 0];
                hold on
                fill(x_color, y_color, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
                xlabel("Frequency (Hz)")
                xticks([0:5:30])
                set(gca, 'FontSize', 14)


                % plot phase difference
                % cur_phase_diff_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{3});
                % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + 2*conditionN*plot_column + [1:2])
                % subplot('Position', cur_phase_diff_posi);
                % polarhistogram(deg2rad(intermuscular_phase_diff{condition_i}), 18, 'FaceColor',colors{1}{condition_i},...
                %     'Normalization','probability');
                % title("Phase difference")
                % set(gca, 'FontSize', 14)


            end
        end
        IMUTotal{condition_i} = [IMUTotal{condition_i}; IMU];
        Phase_diff_total{condition_i} = [Phase_diff_total{condition_i}; intermuscular_phase_diff{condition_i}];
    end
    if(need_individual_plot)
        % linkaxes(y, 'y')
        sgtitle(sprintf("Subject %d", subject_i), 'FontSize', 20)
        set(gcf, 'Position', [300, 200, 1500, 670])
        saveas(gcf, sprintf("subject_new%d.svg", subject_i))
        %     close
    end
end

% ensemble
if(need_ensemble)
    figure
    has_ylabel_ISI = false;
    has_ylabel_PSD = false;
    for condition_i = conditions
        cur_condi_posi = getInnerBoundingBox(posi_outter, posi_condi{condition_i});
        if(trialN>0) % plot figures
            % ISI
            muscles = {"Flx", "Ext"};
            cur_isi_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{1});
            for muscle_i = 1 :2
                ST_var_name = {"STTotal_flx", "STTotal_ext"};
                eval(sprintf("cur_STTotal = %s;", ST_var_name{muscle_i}))
                % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column+muscle_i);
                cur_isi_muscle_posi = getInnerBoundingBox(cur_isi_posi, posi_isi{muscle_i});
                subplot("Position", cur_isi_muscle_posi);


                [~, h] = calculateISI(cur_STTotal{condition_i}, 'mode', 2, 'color', colors{muscle_i}{condition_i});
                hist_id = find(h.BinEdges>=150 & h.BinEdges<=250);
                cur_tremor_ISI_proportion = sum(h.Values(hist_id));
                if(~has_ylabel_ISI && muscle_i == 1)
                    has_ylabel_ISI = true;
                    ylabel("Probability Density Function", "FontSize", 16)
                end

                set(gca, "FontSize", 14)
                xlabel("Inter-spike Interval (ms)", "FontSize", 14)
                title(sprintf("%s, %s\ntrial: %d, MU:%d\n tremor ISI p: %.2f",...
                    conditionName{condition_map(condition_i)}, muscles{muscle_i},...
                length(cur_STTotal{condition_i}), MU_count(cur_STTotal{condition_i}), cur_tremor_ISI_proportion), 'FontSize', 14);
                
            end

            % tremor PSD
            cur_psd_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{2});
            if(condition_i == 1)
                % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                subplot('Position', cur_psd_posi);
            else
                % y(condition_i-1) = subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                y(condition_i-1) = subplot('Position', cur_psd_posi);
            end
            

            [m_id, P, pxx, f, f_low_id, f_up_id] = getTremorPower(IMUTotal{condition_i}); 
            n = find(f<=30);
            freq_to_plot = f(n);
            pxx_to_plot = pxx(n);
            plot(freq_to_plot, pxx_to_plot, 'Color', colors{1}{condition_i}, 'LineWidth', 2.5);
            if(~has_ylabel_PSD)
                ylabel("Power Spectrum Density", "FontSize", 16)
                has_ylabel_PSD = true;
            end
            cur_tremor_proportion = P(m_id) / sum(pxx_to_plot);
            title(sprintf("Tremor proportion: %.2f", cur_tremor_proportion))
            idx_color = f_low_id:f_up_id;
            x_color = f(idx_color);
            x_color = [x_color; x_color(end); x_color(1)];
            y_color = pxx(idx_color);
            y_color = [y_color; 0; 0];
            hold on
            fill(x_color, y_color, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
            xlabel("Frequency (Hz)")
            set(gca, 'FontSize', 14)
            xticks([0:5:30])

            % plot phase difference
            % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + 2*conditionN*plot_column + [1:2])
            % cur_phase_diff_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{3});
            % subplot('Position', cur_phase_diff_posi);
            % polarhistogram(deg2rad(Phase_diff_total{condition_i}), 18, 'FaceColor',colors{1}{condition_i},...
            %     'Normalization','probability')
            % title("Phase difference")
            % set(gca, 'FontSize', 14)
        end
        
    end
    % linkaxes(y, 'y')
    sgtitle(sprintf("Ensemble (group 2)"), 'FontSize', 20)
    % set(gcf, 'Position', [200, 200, 1800, 600])
    % set(gcf, 'Position', get(0, 'ScreenSize'))
    set(gcf, 'Position', [300, 200, 1500, 670])
    saveas(gcf, sprintf("Ensemble group 2.svg", subject_i))
end

%% display instantaneous phase difference
subjects_all = [3:5, 8, 10:13, 14, 15];
subjects_g1 = [3, 8, 11, 12];
subjects_g2 = [4, 5, 10, 13, 15];
subjects_g1 = [8, 11, 12, 15];
subjects_g2 = [3, 4, 5, 10, 13];
subjects = [subjects_g1, subjects_g2];
% subjects = subjects_all;
% subjects = subjects_g2;
% subjects = 3;
subjects = sort(subjects); 
subjectN = length(subjects);

need_individual_plot = true;
need_ensemble = false;

RGBPre = cbrewer('seq', 'Greys', 5, 'linear');
RGBPost_off = cbrewer('seq', 'Reds', 5, 'linear');
RGBPost_on = cbrewer('seq', 'Blues', 5, 'linear');

c_i1 = 5; c_i2 = 3;
colors{1} = {RGBPre(c_i1, :), RGBPost_off(c_i1, :), RGBPost_on(c_i1, :)};
colors{2} = {RGBPre(c_i2, :), RGBPost_off(c_i2, :), RGBPost_on(c_i2, :)};

plot_column = 3;

threshold_lower = 3;
threshold_upper = 7;
conditions = [1, 2, 3]; % pre, post-ON, post-OFF
condition_map = [1, 3, 2];
conditionName = {"Pre", "Post-ON", "Post-OFF"};
conditionN = length(conditions);

total_in_phase_p = ones(subjectN, conditionN) * NaN;
total_out_phase_p = ones(subjectN, conditionN) * NaN;
phase_diff_std = ones(subjectN, conditionN) * NaN;

cur_tremor_ISI_proportion = nan(subjectN, 2, conditionN);

tremor_PSD_proportion = nan(subjectN, conditionN);

% declare bounding box of positions
posi_outter = [0.04, 0.04, 0.93, 0.96];
itv_condi = 0.03;
wid_condi = (1 - itv_condi  * conditionN*2)/conditionN;
posi_condi = {[itv_condi, 0, wid_condi, 1], [itv_condi*3+wid_condi, 0, wid_condi, 1], [itv_condi*5+wid_condi*2, 0, wid_condi, 1]};
posi_metric = {[0, 0.55, 1, 0.40],...
                [0, 0.05, 1, 0.25],...
                [0, 0.06, 1, 0.3]};
posi_isi = {[0, 0, 0.4, 0.6], [0.6, 0, 0.4, 0.6]};

STTotal_flx = cell(1, 1);
STTotal_ext = cell(1, 1);

IMUTotal =cell(conditionN, 1);
Phase_diff_total = cell(conditionN, 1);

fs = 2000;
[b, a] = butter(1, 1/(fs/2), 'high');

trialTotal_i = [0, 0, 0];

for subject_i = 1:subjectN
    cur_subject = subjects(subject_i);
    intermuscular_phase_diff = cell(1, 3);
    if(need_individual_plot)
        figure
        has_ylabel_ISI = false;
        has_ylabel_PSD = false;
    end
    for condition_i = conditions
        ST = cell(1, 1);
        trialN = 0;
        IMU = [];
        cur_condi_posi = getInnerBoundingBox(posi_outter, posi_condi{condition_i});

        for trial_i = 1:30
            [data, M1, M2, M3, M4] = dataLoader(cur_subject, condition_map(condition_i), trial_i);
            [rows, cols] = size(data);
            if(rows<cols)
                data = data';
            end
            if isempty(data)
                trialN = trial_i - 1;
                break
            end

            % extract MU data
            flx_st = [M1, M2];
            ext_st = [M3, M4];
            ST{1}{trial_i} = flx_st;
            ST{2}{trial_i} = ext_st;
            trialTotal_i(condition_i) = trialTotal_i(condition_i) + 1;
            STTotal_flx{condition_i}{trialTotal_i(condition_i)} = [M1, M2];
            STTotal_ext{condition_i}{trialTotal_i(condition_i)} = [M3, M4];

            % extract IMU data
            channelN = size(data, 2);
            cur_imu = data(:, (channelN-5):(channelN-3)) * 9.8;
            imu_max_dir = getTremorPower(cur_imu);
            IMU = [IMU; cur_imu(:, imu_max_dir)];

            % extract phase difference
            if (~isempty(flx_st) && ~isempty(ext_st))
                inst_phase_diff = InstPhaseFactory;
                cur_trial_phase_diff = inst_phase_diff.getTremorPhaseDiff(flx_st, ext_st, cur_imu);

                intermuscular_phase_diff{condition_i} = [intermuscular_phase_diff{condition_i}; cur_trial_phase_diff];
            end
        end
        if(need_individual_plot)
            if(trialN>0) % plot figures

                % ISI
                muscles = {"Flx", "Ext"};
                cur_isi_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{1});


                for muscle_i = 1 :2
                    cur_isi_muscle_posi = getInnerBoundingBox(cur_isi_posi, posi_isi{muscle_i});
                    % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column+muscle_i);
                    subplot("Position", cur_isi_muscle_posi);

                    [~, h] = calculateISI(ST{muscle_i}, 'mode', 2, 'color', colors{muscle_i}{condition_i});
                    hist_id = find(h.BinEdges>=150 & h.BinEdges<=250);
                    cur_tremor_ISI_proportion = sum(h.Values(hist_id));
                    tremor_ISI_proportion(subject_i, muscle_i, condition_i) = cur_tremor_ISI_proportion;

                    if(~has_ylabel_ISI && muscle_i == 1)
                        has_ylabel_ISI = true;
                        ylabel("Probability Density Function", "FontSize", 16)
                    end
                    set(gca, "FontSize", 14)
                    set(gca, "xla")

                    xlabel("Inter-spike Interval (ms)", "FontSize", 14)
                    title(sprintf("%s, %s\ntrial: %d, MU:%d\n tremor ISI p: %.2f",...
                        conditionName{condition_map(condition_i)}, muscles{muscle_i}, trialN, MU_count(ST{muscle_i}), cur_tremor_ISI_proportion), 'FontSize', 14);   
                end

                % tremor PSD
                cur_psd_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{2});
                if(condition_i == 1)
                    % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                    subplot('Position', cur_psd_posi);

                else
                    % y(condition_i-1) = subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                    y(condition_i-1) = subplot('Position', cur_psd_posi);

                end
                
                [m_id, P, pxx, f, f_low_id, f_up_id] = getTremorPower(IMU); 

                n = find(f<=30);
                freq_to_plot = f(n);
                pxx_to_plot = pxx(n);
                plot(freq_to_plot, pxx_to_plot, 'Color', colors{1}{condition_i}, 'LineWidth', 2.5);
                if(~has_ylabel_PSD)
                    ylabel("Power Spectrum Density", "FontSize", 16)
                    has_ylabel_PSD = true;
                end
                cur_tremor_proportion = P(m_id) / sum(pxx_to_plot);
                tremor_PSD_proportion(subject_i, condition_i) = cur_tremor_proportion;
                title(sprintf("Tremor proportion: %.2f", cur_tremor_proportion))
                idx_color = f_low_id:f_up_id;
                x_color = f(idx_color);
                x_color = [x_color; x_color(end); x_color(1)];
                y_color = pxx(idx_color);
                y_color = [y_color; 0; 0];
                hold on
                fill(x_color, y_color, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
                xlabel("Frequency (Hz)")
                xticks([0:5:30])
                set(gca, 'FontSize', 14)


                % plot phase difference
                cur_phase_diff_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{3});
                subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + 2*conditionN*plot_column + [1:2])
                subplot('Position', cur_phase_diff_posi);
                p_h = polarhistogram(deg2rad(intermuscular_phase_diff{condition_i}), 18, 'FaceColor',colors{1}{condition_i},...
                    'Normalization','probability');
                title("Phase difference")
                set(gca, 'FontSize', 14)

                in_phase_id = [1:3, 16:18];
                out_phase_id = [7:12];
                in_phase_p = sum(p_h.Values(in_phase_id));
                out_phase_p = sum(p_h.Values(out_phase_id));

                fprintf("S%d condition %d, in_phase_p:%.1f, out_phase_p:%.1f\n", subject_i, condition_i, in_phase_p, out_phase_p);
                total_in_phase_p(subject_i, condition_i) = in_phase_p;
                total_out_phase_p(subject_i, condition_i) = out_phase_p;
                phase_diff_std(subject_i, condition_i) = std(p_h.Values);

            end
        end
        IMUTotal{condition_i} = [IMUTotal{condition_i}; IMU];
        Phase_diff_total{condition_i} = [Phase_diff_total{condition_i}; intermuscular_phase_diff{condition_i}];
    end
    if(need_individual_plot)
        % linkaxes(y, 'y')
        sgtitle(sprintf("Subject %d", subject_i), 'FontSize', 20)
        set(gcf, 'Position', [300, 200, 1500, 670])
        saveas(gcf, sprintf("subject_new%d.svg", subject_i))
        %     close
    end
end

% ensemble
if(need_ensemble)
    figure
    has_ylabel_ISI = false;
    has_ylabel_PSD = false;
    for condition_i = conditions
        cur_condi_posi = getInnerBoundingBox(posi_outter, posi_condi{condition_i});
        if(trialN>0) % plot figures
            % ISI
            muscles = {"Flx", "Ext"};
            cur_isi_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{1});
            for muscle_i = 1 :2
                ST_var_name = {"STTotal_flx", "STTotal_ext"};
                eval(sprintf("cur_STTotal = %s;", ST_var_name{muscle_i}))
                % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column+muscle_i);
                cur_isi_muscle_posi = getInnerBoundingBox(cur_isi_posi, posi_isi{muscle_i});
                subplot("Position", cur_isi_muscle_posi);


                [~, h] = calculateISI(cur_STTotal{condition_i}, 'mode', 2, 'color', colors{muscle_i}{condition_i});
                hist_id = find(h.BinEdges>=150 & h.BinEdges<=250);
                cur_tremor_ISI_proportion = sum(h.Values(hist_id));
                if(~has_ylabel_ISI && muscle_i == 1)
                    has_ylabel_ISI = true;
                    ylabel("Probability Density Function", "FontSize", 16)
                end

                set(gca, "FontSize", 14)
                xlabel("Inter-spike Interval (ms)", "FontSize", 14)
                title(sprintf("%s, %s\ntrial: %d, MU:%d\n tremor ISI p: %.2f",...
                    conditionName{condition_map(condition_i)}, muscles{muscle_i},...
                length(cur_STTotal{condition_i}), MU_count(cur_STTotal{condition_i}), cur_tremor_ISI_proportion), 'FontSize', 14);
                
            end

            % tremor PSD
            cur_psd_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{2});
            if(condition_i == 1)
                % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                subplot('Position', cur_psd_posi);
            else
                % y(condition_i-1) = subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + conditionN*plot_column + [1:2]);
                y(condition_i-1) = subplot('Position', cur_psd_posi);
            end
            

            [m_id, P, pxx, f, f_low_id, f_up_id] = getTremorPower(IMUTotal{condition_i}); 
            n = find(f<=30);
            freq_to_plot = f(n);
            pxx_to_plot = pxx(n);
            plot(freq_to_plot, pxx_to_plot, 'Color', colors{1}{condition_i}, 'LineWidth', 2.5);
            if(~has_ylabel_PSD)
                ylabel("Power Spectrum Density", "FontSize", 16)
                has_ylabel_PSD = true;
            end
            cur_tremor_proportion = P(m_id) / sum(pxx_to_plot);
            title(sprintf("Tremor proportion: %.2f", cur_tremor_proportion))
            idx_color = f_low_id:f_up_id;
            x_color = f(idx_color);
            x_color = [x_color; x_color(end); x_color(1)];
            y_color = pxx(idx_color);
            y_color = [y_color; 0; 0];
            hold on
            fill(x_color, y_color, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
            xlabel("Frequency (Hz)")
            set(gca, 'FontSize', 14)
            xticks([0:5:30])

            % plot phase difference
            % subplot(plot_column, conditionN*plot_column, (condition_i-1)*plot_column + 2*conditionN*plot_column + [1:2])
            % cur_phase_diff_posi = getInnerBoundingBox(cur_condi_posi, posi_metric{3});
            % subplot('Position', cur_phase_diff_posi);
            % polarhistogram(deg2rad(Phase_diff_total{condition_i}), 18, 'FaceColor',colors{1}{condition_i},...
            %     'Normalization','probability')
            % title("Phase difference")
            % set(gca, 'FontSize', 14)
        end
        
    end
    % linkaxes(y, 'y')
    sgtitle(sprintf("Ensemble (group 2)"), 'FontSize', 20)
    % set(gcf, 'Position', [200, 200, 1800, 600])
    % set(gcf, 'Position', get(0, 'ScreenSize'))
    set(gcf, 'Position', [300, 200, 1500, 670])
    saveas(gcf, sprintf("Ensemble group 2.svg", subject_i))
end

%%
function p = tremor_proportion(pxx, f)
threshold_lower = 3;
threshold_upper = 7;
idx = find(f>=threshold_lower & f<=threshold_upper);
p = sum(pxx(idx)) / sum(pxx);
end
%%
function N = MU_count(MU_cell)
N = 0;
for i = 1:length(MU_cell)
    N = N + size(MU_cell{i}, 2);
end
end