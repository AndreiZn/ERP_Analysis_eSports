disk_prefix = 'K';
combined_results_output_folder = [disk_prefix, ':\EEG_Experiments\EEGLAB_Combined_res_for_pro_npro\'];
data_folders = dir(combined_results_output_folder); data_folders = data_folders(3:end);
num_exps = size(data_folders,1);

p_threshold = 0.1;

for exp_idx = 1:num_exps
    folder_struct = data_folders(exp_idx);
    folder_name = folder_struct.name;
    sub_folder_path = [folder_struct.folder, '\', folder_name, '\'];
    exp_id = folder_name;
    neural_corr = load([sub_folder_path, 'neural_corr.mat']); neural_corr = neural_corr.neural_corr;
    isSix = cellfun(@(x)isequal(x,'2008'),neural_corr);
    [row,~] = find(isSix);
    if ~isempty(row)
        neural_corr(row,:) = [];
    end
    
    num_subs = size(neural_corr, 1);
    neural_corr_mat = NaN(size(neural_corr, 1), size(neural_corr, 2)-1);
    expertise_idx = NaN(size(neural_corr, 1),1);
    del_idx = [];
    
    for i = 1:num_subs
        for j = 2:size(neural_corr, 2)
            if isempty(neural_corr{i,1})
                del_idx = [del_idx, i];
                break;
            else
                neural_corr_mat(i,j-1) = neural_corr{i,j};
            end
        end
        if ~isempty(neural_corr{i,1})
            subId = neural_corr{i,1};
            if str2double(subId) > 2000
                expertise_idx(i) = 2;
            elseif str2double(subId) > 0 && str2double(subId) < 1000
                expertise_idx(i) = 1;
            end
        end
    end
    
    neural_corr(del_idx,:) = [];
    neural_corr_mat(del_idx,:) = [];
    expertise_idx(del_idx,:) = [];
    num_subs = num_subs - numel(del_idx);
    
    mental_conc = neural_corr_mat(:,1);
    visuospatial_att = neural_corr_mat(:,2);
    emotion_state = neural_corr_mat(:,3);
    [p_m,tbl_m,stats_m] = anova1(mental_conc, expertise_idx, 'off');
    [p_v,tbl_v,stats_v] = anova1(visuospatial_att, expertise_idx, 'off');
    [p_e,tbl_e,stats_e] = anova1(emotion_state, expertise_idx, 'off');
    if p_m < p_threshold || p_v < p_threshold || p_e < p_threshold
        sprintf(['Exp-', exp_id])
        if p_m < p_threshold
            sprintf('Mental concentration, p value: %.4f', p_m)
        elseif p_v < p_threshold
            sprintf('Visuospatial attention, p value: %.4f', p_v)
        elseif p_e < p_threshold
            sprintf('Emotion state, p value: %.4f', p_e)
        end
    end
end

%% Amplitude comparison

ch_names = {'Fp1', 'Fp2', 'AF3', 'AF4', 'F7', 'F3', 'Fz', 'F4', 'F8', 'FC5', 'FC1', 'FC2', 'FC6', ...
    'T7', 'C3', 'Cz', 'C4', 'T8', 'CP5', 'CP1', 'CP2', 'CP6', 'P7', 'P3', 'Pz', 'P4', 'P8', ...
    'PO7', 'PO3', 'PO4', 'PO8', 'Oz'};

disk_prefix = 'K';
combined_results_output_folder = [disk_prefix, ':\EEG_Experiments\EEGLAB_Combined_res_for_pro_npro\'];
data_folders = dir(combined_results_output_folder); data_folders = data_folders(3:end);
num_exps = size(data_folders,1);

p_threshold = 0.01;


for exp_idx = 1:num_exps
    
    sub_list = {'sub0001', 'sub0002', 'sub0005', 'sub0006', 'sub0022', 'sub0023', 'sub0024', ...
        'sub2008', 'sub2010', 'sub2011', 'sub2012', 'sub2013', 'sub2015'};
    
    feat_names = {'N100', 'N170', 'P200', 'P300', 'P400'};
    expertise_idx_amp = [1,1,1,1,1,1,1, 2,2,2,2,2,2];
    
    flag_exp_output = 1;
    folder_struct = data_folders(exp_idx);
    folder_name = folder_struct.name;
    sub_folder_path = [folder_struct.folder, '\', folder_name, '\'];
    exp_id = folder_name;
    amplitude_matrix = load([sub_folder_path, 'amplitude_matrix.mat']); amplitude_matrix = amplitude_matrix.amplitude_matrix;
    amplitude_matrix(8, :, :, :) = [];
    sub_list(8)= [];
    expertise_idx_amp(8) = []; 
    
    delete_sub_idx = [];
    for sub_idx = 1:numel(sub_list)
        if sum(sum(sum(~isnan(squeeze(amplitude_matrix(sub_idx, :, :, :)))))) == 0
            delete_sub_idx = [delete_sub_idx, sub_idx];
        else
            for ch_idx = 1:numel(ch_names)
                if sum(sum(amplitude_matrix(sub_idx, ch_idx, :, :))) == 0
                    delete_sub_idx = [delete_sub_idx, sub_idx];
                    break;
                end
            end
        end
    end
    
    
    
    for ch_idx = 1:size(amplitude_matrix, 2)
        for bin_idx = 1:size(amplitude_matrix, 3)
            for feat_idx = 1:size(amplitude_matrix, 4)
                data = amplitude_matrix(:,ch_idx,bin_idx,feat_idx);
                [p_amp,tbl_amp,stats_amp] = anova1(data, expertise_idx_amp, 'off');
                f_amp = tbl_amp{2,5};
                if p_amp < p_threshold
                    if flag_exp_output == 1
                        sprintf(['Exp-', exp_id])
                        sub_list(delete_sub_idx) = [];
                        sprintf('Subject list:')
                        sprintfc(' %s: ',  vertcat(sub_list{:}))
                        flag_exp_output = 0;
                    end
                    sprintf('ch = %s, bin = %s, feat = %s, p value: %.4f, f value: %.4f', ch_names{ch_idx}, num2str(bin_idx), feat_names{feat_idx}, p_amp, f_amp)
                end
            end
        end
    end
end
