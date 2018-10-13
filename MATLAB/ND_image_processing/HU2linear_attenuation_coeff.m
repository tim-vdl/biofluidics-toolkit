function output_volume = HU2linear_attenuation_coeff(input_volume_HU,rescale_slope, rescale_intercept)
% This function converts CT-scan volume in Hounsfield-units to linear
% attenuation coefficients following the equation: 
% HU = rescale_slope * voxel_value + rescale_intercept
% With voxel_value = linear attenuation coefficient
% So that:
% linear_attenuation_coeff = (HU - rescale_intercept)/rescale_slope

if nargin == 1
    rescale_slope = 1;
    rescale_intercept = -1024;
    output_volume = (input_volume_HU - rescale_intercept)./rescale_slope;
elseif nargin == 3
    output_volume = (input_volume_HU - rescale_intercept)./rescale_slope;
else
    error('Error. \nNot enough input variables')
end

