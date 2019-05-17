function [ image_stack ] = ImportSlices(input_path, varargin)
% IMPORTSLICES imports stacks the images located in the folder "input_path".
% InputPath:        A character containing the path for the images 
%                       e.g., %'C:\Users\user1\Projects\project1\images\set1'
% CurrentVoxelSize: A 1X3 vector describing the original voxel size of 
%                       the images in the input path in dims 1, 2 and 3.
% TargetVoxelSize:  A 1X3 vector describing the desired voxel size of 
%                       in dims 1, 2 and 3.
% DICOM:            Look for DICOM images or not.
% FileExtension:    File extension when working with DICOM images

p = inputParser;
addRequired(p, 'InputPath')
addParameter(p, 'CurrentVoxelSize', [])
addParameter(p, 'TargetVoxelSize', [])
addParameter(p, 'DICOM', false)
addParameter(p, 'FileExtension', '*.IMA')
parse(p, input_path, varargin{:})

if ~p.Results.DICOM
    % Add images to image datastore
    image_data_store = imageDatastore(input_path);
    % Loop over images and add them to the stack of slices
    image_stack = [];
    for i = 1:numel(image_data_store.Files)
        slice = imread(image_data_store.Files{i});
        image_stack = cat(3, image_stack, slice);
    end
else
   % Get all file names
   file_extension = p.Results.FileExtension; 
   [~, file_paths, number_of_files] = get_folder_file_names(input_path,...
                                                   file_extension);
   % Get number of images, image width, image height and preallocate 
   info = dicominfo(file_paths{1});
   
   image_stack = uint16(zeros(info.Height, info.Width, n_files));
   
   % Add all slices to the image stack
   for f = 1:number_of_files
      slice = dicomread(file_paths{f});
      image_stack(:,:,f) = slice;
   end
end

% Resize the image to the desired voxelsize
if ~isempty(p.Results.CurrentVoxelSize)
    current_voxel_size  = p.Results.CurrentVoxelSize;
    target_voxel_size   = p.Results.TargetVoxelSize;
	image_stack = change_voxel_size(image_stack,...
                                    current_voxel_size,...
                                    target_voxel_size);
end

end

