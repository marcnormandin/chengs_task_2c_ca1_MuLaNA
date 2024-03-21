function [animal_facing_angle_deg] = ml_clean_headdirection_data(animal_facing_angle_deg, animal_pos_t_mus, showFigures)
    animal_pos_t_s = animal_pos_t_mus ./ 10^6;
    animal_pos_t_s = animal_pos_t_s - animal_pos_t_s(1);

    if showFigures
        figure
        plot(animal_pos_t_s, animal_facing_angle_deg, 'k.-')
        title('Raw Data');
    end

    original_animal_facing_angle_deg = animal_facing_angle_deg;
    animal_facing_angle_deg = original_animal_facing_angle_deg;

    THRESHOLD = 1000;
    ginfo = find_inds_over_threshold(animal_pos_t_s, animal_facing_angle_deg, THRESHOLD);

    [ginfo, animal_facing_angle_deg, fixedInds1] = fix_180_offsets(ginfo, animal_facing_angle_deg);
    [ginfo, animal_facing_angle_deg, fixedInds2] = fix_360_wraps(ginfo, animal_facing_angle_deg);
    [ginfo, animal_facing_angle_deg, fixedInds3] = fix_discontinuities(ginfo, animal_facing_angle_deg);

    [ginfo, animal_facing_angle_deg, fixedInds4] = fix_360_wraps(ginfo, animal_facing_angle_deg);




    fixedInds = [];
    fixedInds = [fixedInds, fixedInds1];
    fixedInds = [fixedInds, fixedInds2];
    fixedInds = [fixedInds, fixedInds3];
    fixedInds = [fixedInds, fixedInds4];
    fixedInds = unique(fixedInds);

    isBad = false(1, length(animal_facing_angle_deg));
    isBad([ginfo.inds]) = true;

    g2 = ml_util_group_points_v2(isBad);
        g2info = [];
        for k = 1:max(g2)
           i = find(g2 == k);
           g2info(k).inds = i;
           g2info(k).count = length(i);
           g2info(k).isBad = isBad(i(1));
        end


    % See how long a segment of good data each point belongs to
    metric = zeros(size(isBad));
    % for i = 1:length(animal_facing_angle_deg)
    %    metric(i) = min(abs(i - [ginfo.inds]));
    % end
    for k = 1:length(g2info)
       gi = g2info(k);

       if ~gi.isBad
          metric(gi.inds) = gi.count; 
       end
    end

    THRESHOLD_METRIC = 20;
    belowContinuityInds = find(metric <= THRESHOLD_METRIC);

    % Now group the points found using the continuity metric
    g3 = ml_util_group_points(belowContinuityInds, 1);
    g3info = [];
    for k = 1:max(g3)
       i = find(g3 == k);
       g3info(k).inds = belowContinuityInds(i);
       g3info(k).count = length(i);
    end

    fixedIndsMetric = [];
    for k = 1:length(g3info)
       leftAngleDeg = animal_facing_angle_deg(g3info(k).inds(1));
       rightAngleDeg = animal_facing_angle_deg(g3info(k).inds(end));

       % Classify into two cases based on the left and right points of the bad
       % group of points.
       bufferDeg = 45;

       % For each endpoint, see which of the 3 angular regions it is in
       % Upper board, interior, lower border
       if leftAngleDeg < bufferDeg
           leftAngleRegion = 1;
       elseif leftAngleDeg > (360 - bufferDeg)
           leftAngleRegion = 2;
       else
           leftAngleRegion = 10;
       end

       if rightAngleDeg < bufferDeg
           rightAngleRegion = 1;
       elseif rightAngleDeg > (360 - bufferDeg)
           rightAngleRegion = 2;
       else
           rightAngleRegion = 10;
       end

       if leftAngleRegion == rightAngleRegion
           % Same region so use a linear fit for the bad points
           da = rightAngleDeg - leftAngleDeg;
           dn = g3info(k).inds(end) - g3info(k).inds(1);
           m = da / dn;
           y = leftAngleDeg + m * (g3info(k).inds - g3info(k).inds(1));
           animal_facing_angle_deg(g3info(k).inds) = y;

           fixedIndsMetric = [fixedIndsMetric, g3info(k).inds];
       elseif abs(leftAngleRegion - rightAngleRegion) == 1
           % Endpoints are in different buffer regions
           % Walk the line!
           % Get the mean angle of the bad points and see what they are closer
           % to
           meanAngleBadPoints = mean(animal_facing_angle_deg(g3info(k).inds));
           if abs(leftAngleDeg - meanAngleBadPoints) < abs(rightAngleDeg - meanAngleBadPoints)
               animal_facing_angle_deg(g3info(k).inds) = leftAngleDeg;
           else
               animal_facing_angle_deg(g3info(k).inds) = rightAngleDeg;
           end
           fixedIndsMetric = [fixedIndsMetric, g3info(k).inds];

       else
           % Shittier situation (One endpoint is in interior)
           da = rightAngleDeg - leftAngleDeg;
           dn = g3info(k).inds(end) - g3info(k).inds(1);
           m = da / dn;
           y = leftAngleDeg + m * (g3info(k).inds - g3info(k).inds(1));
           animal_facing_angle_deg(g3info(k).inds) = y;

           fixedIndsMetric = [fixedIndsMetric, g3info(k).inds];
       end
    end


    if showFigures
        ax = [];
        figure('position', get(0, 'screensize'));
        ax(1) = subplot(3,1,1);
        plot(animal_pos_t_s, original_animal_facing_angle_deg, 'k:')
        hold on
        plot(animal_pos_t_s, animal_facing_angle_deg, 'k.-')
        hold on
        plot(animal_pos_t_s([ginfo.inds]), animal_facing_angle_deg([ginfo.inds]), 'ro', 'markerfacecolor', 'r')
        axis tight

        % Show the fixed inds
        %plot(animal_pos_t_s(fixedInds), animal_facing_angle_deg(fixedInds), 'go', 'markerfacecolor', 'g');

        ax(2) = subplot(3,1,2);
        %stem(animal_pos_t_s, isBad, 'r')
        plot(animal_pos_t_s, metric)

        ax(3) = subplot(3,1,3);
        plot(animal_pos_t_s, original_animal_facing_angle_deg, 'k:')
        hold on
        plot(animal_pos_t_s, animal_facing_angle_deg, 'k.-')
        hold on
        plot(animal_pos_t_s([ginfo.inds]), animal_facing_angle_deg([ginfo.inds]), 'ro', 'markerfacecolor', 'r')
        axis tight
        plot(animal_pos_t_s(belowContinuityInds), animal_facing_angle_deg(belowContinuityInds), 'bo', 'markerfacecolor', 'b')
        plot(animal_pos_t_s(fixedIndsMetric), animal_facing_angle_deg(fixedIndsMetric), 'go', 'markerfacecolor', 'g')
        yline(bufferDeg, 'r', 'linewidth', 4)
        yline(360-bufferDeg, 'r', 'linewidth', 4)
        linkaxes(ax, 'x')
        title('Green was fixed')
    end





    % Plot the original and final for comparison
    if showFigures
        figure('position', get(0, 'screensize'));
        ax = [];

        ax(1) = subplot(2,1,1);
        plot(animal_pos_t_s, original_animal_facing_angle_deg, 'r-', 'linewidth', 1)
        grid on
        axis tight
        title('RAW')

        ax(2) = subplot(2,1,2);
        plot(animal_pos_t_s, animal_facing_angle_deg, 'k-', 'linewidth', 1)
        grid on
        axis tight
        title('CLEANED')

        linkaxes(ax, 'xy')


    %     changedInds = find(animal_facing_angle_deg ~= original_animal_facing_angle_deg);
    %     gfinal = ml_util_group_points(changedInds,1);
    %     gfinalInfo = [];
    %     for k = 1:max(gfinal)
    %        i = find(gfinal == k);
    %        gfinalInfo(k).inds = changedInds(i);
    %        gfinalInfo(k).count = length(i);
    %     end
    %
    %     for k = 1:length(gfinalInfo)
    %         plot(animal_pos_t_s(gfinalInfo(k).inds), animal_facing_angle_deg(gfinalInfo(k).inds), 'r-', 'linewidth', 1)
    %     end

    end
