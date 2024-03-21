function samples = ml_stats_gen_uniform_samples(nSamples, xMin, xMax)
    samples = xMin + (xMax - xMin) * rand(1,nSamples);
end
