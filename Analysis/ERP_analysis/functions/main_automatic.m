%% run all functions from main automatically 

% Define default variables
CFG = define_defaults();

global EEG

% Define output folders
CFG.output_data_folder_name = ['combined_output_Airat_settings', filesep, 'data'];
CFG.output_plots_folder_name = ['combined_output_Airat_settings', filesep, 'plots'];

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
    
    % select only those files that contain 'pd_markers in the name'
    fl = regexp({files.name}, 'CS_\d_pd_markers');
    selected_files = ones(1, numel(fl), 'logical');
    for i=1:numel(fl)
        selected_files(i) = ~isempty(fl{i});
    end
    files2 = files(selected_files);
    
    % rename selected files to old format
    fl = regexp({files2.name}, 'pd_markers');
    for i=1:numel(fl)
        if ~isempty(fl{i})
            filepath = fullfile(files2(i).folder, files2(i).name);
            exp_num = files2(i).name(fl{i}-2);
            new_name = [files2(i).name(1:8), '4_1_', exp_num, '.csv'];
            new_name = fullfile(files2(i).folder, new_name);
            movefile(filepath, new_name, 'f')
        end
    end
    
    % keep only those files that contain '\d_\d_\d in the name'
    files = dir(folderpath);
    fl = regexp({files.name}, '\d_\d_\d');
    selected_files = ones(1, numel(fl), 'logical');
    for i=1:numel(fl)
        selected_files(i) = ~isempty(fl{i});
    end
    files = files(selected_files);

    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        
        if strcmp(filepath(end-2:end), 'csv')
            y = readtable(filepath);
            di_markers = y.DI_markers;
            y = table2array(y);
            y(:, CFG.groupid_channel) = di_markers;
            y = y';
        else
            y = load(filepath); y = y.y;
        end
        
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
%         saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, '01_Plot_', file_struct.name(1:end-3), 'png'])
        close(cur_fig);
        
        % plot data to mark bad channels
        [cur_fig, bad_ch_idx, bad_ch_lbl] = mark_bad_channels(y_cut, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, '02_Plot_Bad_chs_', file_name, '.png'])
        close(cur_fig)
        
        % import data to eeglab
        eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        CFG.eeglab_set_name = eeglab_set_name;
        [EEG] = import_mat_to_eeglab(CFG, y_cut, eeglab_set_name, sub_ID);
        
        % add info on bad channels to the EEG structure
        EEG.bad_ch.bad_ch_idx = bad_ch_idx;
        EEG.bad_ch.bad_ch_lbl = bad_ch_lbl;
        
        % visualize data using the eeglab function eegplot (compare
        % obtained plots with stage_1 plots as a sanity check)
%         fig = eeglab_plot_EEG(EEG,CFG);
%         saveas(fig,[CFG.output_plots_folder_cur, filesep, '03_', eeglab_set_name '_plot','.png'])
%         close(fig)
        
        CFG.eeg_plot_spacing = 50;
        
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [eeglab_set_name, '_01init'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, '04_', cur_set_name '_plot','.png'])
        close(fig)

        % Interpolate channels marked as bad ones during the visual
        % inspection
        EEG_interp = pop_interp(EEG, EEG.bad_ch.bad_ch_idx, 'spherical');
        EEG_interp = eeg_checkset(EEG_interp);
        % visualize data using the eeglab function eegplot
%         fig = eeglab_plot_EEG(EEG_interp, CFG);
%         cur_set_name = [eeglab_set_name, '_02interp'];
%         saveas(fig,[CFG.output_plots_folder_cur, filesep, '05_', cur_set_name '_plot','.png'])
%         close(fig)
        
        % Common average referencing
%         EEG_CAR = pop_reref(EEG_interp, []);
        EEG_CAR = eeg_checkset(EEG);
        % visualize data using the eeglab function eegplot
%         fig = eeglab_plot_EEG(EEG_CAR, CFG);
%         cur_set_name = [eeglab_set_name, '_03CAR'];
%         saveas(fig,[CFG.output_plots_folder_cur, filesep, '06_', cur_set_name '_plot','.png'])
%         close(fig)
        
%%%%% Changed parameter from 1 to 0.5
        % Filter data with a basic FIR filter from 1 to 30 Hz
        EEG_filt = pop_eegfiltnew(EEG_CAR,0.5,30);
        EEG_filt = eeg_checkset(EEG_filt);
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG_filt, CFG);
        cur_set_name = [eeglab_set_name, '_04filtered'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, '07_', cur_set_name '_plot','.png'])
        close(fig)
        
        % calculate EEG.data rank decrease due to CAR
