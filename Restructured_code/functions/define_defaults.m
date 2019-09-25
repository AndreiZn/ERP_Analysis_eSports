function CFG = define_defaults()

CFG = [];
CFG.sample_rate = 250;

CFG.time_channel = 1;
CFG.EEG_channels = 2:33;
CFG.total_num_channels = numel(CFG.EEG_channels);
CFG.trigger_channel = 34;
CFG.target_channel = 35;
CFG.groupid_channel = 36;
gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);

%% Select a root folder (it implies that the root folder will contain the code, data and output folders
CFG.root_folder = uigetdir('./','Select a root folder...');

%% load sample eeglab file to extract channel labels
sample_file = dir(fullfile(CFG.root_folder, '**', 'sample_set.set'));
EEG = pop_loadset('filename','sample_set.set','filepath',sample_file.folder);
CFG.ch_labels = {EEG.chanlocs.labels};