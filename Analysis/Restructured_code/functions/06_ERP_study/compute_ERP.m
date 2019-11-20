function [ERP] = compute_ERP(EEG)

ERP = pop_averager(EEG , 'Criterion', 'all', 'ExcludeBoundary', 'on', 'SEM', 'on' );
