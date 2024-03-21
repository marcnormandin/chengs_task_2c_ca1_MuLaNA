function angles = ml_alg_center_out_angle_continuous_circle_bias(nSamples)    
% This computes the samples of center out angles when points are
% picked uniformly at random from rectangular maps of size nX by nY
    centerX = 0;
    centerY = 0;

    angles = nan(1, nSamples);
    
    [x1,y1] = gen_samples_uniform_disk(nSamples);
    [x2,y2] = gen_samples_uniform_disk(nSamples);

    for k = 1:nSamples
        a1 = ml_alg_center_out_angle(centerX, centerY, x1(k), y1(k));
        a2 = ml_alg_center_out_angle(centerX, centerY, x2(k), y2(k));

                    
        [angleDiff_deg] =  ml_alg_center_out_difference(a1, a2);

        % store
        angles(k) = angleDiff_deg;
    end

    
end% function

function [x,y] = gen_samples_uniform_disk(nSamples)
    r = rand(1, nSamples);
    theta = 2*pi * rand(1, nSamples);
    x = sqrt(r) .* cos(theta);
    y = sqrt(r) .* sin(theta);
end
