classdef MLSpikePlacemap < handle

    properties (SetAccess = private)
        % Copies of the inputs
        x = [];
        y = [];
        ts_ms = [];
        spike_ts_ms = [];
        
        % Either input or defaults
        boundsx = [];%
        boundsy = [];
        nbinsx = [];
        nbinsy = [];
        smoothingKernel = [];
        
        % Save the parameter structure
        p = [];
        
        % Discretized values
        spike_x = [];
        spike_y = [];
        xi = [];
        yi = [];
        sxi = [];
        syi = [];
        xedges = [];
        yedges = [];
        x_bounded = [];
        y_bounded = [];
        
        passedSpeedi = [];
        passed_x = [];
        passed_y = [];
        passed_ts_ms = [];
        
        passedSpeedSpikei = []; % These are indices into the position of spikes that passed the spike thresholds
        passed_spike_ts_ms = [];
        passed_spike_x = [];
        passed_spike_y = [];

        speed_cm_per_second = [];
        
        % Two-dimensional maps
        spikeCountMapTrue = []; % before criteria
        spikeCountMap = []; % after criteria
        visitedCountMap = [];
        dwellTimeMapTrue = []; % before criteria
        dwellTimeMap = []; % after criteria
        meanFiringRateMap = [];
        positionProbMap = [];
        meanFiringRate = [];
        peakFiringRate = [];
        
        % Smoothed two-dimensional maps
        spikeCountMapSmoothed = [];
        meanFiringRateMapSmoothed = [];
        dwellTimeMapSmoothed = [];
        positionProbMapSmoothed = [];
        meanFiringRateSmoothed = [];
        peakFiringRateSmoothed = [];
        informationRateSmoothed = [];
        informationPerSpikeSmoothed = [];
            
        % Computed values
        informationRate = 0;
        informationPerSpike = 0;
        totalSpikesAfterCriteria = 0;
        totalSpikesBeforeCriteria = 0;
        totalDwellTime = 0;
        isPlaceCell = false;
        
        % optional computed values
        informationRate_pvalue = -1;
        informationPerSpike_pvalue = -1;
        informationRateSim = [];
        informationPerSpikeSim = [];
    end
    
    methods
        function obj = MLSpikePlacemap(x, y, ts_ms, spike_ts_ms, varargin)
            p = inputParser;
            p.CaseSensitive = false;
            
            checkArray = @(x) isnumeric(x);
            checkBounds = @(a) length(a) == 2 && a(1) < a(2) && isnumeric(a);
            checkPositive = @(x) length(x) == 1 && x > 0 && isnumeric(x);
            checkPositiveOrZero = @(x) length(x) == 1 && x >= 0 && isnumeric(x);
            
            % Required
            addRequired(p, 'x', checkArray);
            addRequired(p, 'y', checkArray);
            addRequired(p, 'ts_ms', checkArray);
            addRequired(p, 'spike_ts_ms', checkArray);
     
            
            
            % Parameters

                        
                        
            defaultKernel = fspecial('gaussian', 15, 3);
            defaultKernel = defaultKernel ./ max(defaultKernel(:));
            
            
            

            availableSmoothingProtocols = {...
                'SmoothAfterDivision', ...
                'SmoothBeforeDivision' ...
                };
            
            addParameter(p,'smoothingProtocol','SmoothBeforeDivision',...
                 @(x) any(validatestring(x,availableSmoothingProtocols)));
            addParameter(p, 'speed_cm_per_second', []);
            addParameter(p, 'boundsx', [min(x), max(x)], checkBounds);
            addParameter(p, 'boundsy', [min(y), max(y)], checkBounds);
            addParameter(p, 'nbinsx', 20, checkPositive);
            addParameter(p, 'nbinsy', 30, checkPositive);
            addParameter(p, 'smoothingKernel', defaultKernel, @(x) isnumeric(x) );
            addParameter(p, 'criteriaDwellTimeSecondsPerBinMinimum', 0, checkPositiveOrZero);
            addParameter(p, 'criteriaSpikesPerBinMinimum', 0, checkPositiveOrZero);
            addParameter(p, 'criteriaSpikesPerMapMinimum', 15, checkPositiveOrZero);
            addParameter(p, 'criteria_speed_cm_per_second_minimum', 0, checkPositiveOrZero);
            addParameter(p, 'criteria_speed_cm_per_second_maximum', inf, checkPositiveOrZero);
            addParameter(p, 'compute_information_rate_pvalue', false, @(x) islogical(x));
            
            % Store the required inputs
            obj.x = x;
            obj.y = y;
            obj.ts_ms = ts_ms;
            obj.spike_ts_ms = spike_ts_ms;
            
            % Process the inputs and optionals
            parse(p, x, y, ts_ms, spike_ts_ms, varargin{:});
            
            % Store the values that will be used
            obj.boundsx = p.Results.boundsx;
            obj.boundsy = p.Results.boundsy;
            obj.nbinsx = p.Results.nbinsx;
            obj.nbinsy = p.Results.nbinsy;
            obj.smoothingKernel = p.Results.smoothingKernel;
            obj.speed_cm_per_second = p.Results.speed_cm_per_second;
            obj.totalSpikesBeforeCriteria = length(obj.spike_ts_ms);
            obj.spike_x = interp1( obj.ts_ms, obj.x, obj.spike_ts_ms );
            obj.spike_y = interp1( obj.ts_ms, obj.y, obj.spike_ts_ms );
            
            obj.p = p;
            
            % Check that the array lengths are the same length and that the
            % timestamps are valid.
            numPoints = length(obj.x);
            if length(obj.y) ~= numPoints || length(obj.ts_ms) ~= numPoints
                error('The arrays x, y, and ts_ms must all be the same length!');
            end
            if any(diff(obj.ts_ms) < 0)
                error('The timestamp array, ts_ms, must be monotonically increasing, but it is not!');
            end

            
            compute(obj);
        end
        
        function compute(obj)
            % We only want to use spikes that are above the speed criteria
            % threshold for inclusion in the map
            if ~isempty(obj.speed_cm_per_second)
                if length(obj.speed_cm_per_second) ~= length(obj.x)
                    error('The speed positions should be arrays of the same length')
                end
                % For each spike we see if it passes the threshold, if not,
                % we remove it
                spike_spe = interp1( obj.ts_ms, obj.speed_cm_per_second, obj.spike_ts_ms );
                
                passedSpeedi1 = find(spike_spe >= obj.p.Results.criteria_speed_cm_per_second_minimum);
                passedSpeedi2 = find(spike_spe <= obj.p.Results.criteria_speed_cm_per_second_maximum);
                
                obj.passedSpeedSpikei = intersect(passedSpeedi1, passedSpeedi2);
                % The above finds the unique spike indices, but there may
                % be more than one spike per index
            else
                obj.passedSpeedSpikei = 1:length(obj.spike_ts_ms);
            end
            obj.passed_spike_x = obj.spike_x(obj.passedSpeedSpikei);
            obj.passed_spike_y = obj.spike_y(obj.passedSpeedSpikei);
            obj.passed_spike_ts_ms = obj.spike_ts_ms(obj.passedSpeedSpikei);
            
            % Now threshold the paths as well
            if ~isempty(obj.speed_cm_per_second)     
                passedSpeedi1 = find(obj.speed_cm_per_second >= obj.p.Results.criteria_speed_cm_per_second_minimum);
                passedSpeedi2 = find(obj.speed_cm_per_second <= obj.p.Results.criteria_speed_cm_per_second_maximum);
                obj.passedSpeedi = intersect(passedSpeedi1, passedSpeedi2);
            else
                obj.passedSpeedi = 1:length(obj.speed_cm_per_second);
            end
            obj.passed_x = obj.x(obj.passedSpeedi);
            obj.passed_y = obj.y(obj.passedSpeedi);
            obj.passed_ts_ms = obj.ts_ms(obj.passedSpeedi);
            
            
            %fprintf('%d spikes have been excluded using the speed criteria.\n', length(obj.spike_ts_ms) - length(obj.passed_spike_ts_ms));
            %fprintf('%d spikes have passed the speed criteria.\n', length(obj.passed_spike_ts_ms));

            [obj.x_bounded, obj.y_bounded, obj.xi, obj.yi, obj.xedges, obj.yedges] = ...
                ml_core_compute_binned_positions(obj.passed_x, obj.passed_y, obj.boundsx, obj.boundsy, obj.nbinsx, obj.nbinsy);

            % Recompute the spike location since we could have potentially changed
            % the subjects location when the spike occurred. 
