function [dirv] = ml_alg_placemap_dirvector(mapA)    
    % Some maps can be all zeros or all nan or empty, so check
    if all(mapA == 0, 'all') || all(isnan(mapA), 'all') || isempty(mapA)
        dirv = [];
        return
    end


    
    nX = size(mapA,2);
    nY = size(mapA,1);

    if mod(nX,2) == 0
        centerX = nX/2;
    else
        centerX = (nX-1)/2 + 1;
    end

    if mod(nY,2) == 0
        centerY = nY/2;
    else
        centerY = (nY-1)/2 + 1;
    end
    
    k = prctile(mapA, 90, 'all');
    bw = zeros(size(mapA));
    bw(mapA>=k) = mapA(mapA>=k);



    v = [];
    k = 1;
    for i = 1:nY
        for j = 1:nX
            ax = j;
            ay = i;
            
            angle_deg = ml_alg_center_out_angle(centerX, centerY, ax, ay);
            mag = bw(i,j);
            v(k,:) = mag .* [cosd(angle_deg), sind(angle_deg)];
            k = k + 1;
        end
    end

    dirv = sum(v,1);
end% function



