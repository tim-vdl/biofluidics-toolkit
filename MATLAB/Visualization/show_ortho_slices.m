function show_ortho_slices(sample, varargin)

valid_orientations = {'vertical', 'horizontal'};
p = inputParser;
addParameter(p, 'Orientation', 'vertical', @(x) any(validatestring(x, valid_orientations)));
addParameter(p, 'FontSize', 20, @isnumeric);
parse(p, varargin{:});

volume_size = size(sample);
rounded_mids = round(volume_size/2);
slice_xy = squeeze(sample(:,:,rounded_mids(3),:));
slice_xz = squeeze(sample(:,rounded_mids(2),:,:));
slice_yz = squeeze(sample(rounded_mids(1),:,:,:));

% Define grid of subplots
if strcmp(p.Results.Orientation, valid_orientations{1})
    i = 3;
    j = 1;
else
    i = 1;
    j = 3;
end

% Make plot
font_size = p.Results.FontSize;
figure;
subplot(i,j,1)
imshow(slice_xy)
title('XY slice', 'FontSize', font_size)
subplot(i,j,2)
imshow(slice_xz)
title('XZ slice', 'FontSize', font_size)
subplot(i,j,3)
imshow(slice_yz)
title('YZ slice', 'FontSize', font_size)

end

