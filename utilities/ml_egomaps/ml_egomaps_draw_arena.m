function ml_egomaps_draw_arena(ARENA_WIDTH_CM, ARENA_HEIGHT_CM)
    a = [0, ARENA_HEIGHT_CM];
    b = [0, 0];
    c = [ARENA_WIDTH_CM, 0];
    d = [ARENA_WIDTH_CM, ARENA_HEIGHT_CM];
    refCanPts = [a(1), b(1), c(1), d(1); a(2), b(2), c(2), d(2)];
    poly = refCanPts';

    plot(poly(:,1), poly(:,2), 'b-o', 'linewidth', 1)
    hold on
    plot([poly(1,1), poly(end,1)], [poly(1,2), poly(end,2)], 'b-o', 'linewidth', 1)
end