end % function


function [ginfo, animal_facing_angle_deg, fixedInds] = fix_discontinuities(ginfo, animal_facing_angle_deg)
    wasFixed = false(length(ginfo),1);
    
    for k = 1:length(ginfo)
       leftInd = ginfo(k).inds(1);
       rightInd = ginfo(k).inds(end);
       leftAngleDeg = animal_facing_angle_deg(leftInd);
       rightAngleDeg = animal_facing_angle_deg(rightInd);
       
       da = rightAngleDeg - leftAngleDeg;
       dn = rightInd - leftInd;
       m = da / dn;
       
       if abs(da) < 20
           wasFixed(k) = true;
           
           y = leftAngleDeg + m .* (ginfo(k).inds - leftInd);
           
           animal_facing_angle_deg(ginfo(k).inds) = y;
       end
    end
    
    ginfoFixed = ginfo(wasFixed);
    fixedInds = [ginfoFixed.inds];
    ginfo(wasFixed) = [];
end


function [ginfo, animal_facing_angle_deg, fixedInds] = fix_360_wraps(ginfo, animal_facing_angle_deg)
    wasFixed = false(length(ginfo),1);
    
    for k = 1:length(ginfo)
       if ginfo(k).count == 2
           a = animal_facing_angle_deg(ginfo(k).inds(1));
           b = animal_facing_angle_deg(ginfo(k).inds(2));

           %fprintf('%d ', abs(a-b)-360)
           m = abs(abs(a-b) - 360);
           if m < 20 
                wasFixed(k) = true;
           end
       end
    end
    
    ginfoFixed = ginfo(wasFixed);
    fixedInds = [ginfoFixed.inds];
    ginfo(wasFixed) = [];
end

function [ginfo, animal_facing_angle_deg, fixedInds] = fix_180_offsets(ginfo, animal_facing_angle_deg)
    wasFixed = false(length(ginfo),1);

    for k = 1:length(ginfo)
        if ginfo(k).count == 3
            animal_facing_angle_deg(ginfo(k).inds(2)) = mean(animal_facing_angle_deg(ginfo(k).inds([1,3])));
            wasFixed(k) = true;
        end
    end
    ginfoFixed = ginfo(wasFixed);
    fixedInds = [ginfoFixed.inds];
    ginfo(wasFixed) = [];
end % function

function [ginfo] = find_inds_over_threshold(animal_pos_t_s, animal_facing_angle_deg, THRESHOLD)
    dt = diff(animal_pos_t_s);
    dangle = diff(animal_facing_angle_deg);
    av = abs(dangle ./ dt);

    ind1 = find(av>= THRESHOLD);
    ind2 = ind1 + 1;
    inds = [ind1, ind2];
    %inds = ind1;
    inds(inds < 1 | inds > length(animal_facing_angle_deg)) = [];
    inds = unique(inds);

    % classes = zeros(size(animal_pos_t_s));
    % classes(inds) = 1;
    gids = ml_util_group_points(inds,1);
    ginfo = [];
    for k = 1:max(gids)
       i = find(gids == k);
       ginfo(k).inds = inds(i);
       ginfo(k).count = length(i);
    end

end % function
