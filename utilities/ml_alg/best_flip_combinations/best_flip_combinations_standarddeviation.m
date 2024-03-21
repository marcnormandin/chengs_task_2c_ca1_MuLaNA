function [bestMap, bestCombination, metricValue] = best_flip_combinations_standarddeviation(maps)
    
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

        flipMetric(iComb) = sum(std(mc, 0, 3, 'omitnan'), 'all', 'omitnan');
        flippedMap(:,:,iComb) = mean(mc, 3, 'omitnan');
    end % iComb

    [metricValue, j] = min(flipMetric);
    bestMap = flippedMap(:,:,j);
    bestCombination = flipCombinations(j,:);
end % function