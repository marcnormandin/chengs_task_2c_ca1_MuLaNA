function [averageMap, rotSeqRec, rotSeqVal] = ml_compute_best_map_rot_sequence_and_average(pmSet)
    nMaps = size(pmSet,3);
    
    if nMaps == 0
        averageMap = [];
        rotSeqRec = [];
        rotSeqVal = nan;
        return
    end

    R = nan(nMaps, nMaps);
    rho = nan(nMaps, nMaps);
    for iMap1 = 1:nMaps
        for iMap2 = 1:nMaps
            m1 = pmSet(:,:,iMap1);
            m2 = pmSet(:,:,iMap2);
            m2Rot = rot90(m2,2);

            p0 = corr(m1(:), m2(:));
            p180 = corr(m1(:), m2Rot(:));

            if p180 > p0
                R(iMap1, iMap2) = 1;
                rho(iMap1, iMap2) = p180;
            else
                R(iMap1, iMap2) = 0;
                rho(iMap1, iMap2) = p0;
            end
        end
    end

    total = zeros(1, nMaps);
    for i = 1:nMaps
       for j = 1:nMaps
          total(i) = total(i) + rho(j); 
       end
    end
    avgCorr = total ./ nMaps;
    
    [rotSeqVal, maxInd] = max(avgCorr);

    rotSeqRec = R(maxInd,:);
    if rotSeqRec(1) ~= 0
        rotSeqRec = ~rotSeqRec;
    end
    
    % Compute the average map
    averageMap = zeros(size(pmSet,1), size(pmSet,2));
    for iMap = 1:nMaps
        m = pmSet(:,:,iMap);
        m(isnan(m)) = 0;
        if rotSeqRec(iMap) == 1
            m = rot90(m,2);
        end
        averageMap = averageMap + m;
    end
    averageMap = averageMap / nMaps;
    averageMap(~isfinite(averageMap)) = 0;
end % function