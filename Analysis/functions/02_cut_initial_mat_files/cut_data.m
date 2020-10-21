% cut_data function works with 00_ERP_data_selected data folder
% Visually inspect data (mark datasets clearly not appropriate for
% analysis, cut beginning and end of datafiles, mark clearly bad channels)
function CFG = cut_data(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = ['stage_1_cut', filesep, 'data'];
CFG.output_plots_folder_name = ['stage_1_cut', filesep, 'plots'];

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
        if strcmp(file_struct.name(end-2:end), 'csv')
            f = readtable(filepath);
            f = f.Variables;
            f = f(:, 1:8)';
            y = zeros(size(f,1)+2, size(f,2));
            y(1,:) = 0:1/CFG.sample_rate:(size(y,2) - 1)/CFG.sample_rate;
            y(2:9,:) = f;
            y(10, 1:CFG.sample_rate:end) = 1;
        else
            y = load(filepath); y = y.y;
        end

        exp_id = file_struct.name(9:10);
        exp_len_sec = CFG.exp_param(exp_id).exp_len_sec;
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
        CFG.beginning_cut_at_idx = size(y,2) - exp_len_sec*CFG.sample_rate; % where to cut original data at the beginning by default
        CFG.end_cut_at_idx = 3*CFG.sample_rate; % where to cut original data at the end by default
        [~, cur_fig, y_cut, CFG] = plot_and_cut_data(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, 'Plot_', file_struct.name(1:end-3), 'png'])
        close(cur_fig);
        
        % plot data to mark bad channels
        [cur_fig, bad_ch_idx, bad_ch_lbl] = mark_bad_channels(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, 'Plot_Bad_chs_', file_name, '.png'])
        close(cur_fig)
        
        % save cut_data and bad_chs
        %if strcmp(file_struct.name(end-3:end), '.mat')
        file_name = file_struct.name(1:end-4);
        %else
        %    file_name = file_struct.name;
        %end
        save([CFG.output_data_folder_cur, filesep, file_name], 'y_cut', 'bad_ch_idx', 'bad_ch_lbl')
    end
end