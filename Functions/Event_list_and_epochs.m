function [EEG] = Event_list_and_epochs(EEG, epoch_boundary, elist_path, set_name, output_suffix, output_folder_cur)

EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', elist_path, 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning', 'on' ); % GUI: 25-Apr-2019 02:20:01
EEG = pop_overwritevent( EEG, 'codelabel');
EEG = eeg_checkset( EEG );

EEG = pop_epochbin( EEG , epoch_boundary,  'pre'); % GUI: 25-Apr-2019 01:43:10
EEG = eeg_checkset( EEG );
output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);