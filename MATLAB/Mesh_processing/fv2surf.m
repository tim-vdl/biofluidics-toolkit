function [surface,center]  = fv2surf(fv,azsteps,elsteps,center)

if nargin == 3
    center      = mean(fv.vertices,1);
end

fv.vertices = fv.vertices - repmat(center,[size(fv.vertices,1) 1]);

[az,el,rho] = cart2sph(fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3));
rho_f = repmat(flipud(rho), 4, 1);
rho = repmat(rho, 3, 1);
rho = cat(1, rho, rho_f);
el = cat(1, el, el, el, el+pi, el+pi, el-pi, el-pi);
az = cat(1, az-2*pi, az, az+2*pi, az+pi, az-pi, az+pi, az-pi);

% azq         = linspace(-pi+(2*pi/azsteps),pi,azsteps);
azq         = linspace(-pi,pi,azsteps);
elq         = linspace(-pi/2,pi/2,elsteps);
[azq,elq]   = meshgrid(azq,elq);

surface = griddata(az,el,rho,azq,elq,'cubic');
% surface = cat(1,surface(1,:),surface,surface(end,:));
surface = cat(2,surface(:,1),surface,surface(:,end));
surface([1:5 end-4:end],:) = nan;
surface = smoothn(surface,0.5);
surface = surface(:, 2:end-1);
% surface = surface(2:end-1, 2:end-1);


