% EEGLAB history file generated on the 09-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadset('filename','sub0022_1_2_2_after_preICA.set','filepath','J:\\ERP_esports\\ERP_esports_data\\sub0022_20190407\\');
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  }, [-0.2         0.7], 'newname', 'sub0022_1_2_2 epochs', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-200    0]);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_rejepoch( EEG, [6 11 21 33 39 40 41 74] ,0);
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_rejepoch( EEG, 88,0);
