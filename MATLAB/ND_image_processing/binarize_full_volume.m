function [sample_bw_filled, thresh] = binarize_full_volume(sample)
% Get the whole volume of the fruit
thresh = multithresh(sample);
sample_bw = sample > thresh; % figure; imshow3Dfull(sample_bw)
sample_bw_filled = sample_bw;
for z = 1:size(sample_bw,3)
    sample_bw_filled(:,:,z) = imfill(sample_bw(:,:,z),'holes');
end 
% sample_bw_filled = imclose(sample_bw,strel3d(8)); 
end

