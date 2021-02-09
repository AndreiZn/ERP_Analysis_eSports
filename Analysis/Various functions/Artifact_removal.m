function [EEG] = Artifact_removal(EEG, epoch_boundary, ar_rm_from_ch, mwpp_thld, tstep_thld, set_name, output_suffix, output_folder_cur)

EEG  = pop_artmwppth( EEG , 'Channel',  ar_rm_from_ch:EEG.nbchan, 'Flag', [ 1 3], 'Threshold',  mwpp_thld, 'Twindow', epoch_boundary, 'Windowsize',  200, 'Windowstep',...
  50 ); % GUI: 25-Apr-2019 13:26:15

EEG  = pop_artstep( EEG , 'Channel',  ar_rm_from_ch:EEG.nbchan, 'Flag', [ 1 5], 'Threshold',  tstep_thld, 'Twindow', epoch_boundary, 'Windowsize',  400, 'Windowstep',...
  10 ); % GUI: 25-Apr-2019 13:28:12

output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);
EEG = pop_summary_AR_eeg_detection(EEG, [output_folder_cur, 'AR_summary_', set_name, '.txt']);