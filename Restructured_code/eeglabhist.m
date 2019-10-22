% EEGLAB history file generated on the 22-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','sub0023_2_2_2_IC_marked_for_rejection.set','filepath','E:\\ERP_esports\\ERP_esports_alldata\\06_ERP_esports_data_reject_IC\\sub0023_20190412\\');
EEG = eeg_checkset( EEG );
figure; pop_erpimage(EEG,1, [25],[[]],'Pz',1,0,{ '8' '9' '10' '11' '12' '13' '14'},[],'type' ,'yerplabel','\muV','erp','on','limits',[NaN NaN -15 15 NaN NaN NaN NaN] ,'cbar','on','caxis',[-15 15] ,'topo', { [25] EEG.chanlocs EEG.chaninfo } );
erpimage( mean(EEG.data([25], :),1), eeg_getepochevent( EEG, {'8' '9' '10' '11' '12' '13' '14'},[],'type'), linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), 'Pz', 1, 0 ,'yerplabel','\muV','erp','on','limits',[NaN NaN -15 15 NaN NaN NaN NaN] ,'cbar','on','caxis',[-15 15] ,'topo', { [25] EEG.chanlocs EEG.chaninfo } );