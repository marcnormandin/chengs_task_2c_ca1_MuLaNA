function [flipCombinations] = flip_combinations(numTrials)
    % Returns a matrix of unique combinations of 0s and 1s. Each row
    % is one combination.
    flipCombinations = zeros(1,numTrials);

    for i = 1:numTrials %6
        s = zeros(numTrials,1);
        s(1:i) = 1;
        p = unique(perms(s), 'rows');

        flipCombinations = cat(1, flipCombinations, p);
    end

    flipCombinations = unique(flipCombinations, 'rows'); % precaution
end % function