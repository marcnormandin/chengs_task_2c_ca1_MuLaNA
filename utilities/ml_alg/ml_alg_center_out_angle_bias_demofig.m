rectWidth = 1;
rectHeight = 1;

nSamples = 1000000;
anglesBias1 = ml_alg_center_out_angle_continuous_bias(rectWidth, rectHeight, nSamples);
anglesBias2 = ml_alg_center_out_angle_continuous_circle_bias(nSamples);

edges = 0:1:360;

figure
subplot(1,2,1)
histogram(anglesBias1, edges)
title(sprintf('Picked from uniform rectangle (%d, %d)', rectWidth, rectHeight))
subplot(1,2,2)
histogram(anglesBias2, edges);
title('Picked from uniform disk')
sgtitle(sprintf('Showing center out distributions for (%d) points uniform from rectangle or disk', nSamples))
