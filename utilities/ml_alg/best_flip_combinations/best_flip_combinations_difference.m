function [bestMap, bestCombination, metricValue] = best_flip_combinations_difference(maps)
    
    numTrials = size(maps,3);

    flipCombinations = flip_combinations(numTrials);
    numCombinations = size(flipCombinations,1);

    flipMetric = zeros(numCombinations,1);
    flippedMap = zeros(size(maps,1), size(maps,2), numCombinations);

    maps = maps ./ sum(maps, [1,2]);
    
    for iComb = 1:numCombinations
       comb = flipCombinations(iComb,:);
       mc = maps;
       ind = find(comb == 1);
       for k = 1:length(ind)
           mc(:,:,ind(k)) = rot90(mc(:,:,ind(k)), 2);
       end
       
      
       
       k = 1;
       comparisons = zeros( numTrials*(numTrials-1)/2, 1);
       for iTrialA = 1:numTrials
           for iTrialB = iTrialA+1:numTrials
               try
                comparisons(k) = sum(abs( mc(:,:,iTrialA) - mc(:,:,iTrialB) ), 'all');
                k = k + 1;
               catch e

               end
           end
       end

       flipMetric(iComb) = nanmean(comparisons);
       flippedMap(:,:,iComb) = mean(mc, 3, 'omitnan');
    end

    [metricValue, j] = min(flipMetric);
    bestMap = flippedMap(:,:,j);
    bestCombination = flipCombinations(j,:);
end % function