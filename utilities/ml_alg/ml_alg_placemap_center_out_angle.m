function [aAngle, ax, ay] = ml_alg_placemap_center_out_angle(mapA, PLACEFIELD_PERCENTILE_THRESHOLD)
    if isempty(PLACEFIELD_PERCENTILE_THRESHOLD)
        PLACEFIELD_PERCENTILE_THRESHOLD = 95;
    end
    
    ax = nan;
    ay = nan;
    
    % Some maps can be all zeros or all nan or empty, so check
    if all(mapA == 0, 'all') || all(isnan(mapA), 'all') || isempty(mapA)
        aAngle = nan;
        return
    end
    
    centerX = size(mapA,2)/2;
    centerY = size(mapA,1)/2;
    
    [ax, ay] = get_field_location(mapA, PLACEFIELD_PERCENTILE_THRESHOLD);
    
    aAngle = ml_alg_center_out_angle(centerX, centerY, ax, ay);
end% function

function [ax, ay] = get_field_location(M, PLACEFIELD_PERCENTILE_THRESHOLD)
    k = prctile(M, PLACEFIELD_PERCENTILE_THRESHOLD, 'all');

    bw = zeros(size(M));
    bw(M>=k) = M(M>=k);

    measurement = regionprops(bwlabel(bw), bw, {'WeightedCentroid','Area'});
    
    % Find the one with the largest area
    areas = [measurement.Area];
    [~,indMax] = max(areas);
    
    % Get the centroid location for the field with the largest area
    ax = measurement(indMax).WeightedCentroid(1);
    ay = measurement(indMax).WeightedCentroid(2);
end % function



