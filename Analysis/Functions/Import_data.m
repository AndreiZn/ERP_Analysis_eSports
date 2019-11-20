function [EEG] = Import_data(exp_file_path, set_name, sub_ID, output_suffix, output_folder_cur, sampling_rate, electrode_location_file)

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',exp_file_path,'setname',set_name,'srate',sampling_rate,'subject',sub_ID,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG = pop_chanevent(EEG, 36,'edge','leading','edgelen',0);
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'channel',[2:33] );
EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'chanlocs', electrode_location_file);
EEG = eeg_checkset( EEG );
output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);
EEG = eeg_checkset( EEG );