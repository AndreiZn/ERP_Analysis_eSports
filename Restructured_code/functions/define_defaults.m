function CFG = define_defaults()

CFG = [];
CFG.sample_rate = 250;

% load sample eeglab file to extract channel labels
sample_file = dir(fullfile(CFG.root_folder, '**', 'sample_set.set'));
EEG = pop_loadset('filename','sample_set.set','filepath',sample_file.folder);
CFG.ch_labels = {EEG.chanlocs.labels};

CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning by default
CFG.end_cut_at_idx = 3000; % where to cut original data at the end by default
CFG.total_num_channels = 32;
gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);
