% Select the channel location file, the data folder
function CFG = cut_data(CFG)

%% Define variables

    CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning
    CFG.end_cut_at_idx = 3000; % where to cut original data at the end
    CFG.total_num_channels = 32;
    gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);
    CFG.output_data_folder_name = 'stage_1_cut\data';
    CFG.output_plots_folder_name = 'stage_1_cut\plots';
    
%% Select a root folder (it implies that the root folder will contain the code, data and output folders

    CFG.root_folder = uigetdir('./','Select a root folder...');
    
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
            
            CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
            if ~exist(CFG.output_data_folder_cur, 'dir')
                mkdir(CFG.output_data_folder_cur)
            end
            
            CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
            if ~exist(CFG.output_plots_folder_cur, 'dir')
                mkdir(CFG.output_plots_folder_cur)
            end
            
            % plot data
            [~, cur_fig] = plot_and_cut_data(y, CFG, file_struct.name);
            saveas(cur_fig, [CFG.output_plots_folder_cur, '\Plot_', file_struct.name(1:end-3), 'png'])
            close(cur_fig);
        end
    end