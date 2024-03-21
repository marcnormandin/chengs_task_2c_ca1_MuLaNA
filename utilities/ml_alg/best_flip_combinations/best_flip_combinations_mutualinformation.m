function [bestMap, bestCombination, metricValue] = best_flip_combinations_mutualinformation(maps)
    
    numTrials = size(maps,3);

    flipCombinations = flip_combinations(numTrials);
    numCombinations = size(flipCombinations,1);

    flipMetric = zeros(numCombinations,1);
    flippedMap = zeros(size(maps,1), size(maps,2), numCombinations);

    maps = maps ./ sum(maps, [1,2]); % shouldn't affect the mutual information
    
    for iComb = 1:numCombinations
       comb = flipCombinations(iComb,:);
       mc = maps;
       ind = find(comb == 1);
       for k = 1:length(ind)
           mc(:,:,ind(k)) = rot90(mc(:,:,ind(k)), 2);
       end
       
       
           % Use mutual information as the metric for comparing maps.

           % Prep all of the images
           NUM_BINS = 32; % This is how many bins the map values will be binned into. It is not the map dimensions.
           mcPrep = zeros(size(mc));
           for iTrial = 1:numTrials
               mcPrep(:,:,iTrial) = ml_alg_entropy_prep_image(mc(:,:,iTrial), NUM_BINS);
           end
       
           k = 1;
           mutualInformation = zeros( numTrials*(numTrials-1)/2, 1);
           for iTrialA = 1:numTrials
               for iTrialB = iTrialA+1:numTrials
                   try
                    mutualInformation(k) = ml_alg_mutual_information_images( mcPrep(:,:,iTrialA), mcPrep(:,:,iTrialB) );
                    k = k + 1;
                   catch e

                   end
               end
           end

           flipMetric(iComb) = nanmax(mutualInformation);
           flippedMap(:,:,iComb) = mean(mc, 3, 'omitnan');
    end % iComb

    [metricValue, j] = max(flipMetric); % best is maximum mean mutual information
    bestMap = flippedMap(:,:,j);
    bestCombination = flipCombinations(j,:);
end % function