function angles = ml_alg_center_out_angle_discrete_bias(nX, nY)    
% This computes the samples of center out angles when points are
% picked uniformly at random from rectangular maps of size nX by nY
    if mod(nX,2) == 0
        centerX = nX/2;
    else
        centerX = 1 + (nX-1)/2;
    end

    if mod(nY, 2) == 0
        centerY = nY/2;
    else
        centerY = 1 + (nY-1)/2;
    end

    angles = nan(1, nX * nY);
    
    k = 0;
    for i1 = 1:nY
        for j1 = 1:nX
            a1 = ml_alg_center_out_angle(centerX, centerY, j1, i1);

            for i2 = 1:nY
                for j2 = 1:nX
                    a2 = ml_alg_center_out_angle(centerX, centerY, j2, i2);
                    [angleDiff_deg] =  ml_alg_center_out_difference(a1, a2);

                    % store
                    k = k + 1;
                    angles(k) = angleDiff_deg;
                end
            end
        end
    end

    
end% function
