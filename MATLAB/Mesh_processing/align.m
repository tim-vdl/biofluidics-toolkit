
for i = 1:numel(shapes)
    fv = shapes{i};
    A = fv.vertices;
    [U,S,V]=svd(A,0);
    ptcl = pointCloud(fv.vertices);
    model = pcfitsphere(ptcl,3);
    
    a=V(:,1);
    b=model.Center;
    angle = atan2(norm(cross(a,b)), dot(a,b));
    if angle < pi/2
        V = -V;
    end
    
    A_rot = A*V; %V(:,1) is the direction of most variance
    fv_rot = fv;
    fv_rot.vertices = A_rot;
    
    shapes_rot{i} = fv_rot;
    
    figure,patch(fv,'LineStyle','none', 'FaceAlpha', 0.2, 'FaceColor', 'k');
    axis equal
    view(3)
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    rotate3d on
    hold on
    box on
    xlim([-100 100])
    ylim([-100 100])
    zlim([-100 100])
    hold on
    scatter3(0, 0, 0, 'r', 'filled');
    plot(model);
    
    V = V*200;
    hold on
    plot3([0 V(1,1)],[0 V(2,1)],[0 V(3,1)], 'r');
%     plot3([-V(1,1) V(1,1)],[-V(2,1) V(2,1)],[-V(3,1) V(3,1)], 'r');
%         print(sprintf('estimation_%.4d',i),'-dpng','-r300');
        close all
end


%%
cm = lines(6);
figure,patch(fv,'FaceColor',cm(1,:),'LineStyle','none', 'FaceAlpha', 0.2);
hold on
patch(fv_rot,'FaceColor',cm(2,:),'LineStyle','none', 'FaceAlpha', 0.2);
axis equal
view(3)
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
xlim([-100 100])
ylim([-100 100])
zlim([-100 100])
rotate3d on
box on


scatter3(0, 0, 0, 'r', 'filled');