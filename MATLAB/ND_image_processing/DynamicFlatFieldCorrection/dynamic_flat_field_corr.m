%% Dynamic intensity normalization using eigen flat fields in X-ray imaging
% Based on: 
%   - V.Van Nieuwenhove, J. De Beenhouwer, F. De Carlo, L.
%       Mancini, F. Marone, and J. Sijbers, "Dynamic intensity 
%       normalization using eigen flat fields in X-ray imaging", 
%       Optics Express, 2015
%   - Code available with the above mentioned paper
%
% Script: Computes the conventional and dynamic flat field corrected
%         projections of a computed tomography dataset.
%
% Input:  Dark fields, flat fields and projection images
% Output: Eigen flat fields, conventional and dynamical flat field 
%         corrected projections
% 
%--------------------------------------------------------------------------
% Tim Van De Looverbosch
% MeBioS Postharvest Group
% KU Leuven
% Belgium
% tim.vandelooverbosch@kuleuven.be
%%
clear; clc;

%% load flat fields, dark fiels and projections
fprintf('Reading images \n')

flat_field_path = '';
flats = double(ImportSlices(flat_field_path));
n_flats = size(flats, 3);
dims = [size(flats, 1), size(flats, 2)];
n_pixels = prod(dims);

dark_field_path = '';
darks = double(ImportSlices(dark_field_path));
n_darks = size(darks, 3);

proj_path = '';
projs = double(ImportSlices(proj_path));
n_projs = size(projs, 3);

%% Remap pixel values between 0 and 1 with gamma correction
% max_value = max([max(flats(:)), max(darks(:)), max(projs(:))]);
% gamma = 0.35;
% fprintf('Remapping pixel values between [0, 1] with gamma = %f \n', gamma)
% 
% for n = 1:n_flats
%    flats(:,:,n) = imadjust(flats(:,:,n)/max_value,[0 1],[0 1], gamma);
% end
% 
% for n = 1:n_darks
%    darks(:,:,n) = imadjust(darks(:,:,n)/max_value,[0 1],[0 1], gamma);
% end
% 
% for n = 1:n_projs
%    projs(:,:,n) = imadjust(projs(:,:,n)/max_value,[0 1],[0 1], gamma);
% end

%% Image to vectors
fprintf('Reshaping images to vectors \n')

flat_vectors = NaN(n_flats, n_pixels);
dark_vectors = NaN(n_flats, n_pixels);

for n = 1:n_flats
    image = flats(:,:,n);
    flat_vectors(n,:) = image(:);
end
mn_flat = mean(flat_vectors, 1);

for n = 1:n_darks
    image = darks(:,:,n);
    dark_vectors(n,:) = image(:);
end
mn_dark = mean(dark_vectors, 1);

%% normalize flat_lines
fprintf('Normalizing flat field vectors \n')
flat_vectors = flat_vectors - repmat(mn_dark, n_flats, 1) - repmat(mn_flat, n_flats, 1);

%% PCA
fprintf('PCA on flat field vectors \n')
[coeff,score,eigenvalues,tsquared,explained,mu] = pca(flat_vectors);
n_comp = find(cumsum(explained)> 95, 1);

%% Calculate eigen flat fields
fprintf('Calculate eigen flat fields \n')

eigen_flats = NaN(dims(1), dims(2), n_comp);
for n = 1:n_comp
   eigen_flats(:,:,n) = reshape(coeff(:,n), dims); 
end

%% Filter eigen flat fields
fprintf('Filter eigen flat fields \n')

filt_eigen_flats = NaN(size(eigen_flats));
for n=1:n_comp
    eigen_flat = eigen_flats(:,:,n);
    mini = min(eigen_flat(:));
    maxi = max(eigen_flat(:));
    eigen_flat = (eigen_flat - mini)/(maxi - mini);
    [~, eigen_flat] = BM3D(1, eigen_flat); 
    filt_eigen_flats(:,:,n) = eigen_flat*(maxi - mini) + mini;
end

%% estimate weights for projections
fprintf('Weight estimation for dynamic flat field correction \n')

conv_ffc = zeros(size(projs));
dynm_ffc = zeros(size(projs));
weights  = zeros(n_comp, n_projs);
mn_dark  = reshape(mn_dark, dims);
mn_flat  = reshape(mn_flat, dims);
downsample = 2;
for n = 1:n_projs
    proj = projs(:,:,n);
    mn = mean(proj(:));
    conv_ffc(:,:,n) = (proj - mn_dark)./mn_flat;
    
    x = condTVmean(proj, mn_flat,...
        filt_eigen_flats(:,:,1:end), mn_dark, zeros(1,n_comp), downsample);
    weights(:,n) = x;
    
    ff = mn_flat;
    for j = 1:n_comp
       ff = ff + x(j)*filt_eigen_flats(:,:,j); 
    end
    dynm_ffc(:,:,n) = (proj-mn_dark)./(ff);
end

figure;imshow3Dfull(conv_ffc,[0 1])
figure;imshow3Dfull(dynm_ffc,[0 1])
