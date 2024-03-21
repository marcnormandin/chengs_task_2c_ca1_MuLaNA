function ml_egomaps_draw_facing_direction(cx, cy, facingAngleDeg, RADIUS_CM)
% This is for drawing the heading line segment
    tx = RADIUS_CM*sind(facingAngleDeg); 
    ty = -RADIUS_CM*cosd(facingAngleDeg);
    
    plot([cx, cx+tx], [cy, cy+ty], 'g-', 'linewidth', 10)
end % function