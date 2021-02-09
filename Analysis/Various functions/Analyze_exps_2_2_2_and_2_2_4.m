function Analyze_exps_2_2_2_and_2_2_4(chs_to_plot, epoch_boundary)

root_folder = 'K:\eeglab14_1_2b\ERPLAB_Scripts_for_eSports\Exps_2_2_2_and_2_2_4\';
output_folder = 'K:\EEG_Experiments\EEGLAB_Combined_res_for_pro_npro\';

ERP_pro_and_nong_two_exps = pop_appenderp([root_folder, '2_2_2_and_2_2_4_pro_nong_erp_sets_list.txt']);

ERP_pro_and_nong_two_exps = pop_binoperator(ERP_pro_and_nong_two_exps, {  'b9 = b1 - b5'});
ERP_pro_and_nong_two_exps = pop_binoperator(ERP_pro_and_nong_two_exps, {  'b10 = b3 - b7'});

ERP_pro_and_nong_two_exps = pop_savemyerp(ERP_pro_and_nong_two_exps, 'erpname', 'pro_and_nong_2_2_2_and_2_2_4', ...
    'filename', 'pro_and_nong_2_2_2_and_2_2_4.erp', 'filepath', output_folder, 'Warning', 'off');% GUI: 13-May-2019 02:29:44

ERP_pro_and_nong_two_exps = pop_ploterps( ERP_pro_and_nong_two_exps, [9 10],  chs_to_plot , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel',...
 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'k-' }, 'LineWidth',  1, 'Maximize',...
 'on', 'Position', [ 103.714 16.0476 106.857 31.9048], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
 [ epoch_boundary(1) 0.98*epoch_boundary(2)   epoch_boundary(1):200:round(0.98*epoch_boundary(2)) ], 'YDir', 'normal' );
