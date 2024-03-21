function ml_egomaps_draw_segments(segments)
    % Each row has x1y1x2y2 coordinates for a line segment
    hold on
    for k = 1:size(segments,1)
        plot(segments(k,1), segments(k,2), 'ro', 'markerfacecolor', 'r', 'markersize', 10);
        plot(segments(k,3), segments(k,4), 'ro', 'markerfacecolor', 'r', 'markersize', 10);
    end
    for k = 1:size(segments,1)
        plot([segments(k,1), segments(k,3)], [segments(k,2), segments(k,4)], 'k-', 'linewidth', 2);
    end
end % function
