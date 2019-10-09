% Main script - analysis of Event related potentials for the eSports
% project

%% Define default variables
CFG = define_defaults();

%% Visually inspect data (mark datasets clearly not appropriate for
% analysis, cut beginning and end of datafiles, mark clearly bad channels)
cut_data_flag = 0;
if cut_data_flag
    CFG = cut_data(CFG);
end

%% PreICA (import, rereference, filter, etc.)
convert_mat_to_eeglab_flag = 0;
if convert_mat_to_eeglab_flag
    [CFG, EEG] = convert_data(CFG);
end

rereference_and_filter_flag = 0;
if rereference_and_filter_flag
    [CFG, EEG] = reref_and_filter(CFG);
end

% add epoching, baseline correction and trial rejection (review mike
% cohen's lecture

% save datasets after trial rejection (folder 06_...)

% run ICA

% save datasets with ICA weights  (folder 07_...)

% delete bad components/trials (review the lecture)

% convert datasets to continuous EEG

% save resulting datasets (folder 08_...)

%% Run ICA (run ICA, save weight, save bad components)

%% Level-1 analysis (within subject study)

%% Level-2 analysis (group study)

