function [analytic_t_mus, analytic_y] = ml_alg_bandpassed_analytic_signal(t_mus, y, bandpass_freqs)
    % Resample to have equal sampling intervals
    dt_mus = median(diff(t_mus));
    interp_slice_t_mus = t_mus(1):dt_mus:t_mus(end);
    interp_slice_csc = interp1(t_mus, y, interp_slice_t_mus);
    
    % New sampling rate in Hz
    fs = 1 / (dt_mus/10^6);
    
    % Low-pass filter before downsampling (up to 600 Hz)
    y = lowpass(interp_slice_csc, 600, fs,'Steepness', 0.95);
    M = ceil(fs/220); % 220 is desired sampling frequency
    y = downsample(y, M);
    fs = fs / M; % the new sampling rate
    
    % Band-pass filter
    if bandpass_freqs(1)-1 <= 0.25
        bandpass_freqs(1) = 0.25+1;
        %bandpass_freqs(2) = bandpass_freqs(1)+1;
    end

    bandpass_crit_freqs = [(bandpass_freqs(1)-1), bandpass_freqs(1), bandpass_freqs(2), (bandpass_freqs(2)+1)];    % Cutoff frequencies
    a = [0 1 0];        % Desired amplitudes    
    dev = [0.01 0.05 0.01];
    [n, fo, ao, w] = firpmord(bandpass_crit_freqs, a, dev, fs);
    b = firpm(n, fo, ao, w);
    y = filter(b,1,y);

    % analytic signal
    analytic_y = hilbert(y);
    N = length(analytic_y);
    analytic_t_mus = (0:(N-1))/fs*10^6 + t_mus(1); % start at the same time origin
end