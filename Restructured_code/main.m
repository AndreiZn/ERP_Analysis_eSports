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
% convert matlab *.mat files to eeglab datasets *.set 
convert_mat_to_eeglab_flag = 0;
if convert_mat_to_eeglab_flag
    [CFG, EEG] = convert_data(CFG);
end

% interpolate + rereference (CAR) + filter data
interpolate_rereference_and_filter_flag = 0;
if interpolate_rereference_and_filter_flag
    [CFG, EEG] = intrp_reref_and_filter(CFG);
end

% add epoching and perform soft trial rejection (remove trials where the
% data clearly have no brain signal or where the subject blinked just
% before or during the stimuli presentation)

% baseline correction is not performed at this step as suggested at Makoto's preprocessing pipeline 
% https://sccn.ucsd.edu/wiki/Makoto%27s_preprocessing_pipeline#Run_ICA_.2806.2F26.2F2018_updated.29
% (If you extract data epochs before running ICA, make sure that the baseline is long enough (at least 500 ms) or that you do not remove the baseline from your data epochs. 
% See the following article for more information: Groppe, D.M., Makeig, S., & Kutas, M. (2009) Identifying reliable independent components via split-half comparisons. NeuroImage, 45 pp.1199-1211
reject_trials_flag = 0;
if reject_trials_flag
    % run reject_trials as a separate script
    reject_trials(CFG);
end

%% Run ICA (run ICA, save weights, mark bad components)
% run ICA
runICA_flag = 1;
if runICA_flag
    CFG = runICA(CFG);
end

% look through independent components and reject bad ones (look up the
% tutorial for examples)
reject_IC_flag = 0;
if reject_IC_flag
    % run reject_IC as a separate script
    reject_IC();
end

% convert datasets to continuous EEG

% save resulting datasets (folder 08_...)
%% Level-1 analysis (within subject study)

%% Level-2 analysis (group study)

