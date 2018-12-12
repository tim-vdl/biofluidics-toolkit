function [ROI, bounding_boxes, centroids, BW, BW_filled, FV] = batchCT2roi(volume, labels, missing, varargin)
%% BATCHCT2ROI
% Crops all objects in a volume according to labeling.
%
% INPUTS:
%   CT_vol: "CT_vol" is a volume (3D matrix) from which you want to isolate
%           the objects, and order and label them according a certain grid. 
%           The grid with the object labels is defined by the input argument
%           "labels".
%   labels: "labels" is a R x C x L cell array that defines the grid or
%           structure in CT_vol according to which the objects will be 
%           ordened and labeled. L specifies the number of layers of objects
%           in the volume. R and C specify the number of rows and columns 
%           of objects in each layer of the volume. Each element of
%           "labels" contains a char that specifies the label of the object
%           in that position of the grid. By convention, the corresponding 
%           positions between "labels" and "CT_vol" are as they occure when
%           the function imshow3D() is called on CT_vol. The label of
%           label{1,1,1} corresponds with the first object that can be found 
%           in the upper left corner of the volume when scrolling through
%           the slices from 1 to the end (CT_vol(:,:,1) to
%           CT_vol(:,:,end)). labels{end,end,end} corresponds with the last 
%           object that can be found in the bottom right corner of the 
%           volume when scrolling through the slices from 1 to the end.
%           label{end,1,end} corresponds with the last object that can be 
%           found in the bottom left corner of the volume when scrolling 
%           through the slices from 1 to the end.
%   missing: "missing" is a matrix of the same size as "labels" with zeros
%            on the positions where there is an object expected and a 1 
%            where the object is expected to be missing. In the ouputs,
%            structured in the same way as "labels" and "missing", 
%            will be empty at the positions where "missing" has a 1.
%   Name-Value pairs:
%       MinimalObjectVolume: Objects smaller then this will me ignored
%       MeshReductionFactor: Reduce the number of faces in the meshes. 
%                            See "help reducepatch" for more information
%       MeshDimensionScales: Scale the mesh coordinates by multiplying with
%                            each coordinate variable.
%       SavePath:   Specifies where to save the outputs. By default, the
%                   outputs are not saved. For every output type
%                   {'ROI', 'BW', 'BW_filled', 'FV'} a seperate folder will 
%                   be generated in the SavePath folder called
%                   ROI, BW, BW_filled and FV, respectively.
%       OutputToSave: Cell str that specifies which output variables to
%                     save containing one or multiple elements of 
%                     {'ROI', 'bwROI', 'bwROI_filled', 'FV'}. 
%                     By default, only {'ROI'} are saved. Output types can
%                     not be saved if they are not included in the output
%                     during the function call.
%       MeshSaveFormat: Format in which the meshes are saved 
%                       ('mat', 'stl' or 'both').
%       CTvolPadSize:   Size of padding to each side of the volume (default = 5)
%       StrelSize:      Size of the structural element that is used on te
%                       binary volume to "clean up" the segmentation with
%                       imclose() (default = 5). Play with this value if 
%                       the default setting is not appropriate for the 
%                       resolution.
%       BinarizeThreshold:  Threshold that is used to binarize the volume.
%                           By default, the multithresh(volume,1) is used.
% OUTPUTS:
%   ROI:    Cropped objects in the original volume according the the
%           structure defined by "labels".
%   bounding_boxes: Bounding box of every ROI. See "help regionprops3" for
%                   more details.
%   centroids: Centroids box of every ROI. See "help regionprops3" for
%              more details.
%   bwROI:  Cropped binarized objects in the volume according the the
%           structure defined by "labels".
%   bwROI_filled:   Cropped binarized and filled objects in the volume 
%                   according the the structure defined by "labels".
%   FV:    Meshes of the objects in the volume according the the structure 
%          defined by "labels".

