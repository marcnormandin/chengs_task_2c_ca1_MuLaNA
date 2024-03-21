function [y] = ml_alg_movmean(x, windowSize)
    % https://www.mathworks.com/help/matlab/ref/filter.html?s_tid=doc_ta#bt_vs4t-2_1
    a = 1;
    b = (1/windowSize)*ones(1,windowSize);
    x = reshape(x, 1, length(x));
    y = filter(b,a,x);

end % function