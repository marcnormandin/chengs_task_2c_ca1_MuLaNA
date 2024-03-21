function angles = ml_alg_center_out_angle_continuous_bias(width, height, nSamples)    
% This computes the samples of center out angles when points are
% picked uniformly at random from rectangular maps of size nX by nY
    centerX = width/2;
    centerY = height/2;

    angles = nan(1, nSamples);
    
    r1 = rand(nSamples, 2);
    r1(:,1) = width * r1(:,1);
    r1(:,2) = height * r1(:,2);

    r2 = rand(nSamples, 2);
    r2(:,1) = width * r2(:,1);
    r2(:,2) = height * r2(:,2);

    for k = 1:nSamples
        a1 = ml_alg_center_out_angle(centerX, centerY, r1(k,1), r1(k,2));
        a2 = ml_alg_center_out_angle(centerX, centerY, r2(k,1), r2(k,2));

                    
        [angleDiff_deg] =  ml_alg_center_out_difference(a1, a2);

        % store
        angles(k) = angleDiff_deg;
    end

    
end% function
