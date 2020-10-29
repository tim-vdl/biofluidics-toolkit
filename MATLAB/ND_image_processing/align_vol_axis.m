function [rotated_volume, angle, rotation_axis] = align_vol_axis(binary_volume, target_axis)
%ALIGN_VOL_AXIS Align principal axis of a binary volume with a target axis.
% target axis: 3x1 vector
assert(isequal(size(target_axis),[3,1]), 'Target axis should have size [3, 1]')
stats = regionprops3(binary_volume, 'Centroid', 'EigenValues', 'EigenVectors');
eigenvals  =  stats.EigenValues{:};
eigenvects = stats.EigenVectors{:};
[~, id] = max(eigenvals);
principal_axis = [eigenvects(2,id); eigenvects(1,id); eigenvects(3,id)]; % image space to XYZ

rotation_axis = cross(principal_axis,target_axis);
angle = -atand(norm(cross(principal_axis,target_axis),...
    dot(principal_axis,target_axis)));

rotated_volume = logical(imrotate3(double(binary_volume), angle, rotation_axis'));
end

