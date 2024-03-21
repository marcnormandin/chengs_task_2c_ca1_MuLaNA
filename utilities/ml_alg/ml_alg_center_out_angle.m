function aAngle = ml_alg_center_out_angle(centerX, centerY, ax, ay)
    dy = ay - centerY;
    dx = ax - centerX;
    aAngle = atan2d(dy,dx);
    negind = find(aAngle < 0);
    aAngle(negind) = aAngle(negind) + 360;
    aAngle = 360 - aAngle; % This is so that in image coordinates, which is what we plot in, the angle is correct and goes counter clockwise.
end