%             obj.sxi = obj.xi( obj.passedSpeedSpikei );
%             obj.syi = obj.yi( obj.passedSpeedSpikei );

            obj.visitedCountMap = ml_placefield_visitedcountmap( obj.xi, obj.yi, obj.nbinsx, obj.nbinsy);

            % The spike count map before applying the criteria


            [~, ~, obj.sxi, obj.syi, ~, ~] = ...
                ml_core_compute_binned_positions(obj.passed_spike_x, obj.passed_spike_y, obj.boundsx, obj.boundsy, obj.nbinsx, obj.nbinsy);
            
            obj.spikeCountMapTrue = ml_placefield_spikecountmap( obj.sxi, obj.syi, obj.nbinsx, obj.nbinsy);
            
            % The spike count map after applying the criteria
            obj.spikeCountMap = obj.spikeCountMapTrue;
            obj.spikeCountMap(obj.spikeCountMap < obj.p.Results.criteriaSpikesPerBinMinimum) = 0;
            
            % Check the order because the results will be different if we
            % check number of spikes per bin after the total
            if sum(obj.spikeCountMap, 'all') < obj.p.Results.criteriaSpikesPerMapMinimum
                fprintf('Not enough spikes per map. Found (%d), but require (%d).\n', ...
                    sum(obj.spikeCountMap,'all'), obj.p.Results.criteriaSpikesPerMapMinimum);
            
                obj.spikeCountMap = zeros(size(obj.spikeCountMap));
            end
            
            obj.spikeCountMapSmoothed = imfilter( obj.spikeCountMap, obj.smoothingKernel);
            
            % The dwell time map before applying the criteria
            ts_s = (obj.ts_ms - obj.ts_ms(1)) ./ (1.0*10^3);
            median_dt = median(diff(ts_s), 'all');
            obj.dwellTimeMapTrue = ml_placefield_dwelltimemap_v2(obj.xi, obj.yi, median_dt, obj.nbinsx, obj.nbinsy);

            % The dwell time map after applying the criteria
            obj.dwellTimeMap = obj.dwellTimeMapTrue;
            obj.dwellTimeMap( obj.dwellTimeMap < obj.p.Results.criteriaDwellTimeSecondsPerBinMinimum ) = 0;
            
            obj.dwellTimeMapSmoothed = imfilter( obj.dwellTimeMap, obj.smoothingKernel);
            
            % PUT THIS BACK
            %obj.dwellTimeMapSmoothed( obj.dwellTimeMapSmoothed < obj.p.Results.criteriaDwellTimeSecondsPerBinMinimum ) = 0;

            
            % Use the unsmoothed maps that passed the criteria
            obj.meanFiringRateMap = ml_placefield_meanfiringratemap(obj.spikeCountMap, obj.dwellTimeMap );

            % Method 1
            if strcmpi(obj.p.Results.smoothingProtocol, 'SmoothBeforeDivision')
                obj.meanFiringRateMapSmoothed = ml_placefield_meanfiringratemap( obj.spikeCountMapSmoothed, obj.dwellTimeMapSmoothed );
            elseif strcmpi(obj.p.Results.smoothingProtocol, 'SmoothAfterDivision')
            % Method 2
                obj.meanFiringRateMapSmoothed = imfilter( obj.meanFiringRateMap, obj.smoothingKernel);
            else
                error('Invalid value for placemaps.smoothingProtocol (%s). Must be SmoothBeforeDivision or SmoothAfterDivision.', obj.p.Results.smoothingProtocol);
            end
            
            % Calculate some values from the maps (use the unsmoothed maps)
            obj.positionProbMap = ml_placefield_positionprobmap( obj.dwellTimeMap );
            [obj.meanFiringRate, obj.peakFiringRate] = ml_placefield_firingrate( obj.meanFiringRateMap, obj.positionProbMap );
            
            [obj.informationRate, obj.informationPerSpike] = ml_placefield_informationcontent_v2( obj.meanFiringRateMap, obj.positionProbMap );
            
            % Calculate the values using the smoothed maps
            obj.positionProbMapSmoothed = ml_placefield_positionprobmap( obj.dwellTimeMapSmoothed );

            % The previous code computes the mean only over bins that were
            % visited.
            tmp1 = obj.meanFiringRateMapSmoothed .* (obj.dwellTimeMapSmoothed > obj.p.Results.criteriaDwellTimeSecondsPerBinMinimum);
            tmp1(tmp1 == 0) = [];
            obj.meanFiringRateSmoothed = mean(tmp1, 'all'); % the previous code takes the mean not including bins with zero counts

            tmp2 = obj.meanFiringRateMapSmoothed .* (obj.dwellTimeMapSmoothed > obj.p.Results.criteriaDwellTimeSecondsPerBinMinimum);
            obj.peakFiringRateSmoothed = max(tmp2, [], 'all');
            
            
            [obj.informationRateSmoothed, obj.informationPerSpikeSmoothed] = ml_placefield_informationcontent_v2( obj.meanFiringRateMapSmoothed, obj.positionProbMapSmoothed );

            
            %[obj.informationRate, obj.informationPerSpike] = ml_placefield_informationcontent( obj.meanFiringRate, obj.meanFiringRateMap, obj.positionProbMap );


            
    
            obj.totalSpikesAfterCriteria = sum(obj.spikeCountMap, 'all');
            obj.totalDwellTime = sum(obj.dwellTimeMapTrue, 'all');
            
            if obj.meanFiringRate > 0.1 && obj.meanFiringRate < 5.0 && obj.informationRate > 0.5
                obj.isPlaceCell = true;
            end
            
            if obj.p.Results.compute_information_rate_pvalue
                obj.compute_information_rate_pvalue();
            end
        end % function
        
        function compute_information_rate_pvalue(obj)
            pmTrue = obj;
            
            % The true information
            mx = pmTrue.x;
            my = pmTrue.y;
            ts_ms = pmTrue.ts_ms;
            spike_ts_ms = pmTrue.spike_ts_ms;


            % Now compute the shuffled distribution
            shiftMin_ms = 20 * 1000;
            numDraws = 1000;

