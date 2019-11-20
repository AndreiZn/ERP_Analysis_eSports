function Plot_ERP_Image(EEG, target_bin, set_name, output_folder_cur, channel_idx)

figure; 
if numel(channel_idx) == 1
    ch = ['ch_', num2str(channel_idx)];
else
    ch = 'all_chs';
end

event_field = EEG.event;
tgt_idx = find(arrayfun(@(s) ismember(target_bin, s.bini), event_field), 1);
target_bin_name = event_field(tgt_idx).binlabel;

output_image_name = [output_folder_cur, 'ERP_Image_', ch, '_', set_name, '.png'];
pop_erpimage(EEG,1,channel_idx ,[[]],'ERP Image',10,1,{ target_bin_name},[],'type' ,'yerplabel','\muV','erp','on','cbar','on','topo', { channel_idx EEG.chanlocs EEG.chaninfo } );
saveas(gcf, output_image_name)
close(gcf)