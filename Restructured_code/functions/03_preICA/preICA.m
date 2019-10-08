%% preICA function works with 04_ERP_esports_data_eeglab_init folder:
% - Rereference data
% - Filter data
% - Split data into epochs
% - Perform baseline correction
% - Reject bad trials

function [CFG, EEG] = preICA(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_3_preICA\data';
CFG.output_plots_folder_name = 'stage_3_preICA\plots';

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
        %filepath = fullfile(file_struct.folder, file_struct.name);
        
        % Load dataset
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        
        % Filter data with a basic FIR filter from 1 to 30 Hz
        EEG = pop_eegfiltnew(EEG,1,30);
        EEG = eeg_checkset(EEG);
        
        % Common average referencing
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
        
        % Interpolate channels marked as bad ones during the visual
        % inspection
        EEG = pop_interp(EEG, EEG.bad_ch.bad_ch_idx, 'spherical');
        EEG = eeg_checkset( EEG );

        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];

        % visualize data using the eeglab function eegplot (compare
        % obtained plots with stage_1 plots as a sanity check)
        fig = eeglab_plot_EEG(EEG);
        saveas(fig,[CFG.output_plots_folder_cur, '\', eeglab_set_name '_plot','.png'])
        close(fig)
        
        % save the eeglab dataset
        output_set_name = [eeglab_set_name, '_init', '.set'];
        EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        EEG = eeg_checkset(EEG);
        
    end
end