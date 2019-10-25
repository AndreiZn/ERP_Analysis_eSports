%% reject_IC_automatic works with 05_ERP_esports_data_after_ICA folder:
% - use SASICA plugin to visualize components and their properties
% - mark ICs not related to brain activity

CFG = define_defaults();
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_6_reject_IC_automatic\data';
CFG.output_plots_folder_name = 'stage_6_reject_IC_automatic\plots';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, '\', CFG.output_plots_folder_name];
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
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=8:2:numel(files)       
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
        cur_set_name = CFG.eeglab_set_name;
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 25;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG, CFG);
        plot_name = [CFG.eeglab_set_name, '_01before_IC_rejection'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', plot_name '_plot','.png'])
        close(fig)

        
        %SASICA(EEG);
        [EEG, config] = eeg_SASICA(EEG,'MARA_enable',0,'FASTER_enable',1,'FASTER_blinkchanname','Fp1','ADJUST_enable',1,...
                       'chancorr_enable',0,'chancorr_channames','No channel','chancorr_corthresh','auto 4',...
                       'EOGcorr_enable',0,'EOGcorr_Heogchannames','No channel','EOGcorr_corthreshH','auto 4',...
                       'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV','auto 4','resvar_enable',0,...
                       'resvar_thresh',15,'SNR_enable',1,'SNR_snrcut',1.5,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf],...
                       'trialfoc_enable',1,'trialfoc_focaltrialout','auto','focalcomp_enable',1,'focalcomp_focalICAout',2.5,...
                       'autocorr_enable',1,'autocorr_autocorrint',20,'autocorr_dropautocorr',0.5,'opts_noplot',0,'opts_nocompute',0,'opts_FontSize',14);
%         SASICA(EEG,'MARA_enable',0,'FASTER_enable',1,'FASTER_blinkchanname','Fp1','ADJUST_enable',1,...
%                        'chancorr_enable',0,'chancorr_channames','No channel','chancorr_corthresh','auto 4',...
%                        'EOGcorr_enable',0,'EOGcorr_Heogchannames','No channel','EOGcorr_corthreshH','auto 4',...
%                        'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV','auto 4','resvar_enable',0,...
%                        'resvar_thresh',15,'SNR_enable',1,'SNR_snrcut',1.5,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf],...
%                        'trialfoc_enable',1,'trialfoc_focaltrialout','auto','focalcomp_enable',1,'focalcomp_focalICAout',2.5,...
%                        'autocorr_enable',1,'autocorr_autocorrint',20,'autocorr_dropautocorr',0.5,'opts_noplot',0,'opts_nocompute',0,'opts_FontSize',14);

        figHandles = findall(groot, 'Type', 'figure');
        set(figHandles(1), 'Position', [100 100 550 200])
        
        num_figs = numel(figHandles);
        for figi = [1,3,2]
            cur_fig = figHandles(figi);
            cur_fig_name = ['fig_', num2str(figi)];
            saveas(cur_fig,[CFG.output_plots_folder_cur, '\', cur_set_name, '_', cur_fig_name,'.png'])
            close(cur_fig)
        end
            
        
        % remove selected components
        EEG_with_rejected_comp = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0, 0);
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 25;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG_with_rejected_comp, CFG);
        plot_name = [CFG.eeglab_set_name, '_02after_IC_rejection'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', plot_name '_plot','.png'])
        close(fig)
        
        % save the eeglab dataset
        output_set_name = [CFG.eeglab_set_name, '_IC_marked_for_rejection', '.set'];
        EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
        eeg_checkset(EEG);
        
    end
end


