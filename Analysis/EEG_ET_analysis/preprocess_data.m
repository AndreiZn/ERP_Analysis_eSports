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
value_CS_3.im_pres_period = 0.8; value_CS_3.after_im_period = 0.5;

% write values to container
valueSet = {value_CS_1,value_CS_2,value_CS_3};
exp_param = containers.Map(exp_names,valueSet);

%% preprocess ET data

root_folder = uigetdir('./', 'Select data root folder');
ouput_folder = uigetdir('./', 'Select data output folder');
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
    
    fileflag = false(numel(files),1);
    for idx=1:numel(files)
        fileflag(idx, 1) = ~isempty(regexp(files(idx).name, 'eye_sub[0-9][0-9][0-9][0-9]_CS_[1-3] Data.*tsv', 'once')) + ~isempty(regexp(files(idx).name, 'eye_sub[0-9][0-9][0-9][0-9]_CS_[1-3] Data.*csv', 'once'));
    end
    files = files(fileflag);
    
    for file_idx = 1:numel(files)
        file = files(file_idx);
        filepath = fullfile(file.folder, file.name);
        if strcmp(file.name(end-2:end), 'tsv')
            movefile(filepath, [filepath(1:end-3), 'csv'], 'f')
            filepath = [filepath(1:end-3), 'csv'];
        end
        
        % get experiment name
        tmp_idx = strfind(file.name, 'CS_');
        if ~isempty(tmp_idx)
            exp_name = file.name(tmp_idx:tmp_idx+3);
        end
        
        
        % split eye-tracking (ET) data by trial
        if strcmp(file.name(1:3), 'eye') && strcmp(file.name(13:16), exp_name)
            % print sub id and experiment name
            disp(['sub: ', num2str(sub_id), ', exp: ', exp_name, ' ET data'])
            CFG = exp_param(exp_name);
            ET_trial_data = preprocess_ET_data(filepath, exp_name, CFG);
            
            % save processed ET data
            % get sub folder name
            path = split(file.folder, '/');
            sub_fld_name = path(end);
            sub_fld_name = sub_fld_name{:};
            % generate folder path
            output_folder_sub = [ouput_folder, '/', sub_fld_name, '/'];
            % make dir if it doesn't exist
            if ~exist(output_folder_sub, 'dir')
                mkdir(output_folder_sub)
            end
            % save file
            save([output_folder_sub, 'eye_sub', num2str(sub_id), '_', exp_name, '.mat'], 'ET_trial_data');
        end
        
    end
end

%% change the sample rate of EEG data and combine it with ET data

% EEG_root_folder = uigetdir('./', 'Select EEG data root folder');
% ET_root_folder = uigetdir('./', 'Select ET data root folder');
% ouput_folder = uigetdir('./', 'Select data output folder');

EEG_sub_folders = dir(EEG_root_folder);
dirflag = [EEG_sub_folders.isdir] & ~strcmp({EEG_sub_folders.name},'..') & ~strcmp({EEG_sub_folders.name},'.') & ...
          ~strcmp({EEG_sub_folders.name},'.DS_Store') & ~strcmp({EEG_sub_folders.name},'.ipynb_checkpoints');
EEG_sub_folders = EEG_sub_folders(dirflag);

ET_sub_folders = dir(ET_root_folder);
dirflag = [ET_sub_folders.isdir] & ~strcmp({ET_sub_folders.name},'..') & ~strcmp({ET_sub_folders.name},'.') & ...
          ~strcmp({ET_sub_folders.name},'.DS_Store') & ~strcmp({ET_sub_folders.name},'.ipynb_checkpoints');
ET_sub_folders = ET_sub_folders(dirflag);

n_folders = min(numel(EEG_sub_folders), numel(ET_sub_folders));

