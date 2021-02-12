function [cropped_img, rect, centroid] = imcrop_centroid(bw, dims)
%IMCROP_CENTROID crops out an area around the centroid of a binary object. 
%The size of the cropped image in each dimension must be defined by 'dims'.

stats = regionprops(bw, 'Centroid');
centroid = stats.Centroid(:);

rect = [centroid(1) - dims(1)/2,...
    centroid(2) - dims(2)/2,...
    dims(1),...
    dims(2)];
cropped_img = imcrop(bw, rect);
    

