function [ scan ] = ImportSlices(imageLocation,SelectEveryNthImage)
%% ImageLocation is a character containing the path for the images e.g., %'C:\Users\user1\Projects\project1\images\set1'
% n: select slices per n-images: possibility to reduce number of slices to
% be selected. If all slices must be used, do not specify "n", or set it to
% 1.

%% If "n" is not given, take all slices
 if nargin == 1
    SelectEveryNthImage=1;
 end

%% Add images to image set
Images=imageDatastore(imageLocation);
%Images=imageSet(imageLocation,'recursive');
scan=[];

%% make a subset of the slices
% z-slices
for i=1:SelectEveryNthImage:numel(Images.Files)
    slice = imread(Images.Files{i});
    scan=cat(3,scan,slice);
end
% same resolution for x and y
scan = scan(1:SelectEveryNthImage:size(scan,1),1:SelectEveryNthImage:size(scan,2),:);

%display
%figure;imshow3D(scan)
end

