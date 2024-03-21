close all
%clear all
clc

% This tests the code.
% Just change which example is used.

[m1, coa1, ax1, ay1, m2, coa2, ax2, ay2] = mk_example2a();

[angleDiff] =  ml_alg_center_out_difference(coa1, coa2);

m3 = zeros(30,20);

close all

figure
ax = [];
ax(1) = subplot(1,3,1);
imagesc(m1)
hold on
plot_coa(m1, ax1, ay1)
set(gca, 'ydir', 'reverse')
title(sprintf('%0.1f', coa1))
axis equal tight 

ax(2) = subplot(1,3,2);
imagesc(m2)
hold on
plot_coa(m2, ax2, ay2)
set(gca, 'ydir', 'reverse')
title(sprintf('%0.1f', coa2))
axis equal tight 


ax(3) = subplot(1,3,3);
imagesc(m3)
plot_coa(m1, ax1, ay1)
hold on
plot_coa(m2, ax2, ay2)
set(gca, 'ydir', 'reverse')
axis([0, 20, 0, 30])
axis equal tight 
title(sprintf('Difference: %0.1f', angleDiff))

linkaxes(ax, 'xy')



function [m1, coa1, ax1, ay1, m2, coa2, ax2, ay2] = mk_example1()
    m1 = mk_simmap(20, 14);
    [coa1, ax1, ay1] = ml_alg_center_out_angle(m1);
    
    m2 = mk_simmap(15, 20);
    [coa2, ax2, ay2] = ml_alg_center_out_angle(m2);
end

function [m1, coa1, ax1, ay1, m2, coa2, ax2, ay2] = mk_example2a()
    m1 = mk_simmap(20, 15);
    [coa1, ax1, ay1] = ml_alg_center_out_angle(m1);
    
    m2 = mk_simmap(1, 1);
    [coa2, ax2, ay2] = ml_alg_center_out_angle(m2);
end

function [m1, coa1, ax1, ay1, m2, coa2, ax2, ay2] = mk_example2b()
    m1 = mk_simmap(1, 1);
    [coa1, ax1, ay1] = ml_alg_center_out_angle(m1);
    
    m2 = mk_simmap(20, 15);
    [coa2, ax2, ay2] = ml_alg_center_out_angle(m2);
end

function [m1, coa1, ax1, ay1, m2, coa2, ax2, ay2] = mk_example3()
    m1 = mk_simmap(20, 1);
    [coa1, ax1, ay1] = ml_alg_center_out_angle(m1);
    
    m2 = mk_simmap(20, 20);
    [coa2, ax2, ay2] = ml_alg_center_out_angle(m2);
end



function m = mk_simmap(cx, cy)
    m = zeros(30,20);
    m(cy,cx) = 1;
    h = fspecial('gaussian', 30, 5);
    m = imfilter(m, h);
end % function

function plot_coa(m, ax, ay)
    centerX = size(m,2)/2;
    centerY = size(m,1)/2;
    
    plot(centerX, centerY, 'ko', 'markerfacecolor', 'k', 'markersize', 10);
    plot(ax, ay, 'go', 'markerfacecolor', 'g', 'markersize', 10);
    line([centerX, size(m,2)], [centerY, centerY], 'color', 'k', 'linewidth', 4);
    line([centerX, ax], [centerY, ay], 'color', 'g', 'linewidth', 4)
end
