%% reject_trials function works with 03_ERP_esports_data_reref_and_filter folder:
% - Split data into epochs
% - Reject bad trials

% reject_trials(CFG)
CFG = define_defaults();
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_4_reject_trials\data';
CFG.output_plots_folder_name = 'stage_4_reject_trials\plots';

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
        
        CFG.eeg_plot_spacing = 50;
        
        % Load dataset
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        
        % Split data into epochs
        epoch_boundary_s = CFG.exp_param(exp_id).epoch_boundary_s;
        baseline_ms = CFG.exp_param(exp_id).baseline_ms;
        EEG = pop_epoch(EEG, {}, epoch_boundary_s, 'newname', [CFG.eeglab_set_name, '_epochs'], 'epochinfo', 'yes');
        EEG = eeg_checkset(EEG);
        % Remove baseline
        %EEG = pop_rmbase(EEG, baseline_ms);
        %EEG = eeg_checkset(EEG);
        
        % visualize data using the eeglab function eegplot
        fig = eeglab_plot_EEG(EEG, CFG);
        cur_set_name = [CFG.eeglab_set_name, '_01before_rejection'];
        saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
        close(fig)
        
        cmd = ['if ~isempty(TMPREJ); ' ...
                    '[tmprej tmprejE] = eegplot2trial(TMPREJ, EEG.pnts, EEG.trials); ' ...
                    '[EEG ~] = pop_rejepoch(EEG, tmprej, 0); ' ...
                    'EEG.manually_rej_trials = tmprej; ', ...
               'end; ' ....
               'callback_reject_button_pressed(CFG, EEG);'
              ];
        eegplot(EEG.data,'eloc_file',EEG.chanlocs,'command',cmd);
        keyboard
    end
end

