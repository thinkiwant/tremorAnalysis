records = data;
s_ids = unique(records(:,1));
conditions = 1:3;
metrics_begin_cid = 4;
metrics_end_cid = size(records,2);
metrics_cids = metrics_begin_cid:metrics_end_cid;
metrics_ccount = metrics_end_cid - metrics_begin_cid + 1;
results = zeros(length(s_ids)*length(conditions), length(metrics_cids)+2);
cur_result_i = 1;
for s_id = s_ids'
    for condition = conditions
        c_ids = find(records(:,1)==s_id & records(:,2)==condition);
        acml = zeros(1,metrics_ccount);
        for c_id = c_ids'
            acml = acml + records(c_id, metrics_cids);
        end
        if(any(c_ids))
            cur_mean_metrics = acml/length(c_ids);
        end
        results(cur_result_i,:) = [s_id condition cur_mean_metrics];
        cur_result_i = cur_result_i + 1;
    end
end
