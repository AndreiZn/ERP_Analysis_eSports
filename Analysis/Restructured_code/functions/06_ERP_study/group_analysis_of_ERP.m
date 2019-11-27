%% group_analysis_of_ERP function works with 07_ERP_esports_data_get_ERP folder:
% - combine ERPs for pro and non-ro groups and compare them

function CFG = group_analysis_of_ERP(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_8_group_analysis_of_ERP\data';
CFG.output_plots_folder_name = 'stage_8_group_analysis_of_ERP\plots';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

% folder for plots (plots will be grouped by sub_id in this folder)
CFG.output_plots_folder = [CFG.output_folder_path, '\', CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path);
subject_folders = subject_folders(3:end);

ERP_combined = [];

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=1:2:numel(files)
        % read file
        file_struct = files(filei);
        exp_id = file_struct.name(9:13);
        CFG.eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
        % Load dataset
        ERP = pop_loaderp( 'filename', file_struct.name, 'filepath',file_struct.folder);
        
        % Calculate the difference between the first and the second bins
        ERP = pop_binoperator(ERP, {'b3 = b1 - b2'});
        
        if str2double(sub_ID) < 2000
            % pro-players group
            ERP.pro = 1;
            ERP.exp_id = exp_id;
        else
            % non-pro-players group
            ERP.pro = 0;
            ERP.exp_id = exp_id;
        end
        
        % save all ERPs in the ERP_combined struct
        ERP_combined = [ERP_combined; ERP];
        
        %         EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        %         EEG = eeg_checkset(EEG);
        
    end
end



exp_IDs = unique({ERP_combined.exp_id});

for exp_idx = 1:numel(exp_IDs)
    exp_id_cur = exp_IDs(exp_idx);
    ERP_idx = find(contains({ERP_combined.exp_id},exp_id_cur));







ch_ids = [28,31,32];
for ch_idx = ch_ids
    
    lbls = {ERP.chanlocs.labels};
    CFG.channel_lbl_to_plot = lbls{ch_idx};
    CFG.channel_idx_to_plot = ch_idx;%find(contains({ERP.chanlocs.labels},CFG.channel_lbl_to_plot));
    if CFG.plot_diff_only
        CFG.bin_to_plot = 3; % difference between responses to target and non-target stimuli
        line_styles = {'-b'};
    else
        CFG.bin_to_plot = [1, 2, 3];
        line_styles = {'-r'; '-b'; '-g'};
    end
    
    exp_IDs = {'1_2_2'; '2_2_2'; '2_2_4'; '2_2_5'};
    %exp_IDs = {'2_2_2'; '2_2_4'; '2_2_5'};
    
    for exp_idx = 1:numel(exp_IDs)
        exp_id_cur = exp_IDs(exp_idx);
        ERP_idx = find(contains({ERP_combined.exp_id},exp_id_cur));
        
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', exp_id_cur{:}];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        figure('units','normalized','outerposition',[0 0 0.3 1])
        times = ERP_combined(ERP_idx(1)).times;
        
        if CFG.normalize_ERP
            delta_y = 4;
        else
            if CFG.plot_diff_only
                delta_y = 10;
            else
                delta_y = 40;
            end
        end
        
        ytick_value = zeros(numel(ERP_idx),1);
        ytick_label = cell(numel(ERP_idx),1);
        
        for dst_i = 1:numel(ERP_idx)
            dst_idx = ERP_idx(dst_i);
            ERP_cur = ERP_combined(dst_idx);
            
            for bin_idx = 1:numel(CFG.bin_to_plot)
                bin_to_plot = CFG.bin_to_plot(bin_idx);
                ERP_data = ERP_cur.bindata(CFG.channel_idx_to_plot, :, bin_to_plot);
                const_delta = delta_y*(numel(ERP_idx)-dst_i+1);
                if CFG.normalize_ERP
                    max_amp = max(max(abs(ERP_cur.bindata(CFG.channel_idx_to_plot, :, CFG.bin_to_plot))));
                    ERP_data = ERP_data/max_amp;
                end
                data_to_plot = ERP_data + const_delta;
                baseline = linspace(const_delta, const_delta, numel(times));
                
                ytick_value(dst_i) = mean(baseline);
                ytick_label{dst_i} = ERP_cur.subject;
                line_style = line_styles{bin_idx};
                plot(times, data_to_plot, line_style)
                hold on
            end
            
            plot(times, baseline, '--k')
        end
        
        title(['ERP data plot, channel: ', CFG.channel_lbl_to_plot], 'Interpreter', 'None')
        xlabel('Time, ms')
        ylabel('Amplitude, mcV')
        ylim = [0, delta_y*(1+numel(ERP_idx))];
        plot([0, 0], [0, max(ylim)], '--k')
        time_400_ms_idx = dsearchn(times', 400);
        plot([times(time_400_ms_idx), times(time_400_ms_idx)], [0, max(ylim)], '--k')
        set(gca, 'ylim', ylim, 'Ytick', ytick_value(end:-1:1), 'YTickLabel', ytick_label(end:-1:1))
        
        plot_name = ['ERP_channel_', CFG.channel_lbl_to_plot];
        saveas(gcf,[CFG.output_plots_folder_cur, '\', plot_name,'.png'])
        close(gcf)
  
    end
end


