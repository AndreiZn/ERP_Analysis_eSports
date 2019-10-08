% EEGLAB history file generated on the 08-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadset('filename','sub0001_1_1_2_init.set','filepath','C:\\Users\\user.T440_IT\\AndreiZn\\ERP_esports\\ERP_esports_data\\sub0001_20190403\\');
EEG = eeg_checkset( EEG );

EEG = pop_eegfiltnew(EEG, 1,30);
EEG = eeg_checkset( EEG );

EEG = pop_eegfiltnew(EEG, [],1,826,1,[],0);
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, [],30,110,0,[],0);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_interp(EEG, [4   6   7  27], 'spherical');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
