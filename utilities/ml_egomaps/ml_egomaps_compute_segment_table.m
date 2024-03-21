function [T] = ml_egomaps_compute_segment_table(...
    animal_pos_x_cm, animal_pos_y_cm, animal_facing_angle_deg, ...
    ARENA_WIDTH_CM, ARENA_HEIGHT_CM, RADIUS_CM, ...
    DISCRETIZATION_SCALE_FACTOR)

    % Facing angles are such that they increase clockwise and begin
    % vertical in "reversed" coordinates; y-axis increases downwards.

    numSamples = length(animal_pos_x_cm);
    
    T = [];
    k = 1;
    for iSample = 1:numSamples
        facingAngleDeg = animal_facing_angle_deg(iSample);

        % This is the main computation.
        allocentric_segments = compute_intersected_segments(animal_pos_x_cm(iSample), animal_pos_y_cm(iSample), RADIUS_CM, ARENA_WIDTH_CM, ARENA_HEIGHT_CM);

        if numel(allocentric_segments) ~= 0
            egocentric_segments = segments_allocentric_to_egocentric(animal_pos_x_cm(iSample), animal_pos_y_cm(iSample), facingAngleDeg, allocentric_segments);
        else
            egocentric_segments = [];
        end

%         % Convert from line segments to actual points along the line
%         % segments so that the points can be binned.
        segmentPoints = [];
        [bx, by] = discretize_points_of_segments(egocentric_segments, DISCRETIZATION_SCALE_FACTOR);
        bx = real(bx);
        by = real(by);
        if length(bx) ~= length(by)
            warning('length of discretized coordinates does not match: length(bx) = %d but length(by) = %d\n', length(bx), length(by))
        else
            if ~isempty(bx) && ~isempty(by)
                segmentPoints = unique([real(bx), real(by)], 'rows');
                bx = segmentPoints(:,1);
                by = segmentPoints(:,2);
            end
        end

        T(k).allocentric_segments = allocentric_segments;
        T(k).egocentric_segments = egocentric_segments;
        T(k).egocentric_discretized_points = segmentPoints;
        T(k).num_segments = size(allocentric_segments,1); % same as egocentric
        T(k).num_discretized_points = length(bx);
        k = k + 1;
    end
    T = struct2table(T);
end % function



function [bx, by] = discretize_points_of_segments(segments, DISCRETIZATION_SCALE_FACTOR)
    segments = segments * DISCRETIZATION_SCALE_FACTOR;
    bx = [];
    by = [];
    for iSegment = 1:size(segments,1)
        [sx, sy] = ml_egomaps_bresenham(segments(iSegment, 1), segments(iSegment, 2), ...
            segments(iSegment, 3), segments(iSegment, 4));
        bx = [bx; sx];
        by = [by; sy];
    end
    bx = bx ./ DISCRETIZATION_SCALE_FACTOR;
    by = by ./ DISCRETIZATION_SCALE_FACTOR;
end

function [egocentric_points] = convert_points_allocentric_to_egocentric(cx, cy, angle_deg, allocentric_points)
    % Allocentric points must be a Nx2 matrix, where first column is x and
    % second is y.
    
    A1 = allocentric_points;
    A1(:,3) = 1; % add z
    A2 = A1 - [cx, cy, 1];
    B = rotz(-angle_deg) * A2';
    B1 = B;
    B1(3,:) = []; % remove z

    egocentric_points = B1';      
end % function

function [segments] = convert_points_to_segments(points)
    segments = reshape(points', 4, numel(points)/4)';
end

function [points] = convert_segments_to_points(segments)
    points = reshape(segments', 2, size(segments,1)*2)';
end

function [egocentric_segments] = segments_allocentric_to_egocentric(cx, cy, angle_deg, allocentric_segments)
    % Segments are Nx4 where each row is x1, y1, x2, y2 ends of a line
    % segment.
    
    % Reshape to 2*Nx2 array
    allocentric_points = convert_segments_to_points(allocentric_segments);
    
    % Convert each x,y point from allocentric to egocentric
    egocentric_points = convert_points_allocentric_to_egocentric(cx, cy, angle_deg, allocentric_points);
    
    % Reshape back into Nx4 array
    egocentric_segments = convert_points_to_segments(egocentric_points);
end % function

% This is the main computation
function [segments] = compute_intersected_segments(cx, cy, R, ARENA_WIDTH, ARENA_HEIGHT)
    % This version returns intersections and corners if no second
    % intersection
    
    segments = [];
    % top
    dy = cy;
    if dy < R
        dx = R * sin(acos(dy/R));
        ix1 = cx - dx;
        ix2 = cx + dx;
        
        % two intersections
        if ix1 >= 0 && ix1 <= ARENA_WIDTH && ix2 >= 0 && ix2 <= ARENA_WIDTH
            nl = [ix1, 0, ix2, 0];
        elseif ix1 >= 0 && ix1 <= ARENA_WIDTH
            % only x1 was found, not x2, so add the left corner
            nl = [ix1, 0, ARENA_WIDTH, 0];
        else
            % only x2 was found, not x1, so add the right corner
            nl = [ix2, 0, 0, 0];
        end
        
        segments(end+1,:) = nl;
    end
    % bottom
    dy = ARENA_HEIGHT - cy;
    if dy < R
        dx = R*cos(asin(dy/R));
        ix1 = cx - dx;
        ix2 = cx + dx;
        if ix1 >= 0 && ix1 <= ARENA_WIDTH && ix2 >= 0 && ix2 <= ARENA_WIDTH
            nl = [ix1, ARENA_HEIGHT, ix2, ARENA_HEIGHT];
        elseif ix1 >= 0 && ix1 <= ARENA_WIDTH
            nl = [ix1, ARENA_HEIGHT, ARENA_WIDTH, ARENA_HEIGHT];
        else
            nl = [ix2, ARENA_HEIGHT, 0, ARENA_HEIGHT];
        end
        
        segments(end+1, :) = nl;
    end
    % left
    dx = cx;
    if dx < R
        dy = R*sin(acos(dx/R));
        iy1 = cy - dy;
        iy2 = cy + dy;
        if iy1 >= 0 && iy1 <= ARENA_HEIGHT && iy2 >= 0 && iy2 <= ARENA_HEIGHT
            nl = [0, iy1, 0, iy2];
        elseif iy1 >= 0 && iy1 <= ARENA_HEIGHT
            nl = [0, iy1, 0, ARENA_HEIGHT];
        else
            nl = [0, iy2, 0, 0];
        end
        
        segments(end+1, :) = nl;
    end
    % right
    dx = ARENA_WIDTH - cx;
    if dx < R
        dy = R*cos(asin(dx/R));
        iy1 = cy - dy;
        iy2 = cy + dy;
        if iy1 >= 0 && iy1 <= ARENA_HEIGHT && iy2 >= 0 && iy2 <= ARENA_HEIGHT
            nl = [ARENA_WIDTH, iy1, ARENA_WIDTH, iy2];
        elseif iy1 >= 0 && iy1 <= ARENA_HEIGHT
            nl = [ARENA_WIDTH, iy1, ARENA_WIDTH, ARENA_HEIGHT];            
        else
            nl = [ARENA_WIDTH, iy2, ARENA_WIDTH, 0];
        end
        
        segments(end+1, :) = nl;
    end
end
