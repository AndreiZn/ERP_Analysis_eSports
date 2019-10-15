% EEGLAB history file generated on the 15-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','sub0022_2_2_5_after_ICA.set','filepath','E:\\ERP_esports\\ERP_esports_data\\sub0022_20190407\\');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_subcomp( EEG, [1  2], 0);
EEG = eeg_checkset( EEG );
