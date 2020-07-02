function [cropped_volume] = imcrop3d(volume, bounding_box, pad_size, pad_value)
% IMCROP3D crops a volume using the provided bounding box and pads the
% cropped volume by the pad_size with voxels who's value is equal to
% the pad_value.
cropped_volume = volume(bounding_box(2):bounding_box(2)+bounding_box(5)-1,...
        bounding_box(1):bounding_box(1)+bounding_box(4)-1,...
        bounding_box(3):bounding_box(3)+bounding_box(6)-1);
cropped_volume = padarray(cropped_volume, pad_size, pad_value);
end

