function CFG = define_defaults()

CFG = [];
CFG.sample_rate = 250;

CFG.total_num_channels = 8;
CFG.time_channel = 0;
CFG.EEG_channels = 1:8;
CFG.total_num_data_channels = numel(CFG.EEG_channels);
CFG.trigger_channel = 0;
CFG.target_channel = 0;
CFG.groupid_channel = 0;
CFG.DI_channel = 0;
CFG.ard_channel = 0;
gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);
CFG.groupid_latency_ms = 736; % ms, latency of recorded groupdid
CFG.base_station_latency_ms = 222; % ms, latency of the base station of g.Nautilus

%% Select a root folder (it implies that the root folder will contain the code, data and output folders
CFG.root_folder = uigetdir('./','Select a root folder...');

%% load sample eeglab file to extract channel labels
sample_file = dir(fullfile(CFG.root_folder, '**', 'sample_set.set'));
EEG = pop_loadset('filename','sample_set.set','filepath',sample_file.folder);
CFG.ch_labels = {EEG.chanlocs.labels};

%% Electrode location file
electrode_location_file_struct = dir(fullfile(CFG.root_folder, '**', 'gUnicorncap8ch_10-20.locs'));
if numel(electrode_location_file_struct)
    electrode_location_file_struct = electrode_location_file_struct(1);
end
CFG.electrode_location_file = fullfile(electrode_location_file_struct.folder, electrode_location_file_struct.name);

%% Experiment specific variables
keySet = {'1_1_1','1_1_2','1_2_2','2_2_2','2_2_4','2_2_5'}; %,'32_5L','32_5R'

value_1_1_1.epoch_boundary_s = [-0.2 0.7]; value_1_1_1.baseline_ms = [-200 0]; value_1_1_1.ERP_bins = [1];
value_1_1_1.event_type = {'chan36'}; value_1_1_1.event_name = {'bin1_target'};
value_1_1_1.amplitude_limit = [-7.5, 7.5];
value_1_1_1.snr_cut = 1.2; value_1_1_1.autocorr_cut = 0.4;
value_1_1_1.event_length = 0.25;
value_1_1_1.target_spacer_s = 0;

value_1_1_2.epoch_boundary_s = [-0.2 0.45]; value_1_1_2.baseline_ms = [-200 0]; value_1_1_2.ERP_bins = [1 2];
value_1_1_2.event_type = {{'1'}; {'2'}}; value_1_1_2.event_name = {'bin1_target', 'bin2_non-target'};
value_1_1_2.amplitude_limit = [-7.5, 7.5];
value_1_1_2.snr_cut = 1.2; value_1_1_2.autocorr_cut = 0.4;
value_1_1_2.event_length = 0.25;
value_1_1_2.target_spacer_s = 0.25;

value_1_2_2.epoch_boundary_s = [-0.2 0.7]; value_1_2_2.baseline_ms = [-200 0]; value_1_2_2.ERP_bins = [1 2];
value_1_2_2.event_type = {{'1'}; {'2'}}; value_1_2_2.event_name = {'bin1_target', 'bin2_non-target'};
value_1_2_2.amplitude_limit = [-5, 5];
value_1_2_2.snr_cut = 1.5; value_1_2_2.autocorr_cut = 0.5;
value_1_2_2.event_length = 0.25;
value_1_2_2.target_spacer_s = 0.5;

value_2_2_2.epoch_boundary_s = [-0.2 0.7]; value_2_2_2.baseline_ms = [-200 0]; value_2_2_2.ERP_bins = [1 2];
value_2_2_2.event_type = {{'8','9','10','11','12','13','14'}; {'1','2','3','4','5','6','7'}}; value_2_2_2.event_name = {'bin1_target', 'bin2_non-target'};
value_2_2_2.amplitude_limit = [-15, 15];
value_2_2_2.snr_cut = 1.5; value_2_2_2.autocorr_cut = 0.5;
value_2_2_2.event_length = 0.4;
value_2_2_2.target_spacer_s = 0.5;

value_2_2_4.epoch_boundary_s = [-0.2 0.7]; value_2_2_4.baseline_ms = [-200 0]; value_2_2_4.ERP_bins = [1 2];
value_2_2_4.event_type = {{'8','9','10','11','12','13','14'}, {'1','2','3','4','5','6','7'}}; value_2_2_4.event_name = {'bin1_target', 'bin2_non-target'};
value_2_2_4.amplitude_limit = [-15, 15];
value_2_2_4.snr_cut = 1.5; value_2_2_4.autocorr_cut = 0.5;
value_2_2_4.event_length = 0.4;
value_2_2_4.target_spacer_s = 0.5;

value_2_2_5.epoch_boundary_s = [-0.2 0.7]; value_2_2_5.baseline_ms = [-200 0]; value_2_2_5.ERP_bins = [1 2];
value_2_2_5.event_type = {{'1','2','3','4','5'}, {'6','7','8','9','10'}}; value_2_2_5.event_name = {'bin1_target', 'bin2_non-target'};
value_2_2_5.amplitude_limit = [-15, 15];
value_2_2_5.snr_cut = 1.5; value_2_2_5.autocorr_cut = 0.5;
value_2_2_5.event_length = 0.4;
value_2_2_5.target_spacer_s = 0.5;

valueSet = {value_1_1_1,value_1_1_2,value_1_2_2,value_2_2_2,value_2_2_4,value_2_2_5};
CFG.exp_param = containers.Map(keySet,valueSet);

%% Folder for ERPLAB experiments' decription files
folder_name = 'ERPLAB_exp_description_files';
temp = dir(fullfile(CFG.root_folder, '**', folder_name, '.'));
CFG.erplab_files_folder = temp.folder;

%% Define (or select manually) code, data and output folders
cell_root_folder = split(CFG.root_folder, filesep);
root_folder_name = cell_root_folder{end};
%code_folder_name = [root_folder_name(3:end), '_code'];
data_folder_name = ['2_', root_folder_name(3:end), '_data'];
output_folder_name = ['3_', root_folder_name(3:end), '_output'];

%code_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, code_folder_name}, filesep);
data_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, data_folder_name}, filesep);
output_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, output_folder_name}, filesep);

answer = questdlg('Use default locations of code, data and output folders?', 'Location of other folders', ...
    'Yes', 'No', 'Yes');
switch answer
    case 'Yes'
        %CFG.code_folder_path = code_folder_path;
        CFG.data_folder_path = data_folder_path;
        CFG.output_folder_path = output_folder_path;
    case 'No'
        CFG.code_folder_path = uigetdir('./','Select a code folder...');
        CFG.data_folder_path = uigetdir('./','Select a data folder...');
        CFG.output_folder_path = uigetdir('./','Select an output folder...');
end