function ml_egomaps_draw_grid(RADIUS_CM)
    coordinatesRadii = 1:RADIUS_CM;
    coordinatesAngles = [0, 45, 90, 135, 180, 225, 270, 315];

    % Draw the circles
    for i = 1:length(coordinatesRadii)
        h = ml_egomaps_draw_circle(0,0,coordinatesRadii(i));
        set(h, 'linewidth', 1)
    end
    
    % Draw the lines
    for i = 1:length(coordinatesAngles)
       ca = coordinatesAngles(i);
       x2 = RADIUS_CM * sind( ca );
       y2 = - RADIUS_CM * cosd( ca );

       plot([0, x2], [0, y2], 'k-', 'linewidth', 1)
    end
    
    % Draw the angles
    for i = 1:length(coordinatesAngles)
       ca = coordinatesAngles(i);
       x2 = RADIUS_CM*1.15 * sind( ca );
       y2 = - RADIUS_CM*1.15 * cosd( ca );

       text(x2,y2,sprintf('%d', coordinatesAngles(i)))
    end
end