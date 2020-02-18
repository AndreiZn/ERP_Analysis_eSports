function [ERP_feat] = calculate_ERP_features(CFG, ERP_combined)

% channels and datasets to analyze
ch_ids = CFG.ch_idx; num_chs = numel(ch_ids);
exp_IDs = CFG.exp_IDs; num_exps = numel(exp_IDs);
% bins
bins = CFG.bins;
% one of the ERPs
ERP_exmp = ERP_combined(end);
% get channel labels
lbls = {ERP_exmp.chanlocs.labels};

% number of lines in the table of ERP features (a feature is calculated for
% each experiment, subject, channel and bin)
num_t_lines = num_exps * num_chs * CFG.num_subjects * numel(bins);
% table columns
t_exp_id = cell(num_t_lines,1);
t_sub_group = zeros(num_t_lines,1);
t_sub_id =  cell(num_t_lines,1);
t_ch_idx = zeros(num_t_lines,1);
t_ch_lbl = cell(num_t_lines,1);
t_bin = zeros(num_t_lines,1);
t_max_amp = zeros(num_t_lines,1);
t_max_amp_latency = zeros(num_t_lines,1);

t_idx = 1;


for exp_idx = 1:num_exps
    exp_id_cur = exp_IDs(exp_idx);
    ERP_idx = find(contains({ERP_combined.exp_id},exp_id_cur));

    for dst_i = 1:numel(ERP_idx)
        dst_idx = ERP_idx(dst_i);
        ERP_cur = ERP_combined(dst_idx);
        sub_id = ERP_cur.subject;
        
        for ch_idx = ch_ids
            ch_lbl = lbls{ch_idx};
            
            for bin_idx = 1:numel(bins)
                bin = bins(bin_idx);
                bin_data = squeeze(ERP_cur.bindata(ch_idx, :, bin));
                [max_amp, max_amp_idx] = max(bin_data,[],2);
                max_amp_latency = ERP_cur.times(max_amp_idx);
                
                % record calculated values
                t_exp_id(t_idx,1) = exp_id_cur;
                t_sub_group(t_idx,1) = ERP_cur.pro;
                t_sub_id(t_idx,1) = {sub_id};
                t_ch_idx(t_idx,1) = ch_idx;
                t_ch_lbl(t_idx,1) = {ch_lbl};
                t_bin(t_idx,1) = bin;
                t_max_amp(t_idx,1) = max_amp;
                t_max_amp_latency(t_idx,1) = max_amp_latency;
                t_idx = t_idx + 1;
            end
        end
    end
end

ERP_feat = table(t_exp_id,t_sub_group,t_sub_id,t_ch_idx,t_ch_lbl,t_bin,t_max_amp,t_max_amp_latency);