for folder_idx = 1:n_folders
    EEG_folder = EEG_sub_folders(folder_idx);
    EEG_folderpath = fullfile(EEG_folder.folder, EEG_folder.name);
    sub_id_EEG = str2double(EEG_folder.name(4:7));
    
    ET_folder = ET_sub_folders(folder_idx);
    ET_folderpath = fullfile(ET_folder.folder, ET_folder.name);
    sub_id_ET = str2double(ET_folder.name(4:7));
    
    if sub_id_EEG == sub_id_ET
        sub_id = sub_id_EEG;
    else
        disp('sub ids of EEG and ET folders are not equal')
        break
    end
    
    EEG_files = dir(EEG_folderpath);
    fileflag = ~[EEG_files.isdir] & ~strcmp({EEG_files.name},'..') & ~strcmp({EEG_files.name},'.') & ~strcmp({EEG_files.name},'.DS_Store');
    EEG_files = EEG_files(fileflag);
    
    ET_files = dir(ET_folderpath);
    fileflag = ~[ET_files.isdir] & ~strcmp({ET_files.name},'..') & ~strcmp({ET_files.name},'.') & ~strcmp({ET_files.name},'.DS_Store');
    ET_files = ET_files(fileflag);
    
    for exp_idx = 1:3
        
        if (exp_idx == 2 && sub_id == 3003) || (exp_idx == 1 && sub_id == 3007)
            continue
        end
        
        % find EEG data file
        fileflag = false(numel(EEG_files),1);
        for idx=1:numel(EEG_files)
            exp = ['4_1_', int2str(exp_idx)];
            fileflag(idx, 1) = ~isempty(regexp(EEG_files(idx).name, ['sub[0-9][0-9][0-9][0-9]_', exp, '_EEG_cleaned.mat'], 'once'));
        end
        
        disp(['sub: ', num2str(sub_id), ', exp: ', exp, ' combining data'])
        
        EEG_file1 = EEG_files(fileflag);
        EEG_file1 = load(fullfile(EEG_file1.folder, EEG_file1.name));
        EEG_data = EEG_file1.EEG_data;
        
        % find EEG trigger file
        fileflag = false(numel(EEG_files),1);
        for idx=1:numel(EEG_files)
            exp = ['4_1_', int2str(exp_idx)];
            exp_CS = ['CS_', int2str(exp_idx)];
            fileflag(idx, 1) = ~isempty(regexp(EEG_files(idx).name, ['sub[0-9][0-9][0-9][0-9]_', exp, '_trigger_channel.mat'], 'once'));
        end
        EEG_file2 = EEG_files(fileflag);
        EEG_file2 = load(fullfile(EEG_file2.folder, EEG_file2.name));
        EEG_trigger = EEG_file2.EEG_trigger;
        
        ET_data = load(fullfile(ET_files(exp_idx).folder, ET_files(exp_idx).name));
        ET_data = ET_data.ET_trial_data;
        
        n_ch = size(EEG_data, 1);
        n_trials = size(EEG_data, 3);
        n_ts_ET = size(ET_data, 3);
        
        EEG_comp = zeros(n_ch, n_trials, n_ts_ET);
        for ch_idx = 1:n_ch
            for trial_idx = 1:n_trials
                parameters = exp_param(exp_CS);
                EEG_comp(ch_idx, trial_idx, :) = compress_EEG(EEG_data(ch_idx, :, trial_idx), n_ts_ET, parameters);
            end
        end
        
        % combine compressed EEG data, trigger channel and ET data
        EEG_trigger_channel = zeros(1, n_trials, n_ts_ET);
        for trial_idx = 1:n_trials
            EEG_trigger_channel(1, trial_idx, :) = EEG_trigger(trial_idx);
        end
        
        n_total_ch = n_ch + 1 + size(ET_data, 1);
        combined_data = NaN(n_total_ch, n_trials, n_ts_ET);
        combined_data(1:32, :, :) = EEG_comp;
        combined_data(33, :, :) = EEG_trigger_channel;
        combined_data(34:end, :, :) = ET_data;
        
        % save combined data
        % get sub folder name
        path = split(EEG_files(fileflag).folder, '/');
        sub_fld_name = path(end);
        sub_fld_name = sub_fld_name{:};
        % generate folder path
        output_folder_sub = [ouput_folder, '/', sub_fld_name, '/'];
        % make dir if it doesn't exist
        if ~exist(output_folder_sub, 'dir')
            mkdir(output_folder_sub)
        end
        % save file
        save([output_folder_sub, 'sub', num2str(sub_id), '_', exp, '_EEG_ET.mat'], 'combined_data');
        
    end  
end

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

%% auxiliary functions 

% read eye-tracking (ET) data, calculate features for each trial, output ET
% trial data
function ET_trial_data = preprocess_ET_data(ET_filepath, exp_name, CFG)
    
    after_im_period = CFG.after_im_period;
    baseline_period = CFG.baseline_period;
    im_pres_period = CFG.im_pres_period;
    ET_sr = CFG.ET_sr;
    
    ET_data = readtable(ET_filepath);
    % EEG_data = readtable(['sub', num2str(sub_id), '_', exp_name, '_pd_markers.csv']);

    stim_name = ET_data.PresentedMediaName;
    ET_events = [];
    for i = 1:numel(stim_name)
        stim_name_cur = stim_name{i};
        if strcmp(stim_name_cur, 'Plus (1).png')
            stim_name_cur = 'Plus.png';
        end
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
            tmp = ET_event_data(j,:).PupilDiameterLeft;
            if isnumeric(tmp)
                PDL(j) = tmp;
            else
                tmp = ET_event_data(j,:).PupilDiameterLeft{:};
                if isempty(tmp)
                    PDL(j) = NaN;
                else
                    PDL(j) = str2double(tmp(1)) + 0.1*str2double(tmp(3)) + 0.01*str2double(tmp(4));
                end
            end
        end
        PDL = fillmissing(PDL,'previous');
        PDL = fillmissing(PDL,'constant',nanmean(PDL));
        assert(sum(isnan(PDL(:))) == 0);

        PDR = NaN(numel(event_period_idx), 1);
        for j = 1:numel(event_period_idx)
            tmp = ET_event_data(j,:).PupilDiameterRight;
            if isnumeric(tmp)
                PDR(j) = tmp;
            else
                tmp = ET_event_data(j,:).PupilDiameterRight{:};
                if isempty(tmp)
                    PDR(j) = NaN;
                else
                    PDR(j) = str2double(tmp(1)) + 0.1*str2double(tmp(3)) + 0.01*str2double(tmp(4));
                end
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

end

function EEG_averaged = compress_EEG(EEG_trial, ET_trial_ts, params)
    
    trial_time = params.EEG_sr * (params.baseline_period + params.im_pres_period + params.after_im_period);
    if abs(trial_time - numel(EEG_trial)) > 5
        error('trial time and EEG_trial trial time values are different')
    end
    trial_time = numel(EEG_trial);
    EEG_full = zeros(trial_time, 1);
%     EEG_full(2:end-2) = EEG_trial;
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

