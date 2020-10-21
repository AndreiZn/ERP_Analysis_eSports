%% runICA function works with 04_ERP_esports_data_reject_trials folder:
% - Run ICA
% - Plot ICA components

function CFG = runICA(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = ['stage_6_runICA', filesep, 'data'];
CFG.output_plots_folder_name = ['stage_6_runICA', filesep, 'plots'];

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
        CFG.eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
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
        
        % check the rank of the data matrix
        assert(EEG.rank_manually_computed == rank(reshape(EEG.data, EEG.nbchan, [])),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        % run ICA (getrank(tmpdata) function corrected to return rank of
        % the matrix and not the total number of channels - for details read "Adjust data rank for ICA" at https://sccn.ucsd.edu/wiki/Makoto%27s_preprocessing_pipeline#Run_ICA_.2806.2F26.2F2018_updated.29 
        EEG = pop_runica(EEG,'extended',1,'interupt','on');
        %EEG = eeg_checkset(EEG);
        
        % check that the rank of the data matrix is equal to the number of
        % ICA components
        assert(EEG.rank_manually_computed == size(EEG.icaact,1),'Rank of the data matrix is not equal to the number of ICA components')
        
        % visualize all components using the eeglab function eegplot
        CFG.plot_ICA_components = 1;
        CFG.num_components_to_plot = size(EEG.icaact,1);
        CFG.eeg_plot_spacing = 15;
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [CFG.eeglab_set_name, '_all_ICA_components'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, cur_set_name '_plot','.png'])
        close(fig)

        % save the eeglab dataset
        output_set_name = [CFG.eeglab_set_name, '_after_ICA', '.set'];
        EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        eeg_checkset(EEG);
        
    end
end

