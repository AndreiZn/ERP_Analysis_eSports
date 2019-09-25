% EEGLAB history file generated on the 25-Sep-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadset('filename','sample_set.set','filepath','J:\\ERP_esports\\ERP_esports_code\\Restructured_code\\files\\');
EEG = eeg_checkset( EEG );
EEG = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','kurt');
