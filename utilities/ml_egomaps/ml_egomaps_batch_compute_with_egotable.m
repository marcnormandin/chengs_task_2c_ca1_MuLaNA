function [result] = ml_egomaps_batch_compute_with_egotable(...
    pop_cell_activation, ...
    RADIUS_CM, EGOMAPS_CM_PER_BIN, EgoTable)
    % This code processes more than ones cells activity and doesnt make any
    % plots, but can with a callback with simple changes needed.

    numCells = size(pop_cell_activation,2);
    numSamples = size(pop_cell_activation,1); % This must match EgoTable
    if numSamples ~= size(EgoTable,1)
        error('EgoTable must have been made with the same number of samples as the activity.\n');
    end

    binSystem = ml_egomaps_binsystem_create(RADIUS_CM, EGOMAPS_CM_PER_BIN);
    angleMap = ml_egomaps_binsystem_anglemap(binSystem);

    totalOccupancy = zeros(size(binSystem.XX));
    totalActivity = zeros(size(binSystem.XX,1), size(binSystem.XX,2), numCells);

    animal_wall_angle_deg = zeros(numSamples, 1);

    % Process each sample using the table to speed up the calculations
    for iSample = 1:1:numSamples
        % Get the discretized points, if they exist.
        egocentric_discretized_points = EgoTable.egocentric_discretized_points{iSample};

        % Compute the occupancy (where the line segments overlap the bins)
        if ~isempty(egocentric_discretized_points)
            currentOccupancy = ml_bs_occupancy_xy(binSystem, egocentric_discretized_points(:,1), egocentric_discretized_points(:,2));
        else
            currentOccupancy = zeros(size(binSystem.XX));
        end
        % Make the map 0 or 1.
        currentOccupancy(currentOccupancy >= 1) = 1;

        % Accumlate into the total occupancy map
        totalOccupancy = totalOccupancy + currentOccupancy;

        % There may be more than one wall present, and so this computes
        % what the average angle to the walls is since it might be useful.
        [i1, i2] = find(currentOccupancy > 0);
        angles = zeros(1, length(i1));
        for k = 1:length(i1)
            angles(k) = angleMap(i1(k), i2(k));
        end
        animal_wall_angle_deg(iSample) = mean(angles);

        for iCell = 1:numCells
            % Get the animal data for the current sample point and cell
            currentCellActivity = pop_cell_activation(iSample, iCell);

            % Apply same activity to all occupied bins
            currentActivity = currentOccupancy .* currentCellActivity;

            % Accumulate into the total activity map for the cell
            totalActivity(:,:,iCell) = totalActivity(:,:,iCell) + currentActivity;
        end % iCell
    end % iSample

    % Make the total rate maps
    totalRate = zeros(size(binSystem.XX,1), size(binSystem.XX,2), numCells);
    % Do this the crappy way
    for iCell = 1:numCells
        totalRate(:,:,iCell) = totalActivity(:,:,iCell) ./ totalOccupancy;

        [i,j] = find(~isfinite(totalRate(:,:,iCell)));
        for k = 1:length(i)
            totalRate(i(k), j(k), iCell) = 0;
        end
    end % iCell

    % Store
    result.binSystem = binSystem;
    result.totalOccupancy = totalOccupancy;
    result.totalActivity = totalActivity;
    result.totalRate = totalRate;
    result.animalWallAngle_deg = animal_wall_angle_deg;
    result.RADIUS_CM = RADIUS_CM;
    result.EGOMAPS_CM_PER_BIN = EGOMAPS_CM_PER_BIN;
end % function