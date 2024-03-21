function [hFig] = ml_egomaps_draw_colourwheel()

    binSystem = ml_egomaps_binsystem_create(10, 0.05);

    angleMap = ml_egomaps_binsystem_anglemap(binSystem);
    distanceMap = ml_egomaps_binsystem_distancemap(binSystem);

    angleDiskMap = angleMap;
    angleDiskMap(distanceMap > RADIUS_CM) = nan;
    angleDiskMap(distanceMap < RADIUS_CM/2) = nan;

    I = nan(size(angleDiskMap,1)+1, size(angleDiskMap,2)+1);
    I(1:size(angleDiskMap,1), 1:size(angleDiskMap,2)) = angleDiskMap;

    hFig = figure();
    pcolor(I)
    set(gca, 'ydir', 'reverse')
    colormap hsv
    colorbar
    shading interp
    axis equal tight off
end
