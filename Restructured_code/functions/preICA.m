%% PreICA function works with 03_ERP_data_cut data folder:
% - Import data in matlab format, convert it to the eeglab format, fill in dataset info,
% add channel locations and save resulting datasets
% - Rereference data
% - Filter data
% - Split data into epochs
% - Perform baseline correction
% - Reject bad trials

function [CFG, EEG] = preICA(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_2_convert_to_eeglab\data';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
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
    
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        file = load(filepath);
        y = file.y_cut; bad_ch_idx = file.bad_ch_idx; bad_ch_lbl = file.bad_ch_lbl;
        %file_name = file_struct.name(1:end-4);
        
        exp_id = file_struct.name(9:13);
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        
        % import data to eeglab
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        [EEG] = import_mat_to_eeglab(CFG, y, eeglab_set_name, sub_ID);
        
        % TO DO:
        % save bad channels in the EEG structure
        % save eeglab dataset
        
%         output_set_name = [set_name, '_', output_suffix, '.set'];
%         EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',output_folder_cur);
%         EEG = eeg_checkset(EEG);
        
    end
end