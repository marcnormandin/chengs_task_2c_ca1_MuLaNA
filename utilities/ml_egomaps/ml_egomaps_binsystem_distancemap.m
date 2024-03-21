function [distanceMap] = ml_egomaps_binsystem_distancemap(binSystem)
    % Make a map of distances for each grid point
    distanceMap = sqrt(binSystem.XX.^2 + binSystem.YY.^2); % This is fine because the origin is at 0,0 in center of the grid
end % function
