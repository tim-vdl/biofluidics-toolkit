function show_ortho_slices(sample)
volume_size = size(sample);
rounded_mids = round(volume_size/2);

slice_xy = sample(:,:,rounded_mids(3));
slice_xz = squeeze(sample(:,rounded_mids(2),:));
slice_yz = squeeze(sample(rounded_mids(1),:,:));

figure;
subplot(3,1,1)
imshow(slice_xy)
title('XY slice')
subplot(3,1,2)
imshow(slice_xz)
title('XZ slice')
subplot(3,1,3)
imshow(slice_yz)
title('YZ slice')

end

