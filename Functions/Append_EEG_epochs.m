function [EEG_output] = Append_EEG_epochs(EEG, stim_duration_ms, sampling_rate, target_type, set_name, output_folder_cur)

EEG_data = EEG.data;
num_channels = size(EEG_data, 1);
num_trials = size(EEG_data, 3);

stim_duration_smp = round(stim_duration_ms/1000*sampling_rate);
trig_time_smp = find(EEG.times == 0);

target_channel = zeros(1, size(EEG_data, 2), num_trials);
non_target_channel = zeros(1, size(EEG_data, 2), num_trials);

event_per_trial = EEG.urevent;
for trial_idx = 1:num_trials
    event_type = event_per_trial(1,trial_idx).type;
    if ismember(event_type, target_type)
        target_channel(1, trig_time_smp:trig_time_smp+stim_duration_smp, trial_idx) = 1;
    else 
        non_target_channel(1, trig_time_smp:trig_time_smp+stim_duration_smp, trial_idx) = 1;
    end
end
EEG_keep_trials = ~logical(EEG.reject.rejmanual);
EEG_data_good_trials = EEG_data(:, :, EEG_keep_trials);
target_channel_good_trials = target_channel(:, :, EEG_keep_trials);
non_target_channel_good_trials = non_target_channel(:, :, EEG_keep_trials);

EEG_data_appended = EEG_data_good_trials(1:num_channels, :);
EEG_time_ms = 0:1:size(EEG_data_appended, 2)-1;
EEG_time_ms = EEG_time_ms/sampling_rate;
target_channel_appended = target_channel_good_trials(1, :);
non_target_channel_appended = non_target_channel_good_trials(1, :);

EEG_output = [EEG_time_ms; EEG_data_appended; target_channel_appended; non_target_channel_appended];

filename = [output_folder_cur, 'EEG_data_after_ERPLAB_', set_name];
save(filename, 'EEG_output')