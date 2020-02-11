% shift_groupid function works with 01_ERP_data_cut data folder
% Shift groupid by observed latency CFG.groupid_latency_ms
function CFG = shift_groupid(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = 'stage_1_shift\data';
CFG.output_plots_folder_name = 'stage_1_shift\plots';

CFG.output_data_folder = [CFG.output_folder_path, filesep, CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, filesep, CFG.output_plots_folder_name];
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
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(dirflag);
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        file = load(filepath);
        y = file.y_cut; bad_ch_idx = file.bad_ch_idx; bad_ch_lbl = file.bad_ch_lbl;
        file_name = file_struct.name(1:end-4);
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end
        
        % read groupid and get the required shift
        groupid = y(CFG.groupid_channel, :);
        shift_ts = CFG.sample_rate * CFG.groupid_latency_ms/1000;
        % form new indices
        new_idx = shift_ts+1:size(groupid,2);
        new_groupid = [groupid(1,new_idx), zeros(1,shift_ts)];
        y(CFG.groupid_channel, :) = new_groupid;
        
        cur_fig = figure();
        plot(groupid);
        hold on
        plot(y(CFG.groupid_channel, :))
        legend('old groupid', 'new groupid')
        % save plot
        saveas(cur_fig, [CFG.output_plots_folder_cur, '\Plot_', file_struct.name(1:end-3), 'png'])
        close(cur_fig);
        
        % to keep processing pipeline consistent, it's easier to save y as
        % y_cut for the next script
        y_cut = y;
        
        % save cut_data and bad_chs
        save([CFG.output_data_folder_cur, filesep, file_struct.name, '_shifted_groupid'], 'y_cut', 'bad_ch_idx', 'bad_ch_lbl')
    end
end