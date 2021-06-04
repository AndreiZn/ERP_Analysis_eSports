%% defaults

exp_names = {'CS_1', 'CS_2', 'CS_3'};

% CS_1
value_CS_1.EEG_sr = 250; value_CS_1.ET_sr = 120; value_CS_1.baseline_period = 0.5;
value_CS_1.im_pres_period = 0.4; value_CS_1.after_im_period = 0.5;

% CS_2
value_CS_2.EEG_sr = 250; value_CS_2.ET_sr = 120; value_CS_2.baseline_period = 0.5;
value_CS_2.im_pres_period = 0.4; value_CS_2.after_im_period = 0.5;

% CS_3
value_CS_3.EEG_sr = 250; value_CS_3.ET_sr = 120; value_CS_3.baseline_period = 0.5;
value_CS_3.im_pres_period = 0.4; value_CS_3.after_im_period = 0.5;

% write values to container
valueSet = {value_CS_1,value_CS_2,value_CS_3};
exp_param = containers.Map(exp_names,valueSet);

%%

root_folder = uigetdir();
sub_folders = dir(root_folder);
dirflag = [sub_folders.isdir] & ~strcmp({sub_folders.name},'..') & ~strcmp({sub_folders.name},'.') & ...
          ~strcmp({sub_folders.name},'.DS_Store') & ~strcmp({sub_folders.name},'.ipynb_checkpoints');
sub_folders = sub_folders(dirflag);

for folder_idx = 1:numel(sub_folders)
    folder = sub_folders(folder_idx);
    folderpath = fullfile(folder.folder, folder.name);
    
    sub_id = str2double(folder.name(4:7));
    
    files = dir(folderpath);
    fileflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(fileflag);
    
    for file_idx = 1:numel(files)
        file = files(file_idx);
        filepath = fullfile(file.folder, file.name);
        if strcmp(file.name(end-3:end), 'tsv')
            movefile(filepath, [filepath(1:end-3), 'csv'], 'f')
            filepath = [filepath(1:end-3), 'csv'];
        end
        
        
        keyboard;
    end
end

%%
sub_id = 5003;
exp_name = 'CS_3';

ET_data = readtable(['./raw_data/raw/eye_sub', num2str(sub_id), '_', exp_name, '.txt']);
% EEG_data = readtable(['sub', num2str(sub_id), '_', exp_name, '_pd_markers.csv']);

EEG_sr = 250; % Hz
ET_sr = 120; % Hz
baseline_period = 0.5; % s
im_pres_period = 0.4; % s
after_im_period = 0.5; % s

stim_name = ET_data.PresentedMediaName;
ET_events = [];
for i = 1:numel(stim_name)
    stim_name_cur = stim_name{i};
    startIndex = regexp(stim_name_cur,'\d');
    
    if i > 2
        startIndex_prev1 = regexp(stim_name{i-1},'\d');
        startIndex_prev2 = regexp(stim_name{i-2},'\d');
    else
        startIndex_prev1 = [];
        startIndex_prev2 = [];
    end
    
    % save event idx
    if ~isempty(startIndex) && isempty(startIndex_prev1) && isempty(startIndex_prev2)
        ET_events = [ET_events, i];
    end
end

ET_markers = zeros(numel(ET_events), 1);
for i = 1:numel(ET_events)
    if mod(str2double(ET_data(ET_events(i), :).PresentedStimulusName{:}), 2) == 0
        ET_markers(i) = 1;
    else
        ET_markers(i) = 2;
    end
end

% position of terrorists' heads in each picture
% target_position = ones(numel(ET_events), 3);
% target_position(:,1) = 1920/2 * target_position(:,1);
% target_position(:,2) = 1080/2 * target_position(:,2);
if strcmp(exp_name, 'CS_3')
    t = csvread('labeling.csv');
%     target_position(ET_markers == 2, 1) = t(:,2);
%     target_position(ET_markers == 2, 2) = t(:,3);
%     target_position(ET_markers == 2, 3) = t(:,1);
else 
    t = [];
end    

% mapping from EyeMovementType to a numerical category
keySet = {'','EyesNotFound','Fixation','Saccade','Unclassified'};
valueSet = [0 1 2 3 4];
M = containers.Map(keySet,valueSet);

n_feat = 7; % distance to target, eye movement type, pupil diameter (average of left and right), marker
n_trials = numel(ET_events);
n_tp = (baseline_period + im_pres_period + after_im_period) * ET_sr;

