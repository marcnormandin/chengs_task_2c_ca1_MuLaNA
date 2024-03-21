function [xs] = ml_alg_circ_movmean(x, M)
    if mod(M,2) ~= 1
        error('Windows size needs to be odd-valued');
    end
    
    MH = (M-1)/2;
    y = [x(end-MH+1:end), x, x(1:MH)];
    
    % Older versions of MATLAB do not have "movmean"
    z = movmean(y, [MH, MH]);
    
    xs = z(MH+1:end-(MH));
end
