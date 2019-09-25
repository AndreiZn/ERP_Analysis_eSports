% Select the channel location file, the data folder
function CFG = cut_data(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = 'stage_1_cut\data';
CFG.output_plots_folder_name = 'stage_1_cut\plots';

%% Find code, data and output folders
cell_root_folder = split(CFG.root_folder, "\");
root_folder_name = cell_root_folder{end};
code_folder_name = [root_folder_name, '_code'];
data_folder_name = [root_folder_name, '_data'];
output_folder_name = [root_folder_name, '_output'];

code_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, code_folder_name}, '\');
data_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, data_folder_name}, '\');
output_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, output_folder_name}, '\');

answer = questdlg('Use default locations of code, data and output folders?', 'Location of other folders', ...
    'Yes', 'No', 'Yes');
switch answer
    case 'Yes'
        CFG.code_folder_path = code_folder_path;
        CFG.data_folder_path = data_folder_path;
        CFG.output_folder_path = output_folder_path;
    case 'No'
        CFG.code_folder_path = uigetdir('./','Select a code folder...');
        CFG.data_folder_path = uigetdir('./','Select a data folder...');
        CFG.output_folder_path = uigetdir('./','Select an output folder...');
end

CFG.output_data_folder = [output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [output_folder_path, '\', CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path );
subject_folders = subject_folders(3:end);

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        y = load(filepath); y = y.y;
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        % plot data to set bginning and end markers
        file_name = file_struct.name(1:end-4);
        CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning by default
        CFG.end_cut_at_idx = 3000; % where to cut original data at the end by default
        [~, cur_fig, y_cut, CFG] = plot_and_cut_data(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, '\Plot_', file_struct.name(1:end-3), 'png'])
        close(cur_fig);
        
        % plot data to mark bad channels
        [cur_fig, bad_ch_idx, bad_ch_lbl] = mark_bad_channels(y, CFG, file_name);
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, '\Plot_Bad_chs_', file_name, '.png'])
        close(cur_fig)
        
        % save cut_data and bad_chs
        save([CFG.output_data_folder_cur, '\', file_struct.name], 'y_cut', 'bad_ch_idx', 'bad_ch_lbl')
    end
end