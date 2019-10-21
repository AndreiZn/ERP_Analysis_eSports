function [ERP] = compute_ERP(EEG)

ERP = pop_averager(EEG , 'Criterion', 'all', 'ExcludeBoundary', 'on', 'SEM', 'on' );

%ERP = pop_savemyerp(ERP, 'erpname', set_name, 'filename', output_set_name, 'filepath',...
 %output_folder_cur);