%             tshift_min = shiftMin_ms;
%             tshift_max = ts_ms(end) - ts_ms(1) - tshift_min;
%             tshift_draw = (tshift_max - tshift_min).*rand(1,numDraws) + tshift_min;
            
            [tshift_draw_ms, tshift_draw_n] = ml_util_rand_timeshift(ts_ms, shiftMin_ms, numDraws);

            % Allocate memory
            informationRateSim = zeros(1, numDraws);
            informationPerSpikeSim = zeros(1, numDraws);

            %h = figure();
            for iDraw = 1:numDraws
                sim_spike_ts_ms = spike_ts_ms + tshift_draw_ms(iDraw);
                outsideRange_indices = find(sim_spike_ts_ms > ts_ms(end));
                sim_spike_ts_ms(outsideRange_indices) = sim_spike_ts_ms(outsideRange_indices) - ts_ms(end) + ts_ms(1);
                %disp(outsideRange_indices)

                % We shouldn't need to sort them by time, but lets do it.
                sim_spike_ts_ms = sort(sim_spike_ts_ms);

                pmSim = MLSpikePlacemap(mx, my, ts_ms, sim_spike_ts_ms, ...
                    'smoothingProtocol', pmTrue.p.Results.smoothingProtocol, ...
                    'speed_cm_per_second', pmTrue.p.Results.speed_cm_per_second, ...
                    'boundsx', pmTrue.p.Results.boundsx, ...
                    'boundsy', pmTrue.p.Results.boundsy, ...
                    'nbinsx', pmTrue.p.Results.nbinsx, ...
                    'nbinsy', pmTrue.p.Results.nbinsy, ...
                    'smoothingKernel', pmTrue.p.Results.smoothingKernel, ...
                    'criteriaDwellTimeSecondsPerBinMinimum', pmTrue.p.Results.criteriaDwellTimeSecondsPerBinMinimum, ...
                    'criteriaSpikesPerBinMinimum', pmTrue.p.Results.criteriaSpikesPerBinMinimum, ...
                    'criteriaSpikesPerMapMinimum', pmTrue.p.Results.criteriaSpikesPerMapMinimum, ...
                    'criteria_speed_cm_per_second_minimum', pmTrue.p.Results.criteria_speed_cm_per_second_minimum, ...
                    'criteria_speed_cm_per_second_maximum', pmTrue.p.Results.criteria_speed_cm_per_second_maximum, ...
                    'compute_information_rate_pvalue', false);
                
