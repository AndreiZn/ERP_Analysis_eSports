%% reject_IC_semi_automatic works with 05_ERP_esports_data_after_ICA folder:
% - use SASICA plugin to visualize components and their properties
% - mark ICs not related to brain activity

CFG = define_defaults();

answer = questdlg('Would you like to review Independent Components manually?', 'Review ICs manually', ...
    'Yes', 'No', 'Yes');
switch answer
    case 'Yes'
        CFG.review_IC_manually = 1;
    case 'No'
        CFG.review_IC_manually = 0;
end

%% Define function-specific variables
CFG.output_data_folder_name = 'stage_6_reject_IC_semi_automatic\data';
CFG.output_plots_folder_name = 'stage_6_reject_IC_semi_automatic\plots';

CFG.output_data_folder = [CFG.output_folder_path, filesep, CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, filesep, CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
global EEG
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
        exp_id = file_struct.name(9:13);
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
        cur_set_name = CFG.eeglab_set_name;
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 25;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG, CFG);
        plot_name = [CFG.eeglab_set_name, '_01before_IC_rejection'];
        saveas(fig,[CFG.output_plots_folder_cur, filesep, plot_name '_plot','.png'])
        close(fig)
        
        % Run SASICA plugin
        snr_cut = CFG.exp_param(exp_id).snr_cut;
        autocorr_cut = CFG.exp_param(exp_id).autocorr_cut;
        [EEG, config] = eeg_SASICA(EEG,'MARA_enable',0,'FASTER_enable',1,'FASTER_blinkchanname','Fp1','ADJUST_enable',1,...
            'chancorr_enable',0,'chancorr_channames','No channel','chancorr_corthresh','auto 4',...
            'EOGcorr_enable',0,'EOGcorr_Heogchannames','No channel','EOGcorr_corthreshH','auto 4',...
            'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV','auto 4','resvar_enable',0,...
            'resvar_thresh',15,'SNR_enable',1,'SNR_snrcut',snr_cut,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf],...
            'trialfoc_enable',1,'trialfoc_focaltrialout','auto','focalcomp_enable',1,'focalcomp_focalICAout',3,...
            'autocorr_enable',1,'autocorr_autocorrint',20,'autocorr_dropautocorr',autocorr_cut,'opts_noplot',0,'opts_nocompute',0,'opts_FontSize',14);
        
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
        
        % plot data after ICs rejection (if not all of them were rejected)
        if numel(find(EEG.reject.gcompreject)) < numel(EEG.reject.gcompreject)
            % remove selected components
            EEG_with_rejected_comp = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0, 0);
            
            % visualize data using the eeglab function eegplot
            CFG.plot_ICA_components = 0;
            CFG.eeg_plot_spacing = 25;
            CFG.eeglab_plot_fullscreen = 1;
            fig = eeglab_plot_EEG(EEG_with_rejected_comp, CFG);
            plot_name = [CFG.eeglab_set_name, '_02after_IC_rejection'];
            saveas(fig,[CFG.output_plots_folder_cur, filesep, plot_name '_plot','.png'])
            close(fig)
        else
            warndlg(sprintf('All Independent Components for dataset %s were rejected', CFG.eeglab_set_name),'Warning');
        end
        
        % save the eeglab dataset
        output_set_name = [CFG.eeglab_set_name, '_IC_marked_for_rejection', '.set'];
        EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        eeg_checkset(EEG);
        
    end
end


