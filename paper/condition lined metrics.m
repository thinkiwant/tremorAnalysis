close all

condition_metric = total_out_phase_p;
condition_metric = phase_diff_std;
% condition_metric = tremor_ISI_proportion_flx;
% condition_metric = tremor_ISI_proportion_ext;

conditions = 1:3;
colors = {'r', 'b', 'g'};
RGBPre = cbrewer('seq', 'Greys', 5, 'linear');
RGBPost_off = cbrewer('seq', 'Reds', 5, 'linear');
RGBPost_on = cbrewer('seq', 'Blues', 5, 'linear');

c_i1 = 5; c_i2 = 3;
colors{1} = {RGBPre(c_i1, :), RGBPost_off(c_i1, :), RGBPost_on(c_i1, :)};
marker = {"o", "+", "*", "square", "diamond", "pentagram", "^", "v", "hexagram"};
hold on
subjectN = length(condition_metric(:, 1));
one = ones(size(condition_metric(:,1)));
for condition_i = conditions
    for subject_i = 1:subjectN
        plot(condition_i, condition_metric(subject_i, condition_i),"Color", colors{1}{condition_i},'LineWidth', 1.5,'MarkerSize', 8, 'Marker', marker{subject_i}, 'LineStyle','none');
    end
end

valid_id1 = ~isnan(condition_metric(:, 1));
valid_id2 = ~isnan(condition_metric(:, 2));
valid_id3 = ~isnan(condition_metric(:, 3));

for i = find(valid_id1 & valid_id2)
    plot([1 2], [condition_metric(i, 1), condition_metric(i, 2)], 'Color', 'k', 'LineWidth', 0.8)
end

for i = find(valid_id2 & valid_id3)
    plot([2 3], [condition_metric(i, 2), condition_metric(i, 3)], 'Color', 'k', 'LineWidth', 0.8)
end

legend("S"+[[1:subjectN-1], 10], 'Location', 'eastoutside', 'FontSize', 16)
xticks([1, 2, 3])
xticklabels(["Pre", "Post-OFF", "Post-ON"])
yticks([0.0:0.1:1])
% ylim([0.35 1.1])
xlim([0.5, 3.5])
set(gcf, 'Position', [800 300 600 600])
set(gca, 'FontSize', 20)