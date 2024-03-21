function [tr] = ml_cai_trialresult_read( trialResultsFolder )

    tr = {};
    tr.trialResultsFolder = trialResultsFolder;

    tr.neuronFilename = fullfile(trialResultsFolder, 'neuron.hdf5');
    tr.scopeFilename = fullfile(trialResultsFolder, 'scope.hdf5');
    tr.behavFilename = fullfile(trialResultsFolder, 'behav.hdf5');
    tr.behavTrackVidFilename = fullfile(trialResultsFolder, 'behav_track_vid.hdf5');

    try
        tr.behavTrackVid = ml_cai_behavtrackvid_h5_read( tr.behavTrackVidFilename );
    catch e
        tr.behavTrackVid = [];
    end

    try
        tr.neuronData = ml_cai_neuron_h5_read( tr.neuronFilename );
    catch e
        tr.neuronData = [];
    end

    try
        tr.scopeVideoData = ml_cai_scope_h5_read( tr.scopeFilename );
    catch e
        tr.scopeVideoData = [];
    end

    try
        tr.behavVideoData = ml_cai_behav_h5_read( tr.behavFilename );
    catch e
        tr.behavVideoData = [];
    end

    % check for integrity
    if ~isempty(tr.neuronData)
        numTimesamples = tr.neuronData.num_time_samples;
        if tr.scopeVideoData.num_frames ~= numTimesamples
            error('Number of scope time samples (%d) does not match neuron samples (%d)', tr.scopeVideoData.num_frames, numTimeSamples);
        end
    end

    mfn = fullfile(trialResultsFolder, 'movement.mat');
    if isfile( mfn )
       tmp = load( mfn );
       tr.movement = tmp.movement;   
    end
    
    % Compute the calcium events for each neuron
    %for iN = 1:tr.neuronData.num_neurons
    %   tr.neuronData.neuron{iN}.calciumEvents = ml_cai_neuron_calcium_events(tr.neuronData.neuron{iN}, tr.scopeVideoData.timestamp_ms);
    %end
end % function
