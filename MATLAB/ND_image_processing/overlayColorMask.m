function [ MaskedImage ] = overlayColorMask( Image,bwMask,colour )

if ismatrix(Image) % Image is grayscale or logical
    rgbImage = cat(3, Image(:,:),Image(:,:), Image(:,:)); % figure;imshow(rgbImage)
    rgbMask = cat(3, colour(1)*ones(size(bwMask)), colour(2)*ones(size(bwMask)),...
                  colour(3)*ones(size(bwMask))); % figure;imshow(rgbMask)
    rgbMask = rgbMask.*double(bwMask); % figure;imshow(rgbMask)
    MaskedImage = rgbImage + uint8(50*rgbMask); % figure;imshow(MaskedImage)
elseif ndims(squeeze(Image)) == 3 % Image is rgb
    rgbMask = cat(3, colour(1)*ones(size(bwMask)), colour(2)*ones(size(bwMask)),...
        colour(3)*ones(size(bwMask))); % figure;imshow(rgbMask)
    rgbMask = rgbMask.*bwMask; % figure;imshow(rgbMask)
    MaskedImage = squeeze(Image) + uint8(50*rgbMask);
end

end

