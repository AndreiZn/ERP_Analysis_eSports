function [latency_significance_matrix] = Return_significant_latencies(combined_results_output_folder, exp_id, p_threshold, latency_array)

amplitude_matrix = load([combined_results_output_folder, exp_id, '\amplitude_matrix.mat']); amplitude_matrix = amplitude_matrix.amplitude_matrix;
amplitude_matrix(8, :, :, :) = [];
%sub_list = {'sub0001', 'sub0002', 'sub0005', 'sub0006', 'sub0022', 'sub0023', 'sub0024', ...
%    'sub2008', 'sub2010', 'sub2011', 'sub2012', 'sub2013', 'sub2015', 'sub2016'};
expertise_idx_amp = [1,1,1,1,1,1,1, 2,2,2,2,2,2,2];
%sub_list(8)= [];
expertise_idx_amp(8) = [];

num_channels = size(amplitude_matrix, 2);
num_bins = size(amplitude_matrix, 3);
num_features = size(amplitude_matrix, 4);

latency_significance_matrix = zeros(num_channels, num_bins, num_features);

ch_names = {'Fp1', 'Fp2', 'AF3', 'AF4', 'F7', 'F3', 'Fz', 'F4', 'F8', 'FC5', 'FC1', 'FC2', 'FC6', ...
    'T7', 'C3', 'Cz', 'C4', 'T8', 'CP5', 'CP1', 'CP2', 'CP6', 'P7', 'P3', 'Pz', 'P4', 'P8', ...
    'PO7', 'PO3', 'PO4', 'PO8', 'Oz'};

% delete_sub_idx = [];
% for sub_idx = 1:numel(sub_list)
%     if sum(sum(sum(~isnan(squeeze(amplitude_matrix(sub_idx, :, :, :)))))) == 0
%         delete_sub_idx = [delete_sub_idx, sub_idx];
%     else
%         for ch_idx = 1:numel(ch_names)
%             if sum(sum(amplitude_matrix(sub_idx, ch_idx, :, :))) == 0
%                 delete_sub_idx = [delete_sub_idx, sub_idx];
%                 break;
%             end
%         end
%     end
% end



for ch_idx = 1:size(amplitude_matrix, 2)
    for bin_idx = 1:size(amplitude_matrix, 3)
        for feat_idx = 1:size(amplitude_matrix, 4)
            data = amplitude_matrix(:,ch_idx,bin_idx,feat_idx);
            [p_amp,tbl_amp,~] = anova1(data, expertise_idx_amp, 'off');
            f_amp = tbl_amp{2,5};
            if p_amp < p_threshold
                latency_significance_matrix(ch_idx, bin_idx, feat_idx) = 1;
                if bin_idx == 1
                    fprintf('ch = %s, bin = %s, latency = %s ms, p value: %.4f, f value: %.4f \n', ch_names{ch_idx}, num2str(bin_idx), num2str(latency_array(feat_idx)), p_amp, f_amp);
                end
            end
        end
    end
end