%                 figure
%                 subplot(1,2,1)
%                 pmSim.plot_path_with_spikes()
%                 title(sprintf('Shuffle %d', iDraw))
%                 subplot(1,2,2)
%                 pmSim.plot();

%                 plot(sim_spike_ts_ms, iDraw.*ones(1,length(sim_spike_ts_ms)), 'r.')
%                 hold on

                informationRateSim(iDraw) = pmSim.informationRate;
                informationPerSpikeSim(iDraw) = pmSim.informationPerSpike;

            %     figure
            %     pmSim.plot_path_with_spikes()
            end

            obj.informationRate_pvalue = 1 - normcdf(pmTrue.informationRate, mean(informationRateSim), std(informationRateSim));
            obj.informationPerSpike_pvalue = 1 - normcdf(pmTrue.informationPerSpike, mean(informationPerSpikeSim), std(informationPerSpikeSim));
            obj.informationRateSim = informationRateSim;
            obj.informationPerSpikeSim = informationPerSpikeSim;
        end
        
        function plot_path_with_spikes(obj)
            plot(obj.x, obj.y, '-', 'color', [0,0,0,0.4]);

            hold on
            % These are the spikes that passed the velocity check
            spikeScatter1 = scatter(obj.passed_spike_x, obj.passed_spike_y, 50, 'ro', 'markerfacecolor', 'r');
            %spikeScatter1.MarkerFaceAlpha = 0.4;
            %spikeScatter1.MarkerEdgeAlpha = 0.8;

            set(gca, 'ydir', 'reverse')
            axis equal off
        end
        
        function plot_path_with_spikes_all(obj)
            plot(obj.x, obj.y, '-', 'color', [0,0,0,0.4]);

            hold on
            % These are the spikes that passed the velocity check
            spikeScatter1 = scatter(obj.spike_x, obj.spike_y, 50, 'ko', 'markerfacecolor', 'k');
            spikeScatter1.MarkerFaceAlpha = 0.4;
            spikeScatter1.MarkerEdgeAlpha = 0.8;

            set(gca, 'ydir', 'reverse')
            axis equal off
        end
        
        function plot(obj)
            [nr,nc] = size(obj.meanFiringRateMapSmoothed);
            
            pm = obj.meanFiringRateMapSmoothed;
            %pm(obj.visitedCountMap == 0) = nan;
            pcolor( [pm, nan(nr,1); nan(1,nc+1)] );
            shading interp;
            set(gca, 'ydir', 'reverse');

            title(sprintf('(%0.2f, %0.2f) Hz\n(%0.2f b/s, %0.2f b)', ...
                obj.peakFiringRateSmoothed, obj.meanFiringRateSmoothed, obj.informationRateSmoothed, obj.informationPerSpikeSmoothed ))
            axis image off
            colormap jet 
        end

        function plot_information_rate_distribution(obj, faceColour)
            if isempty(faceColour)
                faceColour = 'b';
            end
            
            if isempty(obj.informationRateSim)
                obj.compute_information_rate_pvalue();
            end
            nbins = 50;
            histogram(obj.informationRateSim, nbins, 'normalization', 'pdf', ...
                'faceColor', faceColour);
            title(sprintf('%0.2f b/s\np = %0.4f', obj.informationRate, obj.informationRate_pvalue))
            hold on
            xline(obj.informationRate, 'r', 'linewidth', 8);
            xlabel('b/s');
            grid on
            model_x = linspace(min(obj.informationRateSim), max(obj.informationRateSim), 100);
            model_y = normpdf(model_x, mean(obj.informationRateSim), std(obj.informationRateSim));
            plot(model_x, model_y, 'k-', 'linewidth', 4);
        end 
        
        function plot_information_per_spike_distribution(obj, faceColour)
            if isempty(faceColour)
                faceColour = 'r';
            end
            
            if isempty(obj.informationPerSpikeSim)
                obj.compute_information_rate_pvalue();
            end
            nbins = 50;
            histogram(obj.informationPerSpikeSim, nbins, 'normalization', 'pdf', ...
                'faceColor', faceColour);
            title(sprintf('%0.2f bits\np = %0.4f', obj.informationPerSpike, obj.informationPerSpike_pvalue))
            hold on
            xline(obj.informationPerSpike, 'r', 'linewidth', 8);
            xlabel('bits');
            grid on
            model_x = linspace(min(obj.informationPerSpikeSim), max(obj.informationPerSpikeSim), 100);
            model_y = normpdf(model_x, mean(obj.informationPerSpikeSim), std(obj.informationPerSpikeSim));
            plot(model_x, model_y, 'k-', 'linewidth', 4);
        end 
    end
end

