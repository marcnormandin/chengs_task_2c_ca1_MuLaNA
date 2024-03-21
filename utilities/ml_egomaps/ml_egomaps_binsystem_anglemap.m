function [angleMap] = ml_egomaps_binsystem_anglemap(binSystem)
    % Make a map of angles. We need to rotate it for our coordinate system to
    % be consistent.
    angleMap = atan2(binSystem.YY, binSystem.XX);
    angleMap = rot90(angleMap,1);
    angleMap(angleMap < 0) = angleMap(angleMap < 0) + 2*pi; % Change angles from -pi to pi to be 0 to 2*pi
    angleMap = angleMap / (2*pi) * 360; % Convert from radians to degrees
end % function

