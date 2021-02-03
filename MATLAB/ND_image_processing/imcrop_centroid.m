function [cropped_img, rect, centroid] = imcrop_centroid(img, dims, bright_foreground)
%IMCROP_CENTROID crops out an area around the centroid. The size of the
%cropped image in each dimension must be defined by 'dims'. Define if the
%foreground is bright ('bright_foreground' = 1) or dark
%('bright_foreground' = 0) so that the centroid is calculated on the
%foreground pixels.

if bright_foreground
    bw = img > multithresh(img, 1);
else
    bw = img < multithresh(img, 1);
end

bw = keepNobj(bw, 1);
stats = regionprops(bw, 'Centroid');
centroid = stats.Centroid(:);

rect = [centroid(1) - dims(1)/2,...
    centroid(1) - dims(2)/2,...
    dims(1),...
    dims(2)];
cropped_img = imcrop(img, rect);
    

