function [ERP] = Compute_averaged_ERP(EEG, set_name, output_folder_cur)

ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );

set_name = [set_name, '_ERPset'];
output_set_name = [set_name, '.erp'];
ERP = pop_savemyerp(ERP, 'erpname', set_name, 'filename', output_set_name, 'filepath',...
 output_folder_cur);