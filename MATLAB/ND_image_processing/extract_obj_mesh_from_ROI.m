function [FV] = extract_obj_mesh_from_ROI(ROI, labels, missing, varargin)
p = inputParser;
is_one_number = @(x) numel(x)==1 & isnumeric(x);
checkMeshSaveFormat = @(x) ischar(x) & any(strcmp({'mat','stl','both'},x));
addParameter(p,'MeshReductionFactor',0.05,is_one_number);
addParameter(p,'MeshDimensionScales',[1, 1, 1], @isnumeric);
addParameter(p,'SavePath',[],@ischar);
addParameter(p,'MeshSaveFormat','stl',checkMeshSaveFormat);
addParameter(p,'BinarizeThreshold', multithresh(ROI{1},1), is_one_number);
addParameter(p,'OutputToSave',{'ROI'},@iscellstr);
parse(p,varargin{:});

save_path = p.Results.SavePath;
output2save = p.Results.OutputToSave;
mesh_save_format = p.Results.MeshSaveFormat;
mesh_reduction_factor = p.Results.MeshReductionFactor;
mesh_dim_scales = p.Results.MeshDimensionScales;
binarize_threshold = p.Results.BinarizeThreshold;

FV = cell(size(ROI));
for i = 1:numel(ROI)
    if ~missing(i)
        
        obj = mat2gray(ROI{i}) >= binarize_threshold;
        obj = keepNobj(obj,1);
        obj = imclose(obj,ones(5,5,5));
        obj = imfill(obj,'holes');
        fv = isosurface(obj, 0.5);
        fv = reducepatch(fv, mesh_reduction_factor);
        fv.vertices = (fv.vertices - nanmean(fv.vertices,1)) .* mesh_dim_scales;
        FV{i} = fv;
        
        if ~isempty(save_path)
            fprintf('Saving slices... \n')

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