%% Inputs
p = inputParser;
% checkIntiger = @(x) rem(x,1)==0;
is_one_number = @(x) numel(x)==1 & isnumeric(x);
checkMeshSaveFormat = @(x) ischar(x) & any(strcmp({'mat','stl','both'},x));
addParameter(p,'MinimalObjectVolume',5000,@ischar);
addParameter(p,'MeshReductionFactor',0.05,is_one_number);
addParameter(p,'MeshDimensionScales',[1, 1, 1], @isnumeric);
addParameter(p,'SavePath',[],@ischar);
addParameter(p,'OutputToSave',{'ROI'},@iscellstr);
addParameter(p,'MeshSaveFormat','stl',checkMeshSaveFormat);
addParameter(p,'CTvolPadSize',5,is_one_number);
addParameter(p,'StrelSize',5,is_one_number);
addParameter(p,'BinarizeThreshold', multithresh(volume,1), is_one_number);
parse(p,varargin{:});

output2save = p.Results.OutputToSave;
min_object_vol = p.Results.MinimalObjectVolume;
save_path = p.Results.SavePath;
mesh_save_format = p.Results.MeshSaveFormat;
mesh_reduction_factor = p.Results.MeshReductionFactor;
mesh_dim_scales = p.Results.MeshDimensionScales;
pad_size = p.Results.CTvolPadSize;
strel_size = p.Results.StrelSize;
binarize_threshold = p.Results.BinarizeThreshold;

%% Infere info
[n_row, n_col, n_layers] = size(labels);
n_per_layer = n_col * n_row;
missing_per_layer = sum(sum(missing,2),1);
n_in_layer = n_per_layer - missing_per_layer;
n_in_col = n_row - sum(missing,1);

%% Pad 3D image: add 2 planes of zeroes in x, y, and z direction at beginning and end.
volume   = padarray(volume,[pad_size pad_size pad_size]);

%% Segment the objects
fprintf('Binarizing the volume... \n');
bw_volume = volume > binarize_threshold;
bw_volume = imclose(bw_volume,ones(strel_size,strel_size,strel_size));

fprintf('Filling binary objects... \n');
bw_volume_filled = imfill(bw_volume,'holes');
for i=1:size(volume,3)
    bw_volume(:,:,i) = imfill(bw_volume(:,:,i),'holes');
end

% Remove small objects
fprintf('Removing small objects... \n');
bw_volume_filled = bwareaopen(bw_volume_filled, min_object_vol);
bw_volume = bwareaopen(bw_volume, min_object_vol);

%% Get the bounding box around each object
fprintf('Sorting objects according to numbering... \n');
% Calculate region properties
stats = regionprops3(bw_volume_filled, 'BoundingBox','Centroid');
x = stats.Centroid(:,2);
y = stats.Centroid(:,1);
z = stats.Centroid(:,3);
centroid_table = table(y,x,z,...
    'VariableNames',{'Y','X','Z'});
T = [centroid_table, stats];
% Sort according to Z to seperate layers
T = sortrows(T,'Z');

% Assign the bounding box and centroids according to position and the labeling convention
bounding_boxes = cell(size(labels));
centroids = bounding_boxes;
for i = 1:n_layers
    if i == 1
        this_layer = T(1:n_in_layer(i),:);
    else
        this_layer = T(n_in_layer(i-1)+1:sum(n_in_layer(1:i-1))+n_in_layer(i),:);
    end
    % Sort according to Y to seperate columns
    this_layer = sortrows(this_layer,'Y','ascend'); 
    for c = 1:numel(n_in_col(:,:,i))
        % In every column, sort according to X to have the right order
        this_layer(sum(n_in_col(:,1:c-1,i))+1:sum(n_in_col(:,1:c,i)),:) = ...
            sortrows(this_layer(sum(n_in_col(:,1:c-1,i))+1:sum(n_in_col(:,1:c,i)),:),'X');
    end
    
    count = 0;
    for c = 1:n_col
        for r = 1:n_row
            if ~missing(r,c,i)
                count = count+1;
                bounding_boxes{r,c,i} = this_layer.BoundingBox(count,:);
                centroids{r,c,i} = this_layer.Centroid(count,:);
            end
        end
    end
    
end

%% Crop objects and calculate faces and vertices
fprintf('Cropping ROIs ... \n')
ROI = cell(size(labels));
BW = ROI;
BW_filled = ROI;
FV = ROI;

