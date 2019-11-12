%% group_analysis_of_ERP function works with 07_ERP_esports_data_get_ERP folder:
% - combine ERPs for pro and non-ro groups and compare them

function CFG = group_analysis_of_ERP(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_8_group_analysis_of_ERP\data';
CFG.output_plots_folder_name = 'stage_8_group_analysis_of_ERP\plots';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

% folder for plots (plots will be grouped by sub_id in this folder)
CFG.output_plots_folder = [CFG.output_folder_path, '\', CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path);
subject_folders = subject_folders(3:end);

ERP_combined = [];

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=1:2:numel(files)
        % read file
        file_struct = files(filei);
        exp_id = file_struct.name(9:13);
        CFG.eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
%         % create output folders
%         CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
%         if ~exist(CFG.output_data_folder_cur, 'dir')
%             mkdir(CFG.output_data_folder_cur)
%         end
%         CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
%         if ~exist(CFG.output_plots_folder_cur, 'dir')
%             mkdir(CFG.output_plots_folder_cur)
%         end

%         % Load dataset
          ERP = pop_loaderp( 'filename', file_struct.name, 'filepath',file_struct.folder);
          
          % Calculate the difference between the first and the second bins
          ERP = pop_binoperator(ERP, {'b3 = b1 - b2'});
          
          if str2double(sub_ID) < 2000
              % pro-players group
              ERP.pro = 1;
              ERP.exp_id = exp_id;
          else
              % non-pro-players group
              ERP.pro = 0;
              ERP.exp_id = exp_id;
          end
          
          % save all ERPs in the ERP_combined struct
          ERP_combined = [ERP_combined; ERP];
          
%         EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
%         EEG = eeg_checkset(EEG);
        
    end
end

% CFG.channel_lbl_to_plot = 'Pz';
% CFG.channel_idx_to_plot = find(contains({ERP.chanlocs.labels},CFG.channel_lbl_to_plot));
% num_datasets = numel(ERP_combined);
% 
% exp_IDs = {'1_2_2'; '2_2_2'; '2_2_4'; '2_2_5'};
% 
% for exp_idx = 1:numel(exp_IDs)
%     exp_id_cur = exp_IDs(exp_idx);
%     ERP_idx = find(contains({ERP_combined.exp_id},exp_id_cur));
%     for 
%     end
% end
