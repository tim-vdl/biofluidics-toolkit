function image_stack = change_voxel_size(image_stack, current_voxel_size, target_voxel_size)
current_size = size(image_stack);
true_size = current_size .* current_voxel_size;
target_size = true_size ./ target_voxel_size;
image_stack = imresize3(image_stack, target_size);
end

