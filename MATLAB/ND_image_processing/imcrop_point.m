function [cropped_img, rect] = imcrop_point(img, point, dims)
%IMCROP_POINT crops out an area around a given point ([col, row]). The size of the
%cropped image in each dimension must be defined by 'dims'.

rect = [point(1) - dims(1)/2,...
    point(2) - dims(2)/2,...
    dims(1),...
    dims(2)];
cropped_img = imcrop(img, rect);
    

