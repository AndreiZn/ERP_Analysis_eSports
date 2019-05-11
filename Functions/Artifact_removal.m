function [EEG] = Artifact_removal(EEG, set_name, output_suffix, output_folder_cur)

EEG  = pop_artmwppth( EEG , 'Channel',  8:32, 'Flag', [ 1 3], 'Threshold',  80, 'Twindow', [ -200 748], 'Windowsize',  200, 'Windowstep',...
  50 ); % GUI: 25-Apr-2019 13:26:15

EEG  = pop_artstep( EEG , 'Channel',  8:32, 'Flag', [ 1 5], 'Threshold',  50, 'Twindow', [ -200 748], 'Windowsize',  400, 'Windowstep',...
  10 ); % GUI: 25-Apr-2019 13:28:12

output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);
EEG = pop_summary_AR_eeg_detection(EEG, [output_folder_cur, 'AR_summary_', set_name, '.txt']);