ET_trial_data = NaN(n_feat, n_trials, n_tp);
for trial_idx = 1:n_trials
    event_idx = ET_events(trial_idx);
    
    event_period_idx = event_idx - round(baseline_period*ET_sr):event_idx + round((im_pres_period + after_im_period)*ET_sr) - 1;
    ET_event_data = ET_data(event_period_idx, :);
    % get features
    if strcmp(exp_name, 'CS_3')
        t_idx = find(t(:,1) == str2double(ET_event_data(61,:).PresentedStimulusName{:}));
    else
        t_idx = [];
    end
    if isempty(t_idx)
        target_position = [1920/2, 1080/2];
    else
        target_position = t(t_idx, 2:3);
    end
    
    % Gaze Point X, Y
    GPX = ET_event_data.GazePointX;
    GPX = fillmissing(GPX,'previous');
    GPX = fillmissing(GPX,'constant', nanmean(GPX));
    GPY = ET_event_data.GazePointY;
    GPY = fillmissing(GPY,'previous');
    GPY = fillmissing(GPY,'constant', nanmean(GPY));
    
    % Distance to target
    GPX_dist_to_targ = ET_event_data.GazePointX - target_position(1);
    GPX_dist_to_targ = fillmissing(GPX_dist_to_targ,'previous');
    GPX_dist_to_targ = fillmissing(GPX_dist_to_targ,'constant', nanmean(GPX));
    GPY_dist_to_targ = ET_event_data.GazePointY - target_position(2);
    GPY_dist_to_targ = fillmissing(GPY_dist_to_targ,'previous');
    GPY_dist_to_targ = fillmissing(GPY_dist_to_targ,'constant', nanmean(GPY));
    assert(sum(isnan(GPX_dist_to_targ(:))) == 0);
    assert(sum(isnan(GPY_dist_to_targ(:))) == 0);
    
    % Distance to the center of the screen
    cent_position = [1920/2, 1080/2];
    GPX_dist_to_cent = ET_event_data.GazePointX - cent_position(1);
    GPX_dist_to_cent = fillmissing(GPX_dist_to_cent,'previous');
    GPX_dist_to_cent = fillmissing(GPX_dist_to_cent,'constant', nanmean(GPX));
    GPY_dist_to_cent = ET_event_data.GazePointY - cent_position(2);
    GPY_dist_to_cent = fillmissing(GPY_dist_to_cent,'previous');
    GPY_dist_to_cent = fillmissing(GPY_dist_to_cent,'constant', nanmean(GPY));
    assert(sum(isnan(GPX_dist_to_cent(:))) == 0);
    assert(sum(isnan(GPY_dist_to_cent(:))) == 0);
    
    EMT = NaN(numel(event_period_idx), 1);
    for j = 1:numel(event_period_idx)
        EMT(j) = M(ET_event_data(j,:).EyeMovementType{:});
    end
    assert(sum(isnan(EMT(:))) == 0);
    
    PDL = NaN(numel(event_period_idx), 1);
    for j = 1:numel(event_period_idx)
        tmp = ET_event_data(j,:).PupilDiameterLeft{:};
        if isempty(tmp)
            PDL(j) = NaN;
        else
            PDL(j) = str2double(tmp(1)) + 0.1*str2double(tmp(3)) + 0.01*str2double(tmp(4));
        end
    end
    PDL = fillmissing(PDL,'previous');
    PDL = fillmissing(PDL,'constant',nanmean(PDL));
    assert(sum(isnan(PDL(:))) == 0);
    
    PDR = NaN(numel(event_period_idx), 1);
    for j = 1:numel(event_period_idx)
        tmp = ET_event_data(j,:).PupilDiameterRight{:};
        if isempty(tmp)
            PDR(j) = NaN;
        else
            PDR(j) = str2double(tmp(1)) + 0.1*str2double(tmp(3)) + 0.01*str2double(tmp(4));
        end
    end
    PDR = fillmissing(PDR,'previous');
    PDR = fillmissing(PDR,'constant',nanmean(PDR));
    assert(sum(isnan(PDR(:))) == 0);

    LBL = mod(str2double(ET_data(event_idx, :).PresentedMediaName{:}(1:end-4)), 2) + 1;
    LBL = LBL*ones(numel(event_period_idx), 1);
    
    IM = str2double(ET_event_data(61,:).PresentedStimulusName{:}) * ones(numel(event_period_idx), 1);
    assert(sum(isnan(IM(:))) == 0);
    
    % save features
    ET_trial_data(1, trial_idx, :) = sqrt(GPX_dist_to_targ.^2 + GPY_dist_to_targ.^2);
    ET_trial_data(2, trial_idx, :) = EMT;
    ET_trial_data(3, trial_idx, :) = 0.5*(PDL + PDR);
    ET_trial_data(4, trial_idx, :) = LBL;
    ET_trial_data(5, trial_idx, :) = GPX;
    ET_trial_data(6, trial_idx, :) = GPY;
    ET_trial_data(7, trial_idx, :) = IM;
    ET_trial_data(8, trial_idx, :) = sqrt(GPX_dist_to_cent.^2 + GPY_dist_to_cent.^2);
end
assert(sum(isnan(ET_trial_data(:))) == 0);

save(['./output/ET_features_sub', num2str(sub_id), '_', exp_name, '.mat'], 'ET_trial_data')


%% change the sample rate of EEG data
sub_id = 5003;
exp = '3';
exp_name_EEG = ['4_1_', exp];
exp_name_ET = ['CS_', exp];

