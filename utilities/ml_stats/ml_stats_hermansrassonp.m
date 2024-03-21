% Calculate the critical value and p-value
function [HRT, HRTpvalue] = ml_stats_hermansrassonp(sample)
    n = length(sample);
    m = 1000;
    rt = nan(1,m);
    for i = 1:m
        rsample = ml_stats_gen_uniform_samples(n, 0, 2*pi);
        rt(i) = HermansRassonT(rsample); % from random samples
    end
    HRT = HermansRassonT(sample); % from the true samples
    HRTpvalue = sum((rt < HRT)/m);
end

% Calculate the critical value
function total = HermansRassonT(sample)
    n = length(sample);
    total = 0;
    for i = 1:n
        for j = 1:n
            total = total + pi - abs(pi - abs(sample(i) - sample(j)));
            total =  total + (2.895*abs(sin(sample(i) - sample(j))));
        end
    end
    total = total / n;
end
