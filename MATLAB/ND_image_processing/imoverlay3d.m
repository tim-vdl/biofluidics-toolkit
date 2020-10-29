function [volume_with_mask] = imoverlay3d(volume, mask1, colorSpec, mask2, colorSpec2)
if ndims(volume) == 3
    volume_with_mask = uint8(cat(4,volume, volume, volume));
    if nargin == 2
        for z = 1:size(volume,3)
            volume_with_mask(:,:,z,:) = imoverlay(volume(:,:,z),mask1(:,:,z));
        end
    elseif nargin == 3
        for z = 1:size(volume,3)
            volume_with_mask(:,:,z,:) = imoverlay(volume(:,:,z),mask1(:,:,z),colorSpec);
        end
    elseif nargin == 5
        for z = 1:size(volume,3)
            volume_with_mask(:,:,z,:) = imoverlay(volume(:,:,z),mask1(:,:,z),colorSpec);
            volume_with_mask(:,:,z,:) = imoverlay(squeeze(volume_with_mask(:,:,z,:)),mask2(:,:,z),colorSpec2);
        end
    end
% elseif ndims(volume) ==4
%     volume_with_mask = double(volume);
%     if nargin == 2
%         for z = 1:size(volume,3)
%             volume_with_mask(:,:,z,:) = imoverlay(volume(:,:,z),mask1(:,:,z));
%         end
%     elseif nargin == 3
%         for z = 1:size(volume,3)
%             volume_with_mask(:,:,z,:) = imoverlay(volume(:,:,z),mask1(:,:,z),colorSpec);
%         end
%     end
%     volume_with_mask = uint8(volume_with_mask);
end

