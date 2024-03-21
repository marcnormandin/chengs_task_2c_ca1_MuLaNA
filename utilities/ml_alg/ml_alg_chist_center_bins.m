function [center_bins_deg] = ml_alg_chist_center_bins(n_bins)
    % Computes the center bins for a circular histogram (equal bin widths).
    dtheta_deg = 360.0 / n_bins;
    center_bins_deg = (0:n_bins)*dtheta_deg;
    center_bins_deg(center_bins_deg==360) = []; % drop if 360 included
end % function
