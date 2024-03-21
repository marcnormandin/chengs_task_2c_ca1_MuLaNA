function [bestMap, bestCombination, metricValue] = best_flip_combinations(maps, comparisonMethod)
    comparisonMethod = lower(comparisonMethod);

    if strcmpi(comparisonMethod, 'mutualInformation')
        [bestMap, bestCombination, metricValue] = best_flip_combinations_mutualinformation(maps);
    elseif strcmpi(comparisonMethod, 'difference')
        [bestMap, bestCombination, metricValue] = best_flip_combinations_difference(maps);
    elseif strcmpi(comparisonMethod, 'standardDeviation')
        [bestMap, bestCombination, metricValue] = best_flip_combinations_standarddeviation(maps);
    elseif strcmpi(comparisonMethod, 'correlation')
        [bestMap, bestCombination, metricValue] = best_flip_combinations_correlation(maps);
    else
        error('Invalid comparison method.');
    end
end % function