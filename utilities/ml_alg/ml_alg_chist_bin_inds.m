function [x_bin_inds] = ml_alg_chist_bin_inds(x_deg, center_bins_deg)
    % The bins are assumed to be equally sized/spaced
    % computed from ml_alg_chist_center_bins

    dtheta_deg = median(diff(center_bins_deg));
    right_bins_deg = center_bins_deg + dtheta_deg / 2.0;
    
    % Get the bin indices of the head direction angles
    x_bin_inds = discretize(x_deg, right_bins_deg);
    % This are all less than the most negative value
    x_bin_inds(~isfinite(x_bin_inds)) = 0;
    x_bin_inds = x_bin_inds + 1;
end % function
