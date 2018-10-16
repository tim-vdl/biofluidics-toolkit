%%
clc
input_path = 'C:\Users\u0117721\Desktop\Conference_20162017_boxes\cropped\box2';
CT_vol = ImportSlices(input_path);
CT_vol = mat2gray(CT_vol);
CT_vol = medfilt3(CT_vol, [3, 3, 3]);
CT_vol_r = NaN(size(CT_vol,3),size(CT_vol,2),size(CT_vol,1));
for y = 1:size(CT_vol,1) 
    CT_vol_r(:,:,y) = squeeze(CT_vol(y,:,:))';
end

figure;imshow3Dfull(CT_vol_r)
%%
layer_label = cellstr(num2str([ones(15,1);2*ones(15,1)]));
layer_label = reshape(layer_label,5,3,2);
roi_label = repmat(cellstr(num2str((1:15)','%01.2i')),2,1);
roi_label = reshape(roi_label,5,3,2);
labels = strcat(layer_label,roi_label);

missing = zeros(size(labels));
missing(1,1,2) = 1;

clc
[ROI, ~, ~, ~,~,FV] = batchCT2roi(CT_vol_r, labels, missing);

%%
figure;imshow3Dfull(CT_vol_r)
figure;imshow3Dfull(ROI{2,1,1})
%%
figure;patch(FV{2,1,1}, 'FaceAlpha', 0.3, 'FaceColor', 'r')
axis equal; rotate3d on

%%