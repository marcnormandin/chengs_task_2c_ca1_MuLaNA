function [aAngle, ax, ay] = ml_alg_placemap_center_out_angle_mulitple_fields(mapA, PLACEFIELD_PERCENTILE_THRESHOLD)
    if isempty(PLACEFIELD_PERCENTILE_THRESHOLD)
        PLACEFIELD_PERCENTILE_THRESHOLD = 95;
    end

    % This code will return the AVERAGE center out angle
    % (Averaged over the angles to each field)
    ax = nan; % there is no location since we are just averaging the angles.
    ay = nan;
    
    % Some maps can be all zeros or all nan or empty, so check
    if all(mapA == 0, 'all') || all(isnan(mapA), 'all') || isempty(mapA)
        aAngle = nan;
        return
    end
    
    centerX = size(mapA,2)/2;
    centerY = size(mapA,1)/2;
    
    [centroids, areas] = get_field_locations(mapA, PLACEFIELD_PERCENTILE_THRESHOLD);
    nFields = length(areas);

    aAngles = zeros(nFields,1);
    for iField = 1:nFields
        aAngles(iField) = ml_alg_center_out_angle(centerX, centerY, centroids(iField,1), centroids(iField,2));
    end
    
    % Compute the average
    aAngle = ml_alg_circ_mean(aAngles);
end% function

function [centroids, areas] = get_field_locations(M, PLACEFIELD_PERCENTILE_THRESHOLD)
    k = prctile(M, PLACEFIELD_PERCENTILE_THRESHOLD, 'all');

    bw = zeros(size(M));
    bw(M>=k) = M(M>=k);

    measurement = regionprops(bwlabel(bw), bw, {'WeightedCentroid','Area'});
    
    nFields = length(measurement);
    
    % Find the one with the largest area
    areas = [measurement.Area];

    % Centroids
    centroids = reshape([measurement.WeightedCentroid], 2,nFields)';
end % function