%         EEG_filt.rank_manually_computed = EEG_filt.nbchan - numel(EEG_filt.bad_ch.bad_ch_idx) - 1;
        EEG_filt.rank_manually_computed = EEG_filt.nbchan - numel(EEG_filt.bad_ch.bad_ch_idx);
        assert(EEG_filt.rank_manually_computed == rank(EEG_filt.data(:,:), 10),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        EEG = EEG_filt;
        
        % Split data into epochs
        epoch_boundary_s = CFG.exp_param(exp_id).epoch_boundary_s;
        EEG = pop_epoch(EEG, {}, epoch_boundary_s, 'newname', [CFG.eeglab_set_name, '_epochs'], 'epochinfo', 'yes');
        EEG = eeg_checkset(EEG);
        
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
        CFG.num_components_to_plot = size(EEG.icaact,1);
        CFG.eeg_plot_spacing = 15;
%         fig = eeglab_plot_EEG(EEG, CFG);
%         cur_set_name = [CFG.eeglab_set_name, '_all_ICA_components'];
%         saveas(fig,[CFG.output_plots_folder_cur, filesep, '08_', cur_set_name '_plot','.png'])
%         close(fig)
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 25;
        CFG.eeglab_plot_fullscreen = 1;
%         fig = eeglab_plot_EEG(EEG, CFG);
%         plot_name = [CFG.eeglab_set_name, '_01before_IC_rejection'];
%         saveas(fig,[CFG.output_plots_folder_cur, filesep, '09_', plot_name '_plot','.png'])
%         close(fig)
        
%         answer = questdlg('Would you like to review Independent Components manually?', 'Review ICs manually', ...
%             'Yes', 'No', 'Yes');
%         switch answer
%             case 'Yes'
%                 CFG.review_IC_manually = 1;
%             case 'No'
%                 CFG.review_IC_manually = 0;
%         end
%         
        CFG.review_IC_manually = 0;

        % Run SASICA plugin
        snr_cut = CFG.exp_param(exp_id).snr_cut;
        autocorr_cut = CFG.exp_param(exp_id).autocorr_cut;
%         [EEG, config] = eeg_SASICA(EEG,'MARA_enable',0,'FASTER_enable',0,'FASTER_blinkchanname','Fp1','ADJUST_enable',1,...
%             'chancorr_enable',0,'chancorr_channames','No channel','chancorr_corthresh','auto 4',...
%             'EOGcorr_enable',0,'EOGcorr_Heogchannames','No channel','EOGcorr_corthreshH','auto 4',...
%             'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV','auto 4','resvar_enable',0,...
%             'resvar_thresh',15,'SNR_enable',1,'SNR_snrcut',snr_cut,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf],...
%             'trialfoc_enable',1,'trialfoc_focaltrialout','auto','focalcomp_enable',1,'focalcomp_focalICAout',4.5,...
%             'autocorr_enable',1,'autocorr_autocorrint',20,'autocorr_dropautocorr',autocorr_cut,'opts_noplot',0,'opts_nocompute',0,'opts_FontSize',14);
%         
        [EEG, config] = eeg_SASICA(EEG,'MARA_enable',0,'FASTER_enable',0,'FASTER_blinkchanname','Fp1','ADJUST_enable',1,...
            'chancorr_enable',0,'chancorr_channames','No channel','chancorr_corthresh','auto 4',...
            'EOGcorr_enable',0,'EOGcorr_Heogchannames','No channel','EOGcorr_corthreshH','auto 4',...
            'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV','auto 4','resvar_enable',0,...
            'resvar_thresh',15,'SNR_enable',1,'SNR_snrcut',snr_cut,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf],...
            'trialfoc_enable',0,'trialfoc_focaltrialout','auto','focalcomp_enable',0,'focalcomp_focalICAout',4.5,...
            'autocorr_enable',0,'autocorr_autocorrint',20,'autocorr_dropautocorr',autocorr_cut,'opts_noplot',0,'opts_nocompute',0,'opts_FontSize',14);
        
        
        % change the size of one of the plots
        figHandles = findall(groot, 'Type', 'figure');
        set(figHandles(1), 'Position', [100 100 550 200])
        
        % save obtained plots
        num_figs = numel(figHandles);
        for figi = 1:num_figs
            cur_fig = figHandles(figi);
            cur_fig_name = ['fig_', num2str(figi)];
            set(cur_fig, 'PaperPositionMode', 'auto')
            saveas(cur_fig,[CFG.output_plots_folder_cur, filesep, cur_set_name, '_', cur_fig_name,'.png'])
        end
        
        % if reviewed manually, pause the script, then visualize
        % selected/rejected components with pop_selectcomps
        % otherwise, just close plotted figures
        if CFG.review_IC_manually
            n_data_points = EEG.trials * size(EEG.data, 2);
            ICA_quality_parameter = 20*EEG.nbchan^2;
            if n_data_points < ICA_quality_parameter
                warndlg(sprintf('Number of data points might have been insufficient for the ICA algorithm (%.1f%% of necessary data points)', 100*n_data_points/ICA_quality_parameter),'Warning');
            else
                sprintf('Number of data points was sufficient for the ICA algorithm (%.1f%% of necessary data points)', 100*n_data_points/ICA_quality_parameter)
            end
            keyboard;
            pop_selectcomps(EEG, 1:size(EEG.icaact,1));
            cur_fig = gcf;
            cur_fig_name = 'fig_2_IC_selected_manually';
            saveas(cur_fig,[CFG.output_plots_folder_cur, filesep, cur_set_name, '_', cur_fig_name,'.png'])
            close(cur_fig)
        else
            for figi = [1,3,2]
                cur_fig = figHandles(figi);
                close(cur_fig)
            end
        end
        
