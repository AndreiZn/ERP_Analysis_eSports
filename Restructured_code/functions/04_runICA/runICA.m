%% runICA function works with 06_ERP_esports_data_reject_trials folder:
% - Run ICA
% - Plot ICA components

function CFG = runICA(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_5_runICA\data';
CFG.output_plots_folder_name = 'stage_5_runICA\plots';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, '\', CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path);
subject_folders = subject_folders(3:end);

for subi=7:7%numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=2:2:numel(files)       
        % read file
        file_struct = files(filei);
        exp_id = file_struct.name(9:13);
        CFG.eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end

        % Load dataset
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        
        EEG = pop_runica(EEG,'extended',1,'interupt','on');
        % visualize all components using the eeglab function eegplot
        CFG.plot_ICA_components = 1;
        CFG.num_components_to_plot = CFG.total_num_data_channels;
        CFG.eeg_plot_spacing = 15;
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [CFG.eeglab_set_name, '_all_ICA_components'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)
        % visualize main components using the eeglab function eegplot
        CFG.plot_ICA_components = 1;
        CFG.num_components_to_plot = 10;
        CFG.eeg_plot_spacing = 15;
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [CFG.eeglab_set_name, '_main_ICA_components'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)

        % save the eeglab dataset
        output_set_name = [CFG.eeglab_set_name, '_after_ICA', '.set'];
        EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        eeg_checkset(EEG);
        
    end
end