a = load(['./raw_data/postproc/sub', num2str(sub_id), '_', exp_name_EEG, '_EEG_postproc.mat']);
EEG = a.eeg_data;

ET_data = load(['./output/ET_features_sub', num2str(sub_id), '_', exp_name_ET, '.mat']);
ET_data = ET_data.ET_trial_data;

n_ch = size(EEG, 1);
n_trials = size(EEG, 3);
n_ts_ET = size(ET_data, 3);

EEG_comp = zeros(n_ch, n_trials, n_ts_ET);
for ch_idx = 1:n_ch
    for trial_idx = 1:n_trials
        EEG_comp(ch_idx, trial_idx, :) = compress_EEG(EEG(ch_idx, :, trial_idx), n_ts_ET);
    end
end

% combine postprocessed data
data = [EEG_comp; ET_data];
save(['sub', num2str(sub_id), '_', exp_name, '_EEG_ET_combined.mat'], 'data');

% EEG_full = EEG_data.EEGCh30(55390:55489);
% EEG_trial_ts = numel(EEG_full);
% ET_full = ET_data.GazePointX(15229:15276);
% ET_trial_ts = numel(ET_full);
% 
% EEG_exp = zeros(EEG_trial_ts*ET_trial_ts, 1);
% 
% % expand EEG data
% for time_p_idx = 1:EEG_trial_ts
%     idx = 1 + (time_p_idx-1)*ET_trial_ts:ET_trial_ts + (time_p_idx-1)*ET_trial_ts;
%     
%     if time_p_idx ~= EEG_trial_ts
%         alpha = (EEG_full(time_p_idx+1) - EEG_full(time_p_idx))/ET_trial_ts;
%         t_points = 0:ET_trial_ts-1;
%         EEG_exp(idx) = EEG_full(time_p_idx)*ones(ET_trial_ts,1) + alpha*t_points';
%     else
%         EEG_exp(idx) = EEG_full(time_p_idx)*ones(ET_trial_ts,1);
%     end
% end
% 
% EEG_averaged = zeros(ET_trial_ts, 1);
% % average EEG data
% for time_p_idx = 1:ET_trial_ts
%     idx = 1 + (time_p_idx-1)*EEG_trial_ts:EEG_trial_ts + (time_p_idx-1)*EEG_trial_ts;
%     EEG_averaged(time_p_idx) = mean(EEG_exp(idx));
% end


%% Annotate images
% 
% select a root folder
root_folder = '/Users/andreizn/Desktop/Skoltech_PhD/Projects/eSports_project/EEG+eye_tracker data/stimuli/'; %[uigetdir('./','Select a root folder...'), filesep]; 

% run through images
im_files = dir(root_folder); 
fileflag = ~[im_files.isdir] & ~strcmp({im_files.name},'..') & ~strcmp({im_files.name},'.') & ~strcmp({im_files.name},'.DS_Store');
im_files = im_files(fileflag);
for im_idx = 1:2:numel(im_files)
    % read image with a terroris
    im = im_files(im_idx);
    im = [im.folder, filesep, im.name];
    I = imread(im); % 1080 x 1920 x 3 image
    h = min(size(I,1), size(I,2)); 
    w = max(size(I,1), size(I,2));
    
    imshow(I);
    hold on
    
    trial_idx = find(squeeze(ET_data(7, :, 1)) == str2double(im_files(im_idx).name(3:7)));
    scatter(ET_data(5, trial_idx, 1:end), ET_data(6, trial_idx, 1:end))
    
    keyboard;  
end

%% functions 

function EEG_averaged = compress_EEG(EEG_trial, ET_trial_ts)
    EEG_full = zeros(1.4*250, 1);
    EEG_full(2:end-2) = EEG_trial;
    EEG_trial_ts = numel(EEG_full);
    
    EEG_comp = zeros(EEG_trial_ts*ET_trial_ts, 1);
    
    % compress EEG data
    for time_p_idx = 1:EEG_trial_ts
        idx = 1 + (time_p_idx-1)*ET_trial_ts:ET_trial_ts + (time_p_idx-1)*ET_trial_ts;

        if time_p_idx ~= EEG_trial_ts
            alpha = (EEG_full(time_p_idx+1) - EEG_full(time_p_idx))/ET_trial_ts;
            t_points = 0:ET_trial_ts-1;
            EEG_comp(idx) = EEG_full(time_p_idx)*ones(ET_trial_ts,1) + alpha*t_points';
        else
            EEG_comp(idx) = EEG_full(time_p_idx)*ones(ET_trial_ts,1);
        end
    end
     
    EEG_averaged = zeros(ET_trial_ts, 1);
    % average EEG data
    for time_p_idx = 1:ET_trial_ts
        idx = 1 + (time_p_idx-1)*EEG_trial_ts:EEG_trial_ts + (time_p_idx-1)*EEG_trial_ts;
        EEG_averaged(time_p_idx) = mean(EEG_comp(idx));
    end
        
end

