function [bestMap, bestCombination, metricValue] = best_flip_combinations_correlation(maps)
    
    numTrials = size(maps,3);

    flipCombinations = flip_combinations(numTrials);
    numCombinations = size(flipCombinations,1);

    flipMetric = nan(numCombinations,1);
    flippedMap = nan(size(maps,1), size(maps,2), numCombinations);

    maps = maps ./ sum(maps, [1,2]);
    
    for iComb = 1:numCombinations
       comb = flipCombinations(iComb,:);
       mc = maps;
       ind = find(comb == 1);
       for k = 1:length(ind)
           mc(:,:,ind(k)) = rot90(mc(:,:,ind(k)), 2);
       end
       
       

        k = 1;
        comparison = zeros( numTrials*(numTrials-1)/2, 1);
        for iTrialA = 1:numTrials
           for iTrialB = iTrialA+1:numTrials
               try
                mapA = mc(:,:,iTrialA);
                mapB = mc(:,:,iTrialB);
                comparison(k) = corr(mapA(:), mapB(:));
                k = k + 1;
               catch e

               end
           end
        end

        flipMetric(iComb) = nanmean(comparison);
%        flipMetric(iComb) = nansum(comparison);
        flippedMap(:,:,iComb) = mean(mc, 3, 'omitnan');
       
    end

    [metricValue, j] = max(flipMetric);
    bestMap = flippedMap(:,:,j);
    bestCombination = flipCombinations(j,:);
end % function