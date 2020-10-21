% concat_data function works with cut_data mat files
% Concatenate mat files of different runs for the same experiments and
% subjects
function CFG = concat_data(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = ['stage_2_concat', filesep, 'data'];
CFG.output_plots_folder_name = ['stage_2_concat', filesep, 'plots'];

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
dirflag = [subject_folders.isdir] & ~strcmp({subject_folders.name},'..') & ~strcmp({subject_folders.name},'.') & ~strcmp({subject_folders.name},'.DS_Store');
subject_folders = subject_folders(dirflag);

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(dirflag);
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        file = load(filepath);
        y = file.y_cut; bad_ch_idx = file.bad_ch_idx; bad_ch_lbl = file.bad_ch_lbl;
        
        exp_id = file_struct.name(9:10);
        trial_id = file_struct.name(12:12);
        num_runs = CFG.exp_param(exp_id).runs;
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        if str2double(trial_id) == 1
            y_concat = y;
            bad_ch_idx_concat = bad_ch_idx;
        else
            y_concat = [y_concat, y];
            bad_ch_idx_concat = [bad_ch_idx_concat, bad_ch_idx];
        end
        
        if str2double(trial_id) == num_runs
            % save concat_data
            y = y_concat;
            bad_ch_idx = bad_ch_idx_concat;
            file_name = file_struct.name(1:end-6);
            save([CFG.output_data_folder_cur, filesep, file_name], 'y', 'bad_ch_idx', 'bad_ch_lbl')
        end
        
    end
end