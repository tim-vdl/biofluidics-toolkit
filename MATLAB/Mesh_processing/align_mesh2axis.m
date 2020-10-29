function [aligned_mesh] = align_mesh2axis(mesh, target_axis)
%% ALIGN_MESH2AXIS
% Aligns the principle axis of a 'mesh' with the 'target_axis'
% Input:
%   mesh: struct with vertices and faces
%   target_axis = 1 x 3 vector
% Output:
%   aligned_mesh: mesh with principal axis aligned with 'target_axis'

% Center around the origin
mn = mean(mesh.vertices, 1);
aligned_mesh = mesh;
aligned_mesh.vertices = mesh.vertices - mn;

% Get principal axes using svd
[~,~,V] = svd(aligned_mesh.vertices,0);

% Align principal axis with X-axis
aligned_mesh.vertices = aligned_mesh.vertices * V;

% The first principal axis of shape will be aligned with X-axis if only V is used
% So get rotatiom matrix between target axis and X-axis.
rotm = -axang2rotm(vrrotvec(target_axis,[1,0,0]));
aligned_mesh.vertices = aligned_mesh.vertices * rotm;

% Bring shape back to origin center
aligned_mesh.vertices = algined_mesh.vertices + mn;

end