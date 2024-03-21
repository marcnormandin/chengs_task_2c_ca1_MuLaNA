function [meanAngle] = ml_alg_circ_mean(d)
    % Compute the mean angle (circularly)
    rx = 0;
    ry = 0;
    for i = 1:length(d)
        rx = rx + cosd(d(i));
        ry = ry + sind(d(i));
    end
    meanAngle = atan2d(ry, rx); % this will be -180 to 180
    if meanAngle < 0
        meanAngle = meanAngle + 360;
    end
end % function
