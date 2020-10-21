function analyze_ERP_features(CFG, ERP_features, ERP_combined)

% channels and datasets to analyze
ch_ids = CFG.ch_idx; 
exp_IDs = CFG.exp_IDs; num_exps = numel(exp_IDs);
% bins
bins = CFG.bins;
% one of the ERPs
%ERP_exmp = ERP_combined(end);
% get channel labels
%lbls = {ERP_exmp.chanlocs.labels};

max_coef = 0;

for exp_idx = 1:num_exps
    exp_id_cur = exp_IDs(exp_idx);
    
        for ch_idx = ch_ids
            %ch_lbl = lbls{ch_idx};
            
            for bin_idx = bins
                
                exp_feat_idx = strcmp(ERP_features.t_exp_id, exp_id_cur);
                ch_feat_idx = ERP_features.t_ch_idx == ch_idx;
                bin_feat_idx = ERP_features.t_bin == bin_idx;
                pro_group_idx = ERP_features.t_sub_group == 1;
                npro_group_idx = ERP_features.t_sub_group == 0;
                
                feat_idx = logical(exp_feat_idx.*ch_feat_idx);
                feat_idx = logical(feat_idx.*bin_feat_idx);
                feat_idx_pro = logical(feat_idx.*pro_group_idx);
                feat_idx_npro = logical(feat_idx.*npro_group_idx);
               
                ERP_features_pro = ERP_features(feat_idx_pro, :);
                ERP_features_npro = ERP_features(feat_idx_npro, :);
                
                feat_pro = ERP_features_pro.t_tp_g_mean;
                feat_npro = ERP_features_npro.t_tp_g_mean;
                
                coef = 0;
                for np_sub_idx = 1:size(ERP_features_npro,1)
                    % find num of points where pro has a greater feature
                    % value
                    coef = coef + sum(feat_pro > feat_npro(np_sub_idx));
                end
                % normalize the coefficients
                total_num_comp = size(ERP_features_pro,1) * size(ERP_features_npro,1);
                coef = coef / total_num_comp;
                if coef < 0.5
                    coef = 1 - coef;
                end
                
                if coef > max_coef
                    max_coef = coef;
                end
                
                if coef > 0.8
                    sprintf('exp: %s, ch: %d, bin: %d, coef = %.2f', exp_id_cur{1}, ch_idx, bin_idx, coef)
                    exp_id_idx = strcmp({ERP_combined.exp_id}, exp_id_cur);
                    ERPs_cur = ERP_combined(exp_id_idx);
                    plot_ERPs_in_column(ERPs_cur, ch_idx, bin_idx);
                    [p,~,~] = ranksum(feat_pro, feat_npro);
                    sprintf('p-value: %.4f', p)
                end
            end
        end
end
  