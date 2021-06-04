%% run all functions from main automatically 

% Define default variables
CFG = define_defaults();

% Define output folders
CFG.output_data_folder_name = ['combined_output', filesep, 'data'];
CFG.output_plots_folder_name = ['combined_output', filesep, 'plots'];

CFG.output_data_folder = [CFG.output_folder_path, filesep, CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, filesep, CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

% Loop through folders
subject_folders = dir(CFG.data_folder_path );
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
    
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        y = load(filepath); y = y.y;
        
        % read experiment id
        exp_id = file_struct.name(9:13);
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        % plot data to set bginning and end markers
        file_name = file_struct.name(1:end-4);
        CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning by default
        CFG.end_cut_at_idx = 3000; % where to cut original data at the end by default
        [~, cur_fig, y_cut, CFG] = plot_and_cut_data(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, 'Plot_', file_struct.name(1:end-3), 'png'])
        close(cur_fig);
        
        % plot data to mark bad channels
        [cur_fig, bad_ch_idx, bad_ch_lbl] = mark_bad_channels(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, 'Plot_Bad_chs_', file_name, '.png'])
        close(cur_fig)
        
        % import data to eeglab
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        CFG.eeglab_set_name = eeglab_set_name;
        [EEG] = import_mat_to_eeglab(CFG, y, eeglab_set_name, sub_ID);
        
        % add info on bad channels to the EEG structure
        EEG.bad_ch.bad_ch_idx = bad_ch_idx;
        EEG.bad_ch.bad_ch_lbl = bad_ch_lbl;
        
        % visualize data using the eeglab function eegplot (compare
        % obtained plots with stage_1 plots as a sanity check)
        fig = eeglab_plot_EEG(EEG,CFG);
        saveas(fig,[CFG.output_plots_folder_cur, filesep, eeglab_set_name '_plot','.png'])
        close(fig)
        
        CFG.eeg_plot_spacing = 50;
        
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [eeglab_set_name, '_01init'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, cur_set_name '_plot','.png'])
        close(fig)

        % Interpolate channels marked as bad ones during the visual
        % inspection
        EEG_interp = pop_interp(EEG, EEG.bad_ch.bad_ch_idx, 'spherical');
        EEG_interp = eeg_checkset(EEG_interp);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_interp, CFG);
        cur_set_name = [eeglab_set_name, '_02interp'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, cur_set_name '_plot','.png'])
        close(fig)
        
        % Common average referencing
        EEG_CAR = pop_reref(EEG_interp, []);
        EEG_CAR = eeg_checkset(EEG_CAR);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_CAR, CFG);
        cur_set_name = [eeglab_set_name, '_03CAR'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, cur_set_name '_plot','.png'])
        close(fig)
        
        % Filter data with a basic FIR filter from 1 to 30 Hz
        EEG_filt = pop_eegfiltnew(EEG_CAR,1,30);
        EEG_filt = eeg_checkset(EEG_filt);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_filt, CFG);
        cur_set_name = [eeglab_set_name, '_04filtered'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, cur_set_name '_plot','.png'])
        close(fig)
        
        % calculate EEG.data rank decrease due to CAR
        EEG_filt.rank_manually_computed = EEG_filt.nbchan - numel(EEG_filt.bad_ch.bad_ch_idx) - 1; 
        assert(EEG_filt.rank_manually_computed == rank(EEG_filt.data(:,:), 10),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        EEG = EEG_filt;
        
        % Split data into epochs
        epoch_boundary_s = CFG.exp_param(exp_id).epoch_boundary_s;
        EEG = pop_epoch(EEG, {}, epoch_boundary_s, 'newname', [CFG.eeglab_set_name, '_epochs'], 'epochinfo', 'yes');
        EEG = eeg_checkset(EEG);
        
        keyboard
        % check the rank of the data matrix
        assert(EEG.rank_manually_computed == rank(reshape(EEG.data, EEG.nbchan, [])),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        % run ICA (getrank(tmpdata) function corrected to return rank of
        % the matrix and not the total number of channels - for details read "Adjust data rank for ICA" at https://sccn.ucsd.edu/wiki/Makoto%27s_preprocessing_pipeline#Run_ICA_.2806.2F26.2F2018_updated.29
        EEG = pop_runica(EEG,'extended',1,'interupt','on');
        EEG = eeg_checkset(EEG);
        if isempty(EEG.icaact)
            EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % automatically does single or double
            EEG.icaact    = reshape( EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);
        end
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
        
        
    end
end