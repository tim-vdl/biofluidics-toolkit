function [output_mesh] = transform_this_mesh(input_mesh, tform)

input_pcl = pointCloud(input_mesh.vertices);
transformed_pcl = pctransform(input_pcl, tform);
output_mesh.vertices = transformed_pcl.Location;
output_mesh.faces = input_mesh.faces;

end