for i = 1:numel(labels)
    if ~missing(i)
        bb = bounding_boxes{i};
        xMin = floor(bb(1)) - 1;
        xMax = ceil(xMin + bb(4)) + 1;
        yMin = floor(bb(2)) - 1;
        yMax = ceil(yMin + bb(5)) + 1;
        zMin = floor(bb(3)) - 1;
        zMax = ceil(zMin + bb(6)) + 1;
        fprintf('Cropping ROI %s ... \n', labels{i});
        roi = volume(yMin:yMax,...
            xMin:xMax,...
            zMin:zMax);
        ROI{i} = padarray(roi,[1 1 1]);
        
        if nargout >= 4 % Other ouputs if requested
            fprintf('Cropping bwROI %s ... \n', labels{i});
            bw_roi = bw_volume(yMin:yMax,...
                xMin:xMax,...
                zMin:zMax);
            bw_roi = padarray(bw_roi,[1 1 1]);
            bw_roi = keepNobj(bw_roi,1);
            BW{i} = bw_roi;
            if nargout >= 5
                fprintf('Cropping bwROIfilled %s ... \n', labels{i});
                bw_roi_filled = bw_volume_filled(yMin:yMax,...
                    xMin:xMax,...
                    zMin:zMax);
                bw_roi_filled = padarray(bw_roi_filled,[1 1 1]);
                bw_roi_filled = keepNobj(bw_roi_filled,1);
                BW_filled{i} = bw_roi_filled;
                if nargout >= 6
                    fprintf('Generating Faces and Vertices of %s ... \n', labels{i});
                    fv = isosurface(bw_roi_filled, 0.5);
                    fv = reducepatch(fv, mesh_reduction_factor);
                    fv.vertices = (fv.vertices - nanmean(fv.vertices,1)) .* mesh_dim_scales;
                    FV{i} = fv;
                end
            end
        end
    end
end

%% Save ROIs to folder if requested
if ~isempty(save_path)
    fprintf('Saving slices... \n')
    for i = 1:numel(ROI)
        if ~missing(i)
            if any(strcmp(output2save,'ROI'))
                output_type = 'ROI';
                folder = labels{i};
                fprintf('Saving slices of ROI %s ... \n', folder);
                mkdir(fullfile(save_path, output_type, folder));
                this_roi = ROI{i};
                for j = 1:size(this_roi,3)
                    imwrite(this_roi(:,:,j),...
                        fullfile(save_path,...
                        output_type,...
                        folder,...
                        sprintf('slice_%0.4d.tif',j)));
                end
            end
            if any(strcmp(output2save,'BW'))
                output_type = 'BW';
                folder = labels{i};
                fprintf('Saving slices of BW %s ... \n', folder);
                mkdir(fullfile(save_path, output_type, folder));
                this_roi = BW{i};
                for j = 1:size(this_roi,3)
                    imwrite(this_roi(:,:,j),...
                        fullfile(save_path,...
                        output_type,...
                        folder,...
                        sprintf('slice_%0.4d.tif',j)));
                end
            end
            if any(strcmp(output2save,'BW_filled'))
                output_type = 'BW_filled';
                folder = labels{i};
                fprintf('Saving slices of BW_filled %s ... \n', folder);
                mkdir(fullfile(save_path, output_type, folder));
                this_roi = BW_filled{i};
                for j = 1:size(this_roi,3)
                    imwrite(this_roi(:,:,j),...
                        fullfile(save_path,...
                        output_type,...
                        folder,...
                        sprintf('slice_%0.4d.tif',j)));
                end
            end
            if any(strcmp(output2save,'FV'))
                output_type = 'FV';
                folder = labels{i};
                fprintf('Saving mesh of FV %s ... \n', folder);
                mkdir(fullfile(save_path, output_type));
                this_roi = FV{i};
                if strcmp(mesh_save_format,'mat')
                    file_name = strcat(folder,'.mat');
                    save(fullfile(save_path, output_type, file_name), 'this_roi')
                elseif strcmp(mesh_save_format,'stl')
                    file_name = strcat(folder,'.stl');
                    stlWrite(fullfile(save_path, output_type, file_name), this_roi)
                elseif strcmp(mesh_save_format,'both')
                    file_name = strcat(folder,'.mat');
                    save(fullfile(save_path, output_type, file_name), 'this_roi')
                    file_name = strcat(folder,'.stl');
                    stlWrite(fullfile(save_path, output_type, file_name), this_roi)
                end
            end
        end
    end
end