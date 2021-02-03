function [row,col] = find_core_position(bw_filled)
%FIND_CORE_POSITION finds to estimated position of the pear core based on a
%distance map of a binary image of a pear. Holes inside of the binary 
%object are expected to be filled (e.g., using the imfill(_, 'holes') function).
%
d = bwdist(~bw_filled);
[~, idx] = max(d, [], 'all', 'linear');
img_size = size(bw_filled);
[row, col] = ind2sub(img_size ,idx);
end

