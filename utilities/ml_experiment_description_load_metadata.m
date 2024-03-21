function [data] = ml_experiment_description_load_metadata(experimentDescriptionFilename)

    [filePath, fileName, fileExtension] = fileparts( experimentDescriptionFilename );
    if ~strcmp(fileExtension, '.json')
        error('Invalid extension for %s.', experimentDescriptionFilename);
    end



    data.edFolder = filePath;
    data.edFilename = experimentDescriptionFilename;
    data.experimentDescription = ml_util_json_read(data.edFilename);
    data.recordingsParentFolder = filePath;
    
    sessionNames = data.experimentDescription.session_folders;
    nSessions = length(sessionNames);
    for iSession = 1:nSessions
        sessionName = sessionNames{iSession};
        srFilename = fullfile(data.recordingsParentFolder, sessionName, 'session_record.json');
        data.meta.sessionRecords.(sessionName) = MLSessionRecord( srFilename );
    end
end % function