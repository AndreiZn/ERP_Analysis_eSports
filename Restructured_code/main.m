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
import_mat_to_eeglab_flag = 0;
if import_mat_to_eeglab_flag
    [CFG, EEG] = import_data(CFG);
end

flag = 1;
if flag
    [CFG, EEG] = preICA(CFG);
end

%% Run ICA (run ICA, save weight, save bad components)

%% Level-1 analysis (within subject study)

%% Level-2 analysis (group study)

