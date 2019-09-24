function CFG = define_defaults()

CFG = [];
CFG.sample_rate = 250;

CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning by default
CFG.end_cut_at_idx = 3000; % where to cut original data at the end by default

CFG.time_channel = 1;
CFG.EEG_channels = 2:33;
CFG.total_num_channels = numel(CFG.EEG_channels);
CFG.trigger_channel = 34;
CFG.target_channel = 35;
CFG.groupid_channel = 36;
gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);
