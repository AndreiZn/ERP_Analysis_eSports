function Plot_ERP_Image(EEG, set_name, output_folder_cur, channel_idx)

figure; 
if numel(channel_idx) == 1
    ch = ['ch_', num2str(channel_idx)];
else
    ch = 'all_chs';
end
output_image_name = [output_folder_cur, 'ERP_Image_', ch, '_', set_name, '.png'];
pop_erpimage(EEG,1,channel_idx ,[[]],'ERP Image',10,1,{ 'B1(red_circle)'},[],'type' ,'yerplabel','\muV','erp','on','cbar','on','topo', { channel_idx EEG.chanlocs EEG.chaninfo } );
saveas(gcf, output_image_name)
close(gcf)