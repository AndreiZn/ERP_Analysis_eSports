%% Remove bad components

%% Remove bad trials

%% Combine epochs into one epoch

%% Load Eventlist and split data into epochs
output_suffix = 'be';
elist_name = ['elist_', cur_exp_id, '_short.txt'];
elist_path = [ERPLAB_scripts_folder, 'Exp_', cur_exp_id, '\', elist_name];
[EEG] = Event_list_and_epochs(EEG, epoch_boundary, elist_path, set_name, output_suffix, output_folder_cur);
EEG = eeg_checkset( EEG );

%% Compute ERPs
[ERP] = Compute_averaged_ERP(EEG, set_name, output_folder_cur);
%% Plot ERPs
if plot_ERP_flag
    [ERP] = Plot_ERP_waveforms(ERP, EEG.nbchan, epoch_boundary, ar_rm_from_ch, set_name, output_folder_cur, plot_animation_flag);
end
%% Plot ERP images
if plot_ERP_Im_flag
    for channel_idx = 1:EEG.nbchan
        Plot_ERP_Image(EEG, target_bin, set_name, output_folder_cur, channel_idx)
    end
end

function [EEG] = Event_list_and_epochs(EEG, epoch_boundary, elist_path, set_name, output_suffix, output_folder_cur)

EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', elist_path, 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning', 'on' ); % GUI: 25-Apr-2019 02:20:01
EEG = pop_overwritevent( EEG, 'codelabel');
EEG = eeg_checkset( EEG );

EEG = pop_epochbin( EEG , epoch_boundary,  'pre'); % GUI: 25-Apr-2019 01:43:10
EEG = eeg_checkset( EEG );
output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);

end