%         % plot data after ICs rejection (if not all of them were rejected)
%         if numel(find(EEG.reject.gcompreject)) < numel(EEG.reject.gcompreject)
%             % remove selected components
%             EEG_with_rejected_comp = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0, 0);
%             
%             % visualize data using the eeglab function eegplot
%             CFG.eeg_plot_spacing = 25;
%             CFG.eeglab_plot_fullscreen = 1;
%             fig = eeglab_plot_EEG(EEG_with_rejected_comp, CFG);
%             plot_name = [CFG.eeglab_set_name, '_02after_IC_rejection'];
%             saveas(fig,[CFG.output_plots_folder_cur, filesep, plot_name '_plot','.png'])
%             close(fig)
%         else
%             warndlg(sprintf('All Independent Components for dataset %s were rejected', CFG.eeglab_set_name),'Warning');
%         end
        
        % remove marked ICs
        rem = zeros(1, numel(EEG.reject.gcompreject));
        rem(1, 1:3) = 1;
        EEG.reject.gcompreject = EEG.reject.gcompreject.* rem;
        num_components_to_remove = numel(find(EEG.reject.gcompreject));
        EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0, 0);
        
        % recompute rank of the data matrix manually
        EEG.rank_manually_computed = EEG.rank_manually_computed - num_components_to_remove;

        % check rank of the data matrix
        assert(EEG.rank_manually_computed == rank(reshape(EEG.data, EEG.nbchan, [])),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        
        % remove baseline
        baseline_ms = CFG.exp_param(exp_id).baseline_ms;
        EEG = pop_rmbase(EEG, baseline_ms);
        EEG = eeg_checkset(EEG);
        
        % combine epochs into one epoch
        EEG = epoch2continuous(EEG);
        EEG = eeg_checkset(EEG);
        
        % load eventlist, split data into epochs and remove baseline in the ERPLAB plugin
        CFG.epoch_boundary_ms = 1000*CFG.exp_param(exp_id).epoch_boundary_s;
        elist_filename = ['elist_', exp_id, '_short.txt'];
        CFG.elist_path = [CFG.erplab_files_folder, filesep, exp_id, filesep, elist_filename];
        [CFG, EEG] = load_eventlist_and_epoch(CFG, EEG);
        
        % compute ERPs
        [ERP] = compute_ERP(EEG);
        EEG_data = EEG.data;
        EEG_trigger = [];
        for i=1:numel(EEG.urevent)
            EEG_trigger = [EEG_trigger, EEG.urevent(i).type];
        end
 
        save([CFG.output_data_folder_cur, filesep, CFG.eeglab_set_name '_EEG_cleaned_eeglab.mat'],'EEG')
        save([CFG.output_data_folder_cur, filesep, CFG.eeglab_set_name '_EEG_cleaned.mat'],'EEG_data')
        save([CFG.output_data_folder_cur, filesep, CFG.eeglab_set_name '_trigger_channel.mat'],'EEG_trigger')
    end
end