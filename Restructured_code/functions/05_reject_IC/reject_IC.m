%% reject_IC works with 07_ERP_esports_data_after_ICA folder:
% - Visualize ICs (topoplot, power spectrum, ERP image)
% - Mark ICs not related to brain activity and reject marked ICs

CFG = define_defaults();
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_6_reject_IC\data';
CFG.output_plots_folder_name = 'stage_6_reject_IC\plots';

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

for subi=1:1%1:numel(subject_folders)
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
        cur_set_name = CFG.eeglab_set_name;
        
        % visualize data using the eeglab function eegplot
        CFG.plot_ICA_components = 0;
        CFG.eeg_plot_spacing = 25;
        CFG.eeglab_plot_fullscreen = 1;
        fig = eeglab_plot_EEG(EEG, CFG);
        plot_name = [CFG.eeglab_set_name, '_01before_IC_rejection'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', plot_name '_plot','.png'])
        close(fig)
        
        % Create CFG.num_components_to_plot figures with IC properties
        % (topoplot, power spectrum and ERP image)
        CFG.num_components_to_plot = round(0.5*size(EEG.icaact,1));
        pop_prop(EEG, 0, 1:CFG.num_components_to_plot, 1,{'freqrange' [1 30]});
        
        % Plot time-series of each IC
        CFG.plot_ICA_components = 1;
        CFG.eeg_plot_spacing = 15;
        CFG.eeglab_plot_fullscreen = 0;
        eeglab_plot_EEG(EEG, CFG);

        % get handles of all figures and save them
        figHandles = findall(groot, 'Type', 'figure');
        num_figs = numel(figHandles);
        for figi = num_figs:-1:2
            cur_fig = figHandles(figi);
            cur_fig_name = cur_fig.Name(14:end);
            saveas(cur_fig,[CFG.output_plots_folder_cur, '\', cur_set_name, '_', cur_fig_name,'.png'])
        end
        
        % Wait till the user marks bad components
        keyboard
        
        % close components' time-series plot
        close(figHandles(1))
        % plot again but with marked components highlighted with red color
        fig = eeglab_plot_EEG(EEG, CFG);
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_reject_IC','.png'])
        close(fig)
        
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


