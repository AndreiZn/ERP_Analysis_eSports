%% intrp_reref_and_filter function works with 02_ERP_esports_data_eeglab_init folder:
% - Interpolate bad channels
% - Rereference data (CAR)
% - Filter data

function [CFG, EEG] = intrp_reref_and_filter(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_3_intrp_reref_and_filter\data';
CFG.output_plots_folder_name = 'stage_3_intrp_reref_and_filter\plots';

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

for subi=1:numel(subject_folders)
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
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        CFG.eeg_plot_spacing = 50;
        
        % Load dataset
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [eeglab_set_name, '_01init'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)

        % Interpolate channels marked as bad ones during the visual
        % inspection
        EEG_interp = pop_interp(EEG, EEG.bad_ch.bad_ch_idx, 'spherical');
        EEG_interp = eeg_checkset(EEG_interp);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_interp, CFG);
        cur_set_name = [eeglab_set_name, '_02interp'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)
        
        % Common average referencing
        EEG_CAR = pop_reref(EEG_interp, []);
        EEG_CAR = eeg_checkset(EEG_CAR);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_CAR, CFG);
        cur_set_name = [eeglab_set_name, '_03CAR'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)
        
        % Filter data with a basic FIR filter from 1 to 30 Hz
        EEG_filt = pop_eegfiltnew(EEG_CAR,1,30);
        EEG_filt = eeg_checkset(EEG_filt);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_filt, CFG);
        cur_set_name = [eeglab_set_name, '_04filtered'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)
        
        % calculate EEG.data rank decrease due to CAR
        EEG_filt.rank_manually_computed = EEG_filt.nbchan - numel(EEG_filt.bad_ch.bad_ch_idx) - 1; 
        assert(EEG_filt.rank_manually_computed == rank(EEG_filt.data(:,:)),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        % save the eeglab dataset
        output_set_name = [eeglab_set_name, '_intrp_reref_filtered', '.set'];
        EEG = pop_saveset(EEG_filt, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        EEG = eeg_checkset(EEG);
        
    end
end