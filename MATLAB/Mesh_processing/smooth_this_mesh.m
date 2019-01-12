function [smooth_mesh] = smooth_this_mesh(input_mesh, n_iterations)
[output_vertices, output_faces] = smoothMesh(input_mesh.vertices,...
    input_mesh.faces,...
    n_iterations);
smooth_mesh.vertices    = output_vertices;
smooth_mesh.faces       = output_faces;
end

