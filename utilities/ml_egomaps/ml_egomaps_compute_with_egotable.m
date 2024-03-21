function [result] = ml_egomaps_compute_with_egotable(...
    animal_pos_x_cm, animal_pos_y_cm, animal_facing_angle_deg, ...
    cell_activation, ...
    ARENA_WIDTH_CM, ARENA_HEIGHT_CM, RADIUS_CM, EGOMAPS_CM_PER_BIN, EgoTable, showAnimation)

    %DISCRETIZATION_SCALE_FACTOR = 100;
%     EgoTable = ml_egomaps_compute_segment_table(...
%         animal_pos_x_cm, animal_pos_y_cm, animal_facing_angle_deg, ...
%         ARENA_WIDTH_CM, ARENA_HEIGHT_CM, RADIUS_CM, ...
%         DISCRETIZATION_SCALE_FACTOR);

    % Simulate an egocentric border cell. Now that we have the egocentric line
    % segments for the spatial data of the animal, we can simulate the
    % activation times for an egocentric border cell.
    % For discretization example (in EGOCENTRIC coordinates)
    binSystem = ml_egomaps_binsystem_create(RADIUS_CM, EGOMAPS_CM_PER_BIN);

    angleMap = ml_egomaps_binsystem_anglemap(binSystem);

    numSamples = length(animal_pos_x_cm);
    totalOccupancy = zeros(size(binSystem.XX));
    totalActivity = zeros(size(binSystem.XX));

    if showAnimation
        hFig = figure('position', get(0, 'screensize'));
    end

    animal_wall_angle_deg = zeros(size(animal_pos_x_cm));

    for iSample = 1:1:numSamples
        % Get the animal data for the current sample point
        cx = animal_pos_x_cm(iSample);
        cy = animal_pos_y_cm(iSample);
        facingAngleDeg = animal_facing_angle_deg(iSample);
        cellActivity = cell_activation(iSample);

        % Extract the data from the table
        allocentric_segments = EgoTable.allocentric_segments{iSample};
        egocentric_segments = EgoTable.egocentric_segments{iSample};

        % Get the discretized points, if they exist.
        egocentric_discretized_points = EgoTable.egocentric_discretized_points{iSample};

        % Compute the occupancy (where the line segments overlap the bins)
        if ~isempty(egocentric_discretized_points)
            occupancy = ml_bs_occupancy_xy(binSystem, egocentric_discretized_points(:,1), egocentric_discretized_points(:,2));
        else
            occupancy = zeros(size(binSystem.XX));
        end
        occupancy(occupancy >= 1) = 1;

        [i1, i2] = find(occupancy > 0);
        angles = zeros(1, length(i1));
        for k = 1:length(i1)
            angles(k) = angleMap(i1(k), i2(k));
        end
        animal_wall_angle_deg(iSample) = mean(angles);

        totalOccupancy = totalOccupancy + occupancy;

        activity = occupancy * cellActivity;
        totalActivity = totalActivity + activity;

        totalRate = totalActivity ./ totalOccupancy;
        totalRate(~isfinite(totalRate)) = 0;

        % DRAW
        if showAnimation
            clf(hFig, 'reset');

            % ALLOCENTRIC
            subplot(2,3,1)
            ml_egomaps_draw_arena(ARENA_WIDTH_CM, ARENA_HEIGHT_CM)
            hold on
            ml_egomaps_draw_circle(cx, cy, RADIUS_CM);
            ml_egomaps_draw_facing_direction(cx, cy, facingAngleDeg, RADIUS_CM)
            plot(cx,cy,'ko','markerfacecolor', 'k', 'markersize', 10)
            ml_egomaps_draw_segments(allocentric_segments)
            grid on
            set(gca, 'ydir', 'reverse')
            axis([-RADIUS_CM, ARENA_WIDTH_CM+RADIUS_CM, -RADIUS_CM, ARENA_HEIGHT_CM+RADIUS_CM])
            daspect([1 1 1])
            title('Allocentric')

            % EGOCENTRIC
            subplot(2,3,2)
            ml_egomaps_draw_segments(egocentric_segments)
            hold on
            plot([0,0], [0, -RADIUS_CM], 'g-', 'linewidth', 10)
            plot(0,0, 'ko', 'markerfacecolor', 'k', 'markersize', 10)
            ml_egomaps_draw_circle(0, 0, RADIUS_CM);
            set(gca, 'ydir', 'reverse')
            axis([-RADIUS_CM, RADIUS_CM, -RADIUS_CM, RADIUS_CM])
            daspect([1 1 1])
            grid on
            grid minor
            title('Egocentric')

            % Discretized bins
            subplot(2,3,3)
            O = nan(size(occupancy));
            O(occupancy == 1) = 1;
            pcolor(binSystem.XX, binSystem.YY, O)
            hold on
            ml_egomaps_draw_circle(0, 0, RADIUS_CM);
            set(gca, 'ydir', 'reverse');
            shading flat
            axis equal off
            hold on


            subplot(2,3,4)
            R = nan(size(totalOccupancy));
            R(totalOccupancy > 0) = totalOccupancy(totalOccupancy>0);
            %A(occupancy == 1) = 1;
            pcolor(binSystem.XX, binSystem.YY, R)
            hold on
            ml_egomaps_draw_circle(0, 0, RADIUS_CM);
            set(gca, 'ydir', 'reverse');
            shading flat
            axis equal off
            hold on
            title('Total Occupancy')



            subplot(2,3,5)
            A = nan(size(totalActivity));
            A(totalActivity > 0) = totalActivity(totalActivity > 0);
            pcolor(binSystem.XX, binSystem.YY, A)
            hold on
            ml_egomaps_draw_circle(0, 0, RADIUS_CM);
            set(gca, 'ydir', 'reverse');
            shading flat
            axis equal off
            hold on
            if cellActivity > 0
                title(sprintf('Total Cell Activity\n Currently Active => %0.2f', cellActivity))
            else
                title(sprintf('Total Cell Activity\n Currently Inactive'))
            end


            subplot(2,3,6)
            R = nan(size(totalRate));
            R(totalRate > 0) = totalRate(totalRate>0);
            %A(occupancy == 1) = 1;
            pcolor(binSystem.XX, binSystem.YY, R)
            hold on
            ml_egomaps_draw_circle(0, 0, RADIUS_CM);
            set(gca, 'ydir', 'reverse');
            shading flat
            axis equal off
            hold on
            title('Total Rate')




            sgtitle(sprintf('Allocentric heading\n%0.2f degrees clockwise from vertical', facingAngleDeg))
            pause(0.01);
        end % if showAnimation
    end % iSample
    
    result.binSystem = binSystem;
    result.totalOccupancy = totalOccupancy;
    result.totalActivity = totalActivity;
    result.totalRate = totalRate;
    result.animalWallAngle_deg = animal_wall_angle_deg;
end % function