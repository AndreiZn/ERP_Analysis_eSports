resize_to = [450,450];
root_folder = '/Users/andreizn/Desktop/Sample_images_P300/';
output_folder = [root_folder, 'resized', filesep];
if ~exist(output_folder, 'dir')
    mkdir(output_folder)
end
model_class = {'0_CT'; '1_T'};
size_class = {'0_small'; '1_medium'; '2_large'};
map_class = {'0_Dust2'; '1_Inferno'; '2_Train'; '3_Mirage'; '4_Nuke'; '5_Overpass'; '6_Vertigo'};
n_scr = 5;

for model_class_idx = 1:numel(model_class)
    
    model_class_cur = model_class{model_class_idx};
    im_prefix_model_class = num2str(model_class_idx - 1);
    
    for map_class_idx = 1:numel(map_class)
        
        map_class_cur = map_class{map_class_idx};
        im_prefix_map_class = num2str(map_class_idx - 1);
        
        for size_class_idx = 1:numel(size_class)
            
            size_class_cur = size_class{size_class_idx};
            im_prefix_size_class = num2str(size_class_idx - 1);

            folder_cur = [root_folder, model_class_cur, filesep, size_class_cur, filesep, map_class_cur, filesep];
            im_files = dir(folder_cur);
            fileflag = ~[im_files.isdir] & ~strcmp({im_files.name},'..') & ~strcmp({im_files.name},'.') & ~strcmp({im_files.name},'.DS_Store');
            im_files = im_files(fileflag);
            for im_idx=1:numel(im_files)
                im = im_files(im_idx);
                im = [im.folder, filesep, im.name];
                I = imread(im);
                h = min(size(I,1), size(I,2));
                I = I(1:h, 1:h, :);
                I_resized = imresize(I, resize_to);
                I_output = zeros(1080,1920,3,'uint8');
                y_1 = (1080-resize_to(2))/2; y_2 = y_1 + resize_to(2)-1;
                x_1 = (1920-resize_to(1))/2; x_2 = x_1 + resize_to(1)-1;
                I_output(y_1:y_2, x_1:x_2, :) = I_resized;
                imwrite(I_output, [output_folder, 'h_', im_prefix_model_class, im_prefix_map_class, im_prefix_size_class, num2str(im_idx, '%02d'), '.png']);
            end
        end
    end
end

% if im_idx <= 10
%     I_scrambled = zeros([resize_to,3],'uint8');
%     row_rand = randperm(n_scr);
%     col_rand = randperm(n_scr);
%     for row=1:5
%         for col=1:5
%             row_rand_cur = row_rand(row);
%             col_rand_cur = col_rand(col);
%             step_x = resize_to(1)/n_scr; step_y = resize_to(2)/n_scr;
%             I_scrambled(1+(row-1)*step_y:row*step_y, 1+(col-1)*step_x:col*step_x,:) = I_resized(1+(row_rand_cur-1)*step_y:row_rand_cur*step_y, 1+(col_rand_cur-1)*step_x:col_rand_cur*step_x,:);
%         end
%     end
%     I_output = zeros(1080,1920,3,'uint8');
%     y_1 = (1080-resize_to(2))/2; y_2 = y_1 + resize_to(2)-1;
%     x_1 = (1920-resize_to(1))/2; x_2 = x_1 + resize_to(1)-1;
%     I_output(y_1:y_2, x_1:x_2, :) = I_scrambled;
%     imwrite(I_output, [output_folder, 'scrambled_0', num2str(im_idx) '.png']);
% end
% in = imread(im);
% [a, b, c] = size(in);
% sOrder = randperm(a*b*c); % Order to scramble image.
% out = in(sOrder);
% out = reshape(out, a, b, c);