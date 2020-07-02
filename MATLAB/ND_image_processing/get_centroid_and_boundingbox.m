function [centroid, bounding_box] = get_centroid_and_boundingbox(volume)
% GET_CENTROID_AND_BOUNDINGBOX calculates the centroid and bouding box of
% every individual connected component in the input volume.
stats = regionprops3(volume, 'Centroid', 'BoundingBox');
centroid = stats.Centroid;
bounding_box = stats.BoundingBox;
end

