function [amp_matrix] = Compute_neural_latencies(ERP, indelec, n_features, latency_array, n_chs, total_num_chs)

amp_matrix = zeros(total_num_chs, 2, n_features);

for feat_idx = 1:n_features
    latency = latency_array(feat_idx);
    [ERP_MEASURES, ~] = geterpvalues(ERP,  latency, [ 1 2],  1:n_chs, 'instabl');
    
    cur_ch_idx = 1;
    for ch_idx = 1:total_num_chs
        if ~ismember(ch_idx, indelec)
            amp_matrix(ch_idx, :, feat_idx) = ERP_MEASURES(:, cur_ch_idx);
            cur_ch_idx = cur_ch_idx + 1;
        else
            amp_matrix(ch_idx, :, feat_idx) = NaN;
        end
    end
end

