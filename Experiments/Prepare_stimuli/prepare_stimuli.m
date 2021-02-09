% This script is intended to take screenshots from the CS:GO game, cut them
% to the shape defined by the "resize_to" parameter, put them on a black
% background of size "output_image_size" and save to the "output" folder.
% Select the root folder when running the script. The folder should be
% organized hierarchically with model class folders on top, followed by size
% class folders down to map class folders.

%% Define the size initial images will be resized to as well as the output image size
resize_to = [450,450];
output_image_size = [1920,1080];

%% Select a root folder
root_folder = [uigetdir('./','Select a root folder...'), filesep]; %'/Users/andreizn/Desktop/Sample_images_P300/';
output_folder = [root_folder, 'output', filesep];
if ~exist(output_folder, 'dir')
    mkdir(output_folder)
end

%% Run through the folders to resize images, put on a black background and save to the output folder
model_class = {'0_CT'; '1_T'};
size_class = {'0_small'; '1_medium'; '2_large'};
map_class = {'0_Dust2'; '1_Inferno'; '2_Train'; '3_Mirage'; '4_Nuke'; '5_Overpass'; '6_Vertigo'};

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
                I_output = zeros(output_image_size(2),output_image_size(1),3,'uint8');
                y_1 = (output_image_size(2)-resize_to(2))/2; y_2 = y_1 + resize_to(2)-1;
                x_1 = (output_image_size(1)-resize_to(1))/2; x_2 = x_1 + resize_to(1)-1;
                I_output(y_1:y_2, x_1:x_2, :) = I_resized;
                imwrite(I_output, [output_folder, 'h_', im_prefix_model_class, im_prefix_map_class, im_prefix_size_class, num2str(im_idx, '%02d'), '.png']);
            end
        end
    end
end