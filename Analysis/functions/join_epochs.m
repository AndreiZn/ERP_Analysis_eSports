% join_epochs function works with epoched set
% Joins epochs of EEG.data and saves as mat files
function CFG = join_epochs(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = ['stage_6_join_epochs', filesep, 'data'];
CFG.output_plots_folder_name = ['stage_6_join_epochs', filesep, 'plots'];

CFG.output_data_folder = [CFG.output_folder_path, filesep, CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, filesep, CFG.output_plots_folder_name];
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
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=2:2:numel(files)
        
        % read file
        file_struct = files(filei);
        exp_id = file_struct.name(9:10);
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        CFG.eeglab_set_name = eeglab_set_name;
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        % Load dataset
        
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 50;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG, CFG);
        plot_name = [CFG.eeglab_set_name, '_01before_joining_epochs'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, plot_name '_plot','.png'])
        close(fig)
        
        % combine epochs into one epoch
        EEG = epoch2continuous(EEG);
        EEG = eeg_checkset(EEG);
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 50;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG, CFG);
        plot_name = [CFG.eeglab_set_name, '_02after_joining_epochs'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, plot_name '_plot','.png'])
        close(fig)
        
        save([CFG.output_data_folder_cur, filesep, eeglab_set_name], 'EEG')
        
    end
end