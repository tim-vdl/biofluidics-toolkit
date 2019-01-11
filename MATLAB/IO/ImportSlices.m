function [ image_stack ] = ImportSlices(input_path, current_voxel_size, target_voxel_size)
% IMPORTSLICES imports stacks the images located in the folder "input_path".
% input_path:           a character containing the path for the images 
%                       e.g., %'C:\Users\user1\Projects\project1\images\set1'
% current_voxel_size:   a 1X3 vector describing the original voxel size of 
%                       the images in the input path in dims 1, 2 and 3.
% target_voxel_size:    a 1X3 vector describing the desired voxel size of 
%                       in dims 1, 2 and 3.


% Add images to image datastore
Images = imageDatastore(input_path);

% Loop over images and add them to the stack of slices
image_stack = [];
for i = 1:numel(Images.Files)
    slice = imread(Images.Files{i});
    image_stack = cat(3, image_stack, slice);
end

% Resize the image to the desired voxelsize
if nargin > 1
	current_size = size(image_stack);
	true_size = current_size .* current_voxel_size;
	target_size = true_size ./ target_voxel_size;
	image_stack = imresize3(image_stack, target_size);
end

end

