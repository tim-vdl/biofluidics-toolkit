function fv_box = box_mesh(display_option,xmin, xmax, ymin, ymax, zmin, zmax)
    if nargin == 1
        xmin = 0;
        xmax = 1;
        ymin = 0;
        ymax = 1;
        zmin = 0;
        zmax = 1;
    end
    vertices = [xmin ymin zmin;...
           xmin ymax zmin;
           xmax ymax zmin;
           xmax ymin zmin;
           xmin ymax zmax;
           xmax ymax zmax;
           xmax ymin zmax;
           xmin ymin zmax];
    faces = [1 2 3 4;...
             1 2 5 8;...
             2 3 6 5;...
             3 4 7 6;...
             4 1 8 7;...
             8 5 6 7];
    if nargout>0
        fv_box = struct('faces',faces,'vertices',vertices);
    end
        
    if display_option
        patch('faces',faces,'vertices',vertices,'facecolor',[0.5 0.8 0.5],'facealpha',0.6 );
    end
axis equal