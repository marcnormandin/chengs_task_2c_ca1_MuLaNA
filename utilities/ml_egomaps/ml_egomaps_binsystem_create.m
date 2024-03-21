function [binSystem] = ml_egomaps_binsystem_create(RADIUS_CM, cm_per_bin)
    % This creates a bin system for the egocentric coordinates
    boundsx = [-RADIUS_CM, RADIUS_CM];
    boundsy = [-RADIUS_CM, RADIUS_CM];
    cm_per_bin_x = cm_per_bin;
    cm_per_bin_y = cm_per_bin;
    binSystem = ml_bs_create(boundsx, boundsy, cm_per_bin_x, cm_per_bin_y);
end % function
