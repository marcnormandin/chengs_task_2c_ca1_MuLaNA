function ms = men_msGenerateVideoObj(dataFolder, scopeFilenamePrefix, scopeFilenameSuffix, timestampFilenameSuffix, timestampFilename, settingsAndNotesFilename, MAXFRAMESPERFILE)
%MSGENERATEMS Summary of this function goes here
%   Detailed explanation goes here

    ms.dataFolder = dataFolder; % Added by GE to keep track of where the files were initially
    
    %MAXFRAMESPERFILE = 1000; %This is set in the miniscope control software
    
    % find avi and dat files
    aviFiles = dir([dataFolder filesep '*' scopeFilenameSuffix]);
    datFiles = dir([dataFolder filesep '*' timestampFilenameSuffix]);
    
    ms.numFiles = 0;
    ms.numFrames = 0;
    ms.vidNum = [];
    ms.frameNum = [];
    ms.maxFramesPerFile = MAXFRAMESPERFILE;
    
    %find the total number of relevant video files
    for i=1:length(aviFiles)
        endIndex = strfind(aviFiles(i).name,scopeFilenameSuffix);
        if (~isempty(strfind(aviFiles(i).name,scopeFilenamePrefix)))
            ms.numFiles = max([ms.numFiles str2double(aviFiles(i).name((length(scopeFilenamePrefix)+1):endIndex))]);
        end
    end
    
    %generate a vidObj for each video file. Also calculate total frames
    for i=1:ms.numFiles
%         [folder filesep num2str(scopeFilenamePrefix) num2str(i) '.avi']
        ms.vidObj{i} = VideoReader([dataFolder filesep num2str(scopeFilenamePrefix) num2str(i) scopeFilenameSuffix]);
        ms.vidNum = [ms.vidNum i*ones(1,ms.vidObj{i}.NumberOfFrames)];
        ms.frameNum = [ms.frameNum 1:ms.vidObj{i}.NumberOfFrames];
        ms.numFrames = ms.numFrames + ms.vidObj{i}.NumberOfFrames;
    end
    ms.height = ms.vidObj{1}.Height;
    ms.width = ms.vidObj{1}.Width;
    
    %read timestamp information
    for i=1:length(datFiles)
        if strcmp(datFiles(i).name,timestampFilename)
            fileID = fopen([dataFolder filesep datFiles(i).name],'r');
            dataArray = textscan(fileID, '%f%f%f%f%[^\n\r]', 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
            camNum = dataArray{:, 1};
            frameNum = dataArray{:, 2};
            sysClock = dataArray{:, 3};
            buffer1 = dataArray{:, 4};
            clearvars dataArray;
            fclose(fileID);
            cameraMatched = 0;
            for j=0:max(camNum)
%                 (frameNum(find(camNum==j,1,'last')) == ms.numFrames)
%                 (sum(camNum==j) == ms.numFrames)
                if (sum(camNum==j)~=0)
                if ((frameNum(find(camNum==j,1,'last')) == ms.numFrames) && (sum(camNum==j) == ms.numFrames))
                    ms.camNumber = j;
                    ms.time = sysClock(camNum == j);
                    ms.time(1) = 0;
                    ms.maxBufferUsed = max(buffer1(camNum==j));
                    cameraMatched = 1;
                end
                end
            end
            if ~cameraMatched
                display(['Problem matching up timestamps for ' dataFolder]);
            end
        end
         
        %read in and store animal name
        if strcmp(datFiles(i).name, settingsAndNotesFilename)
            fileID = fopen([dataFolder filesep datFiles(i).name],'r');
            textscan(fileID, '%[^\n\r]', 1, 'ReturnOnError', false);
            dataArray = textscan(fileID, '%s%s%s%s%[^\n\r]', 1, 'Delimiter', '\t', 'ReturnOnError', false);
            ms.Experiment = dataArray(:,1);
            ms.Experiment = string(ms.Experiment{1});
        end
    end
    
%     
%     %figure out date and time of recording if that information if available
%     %in folder path
    idx = strfind(dataFolder, '_');
    idx2 = strfind(dataFolder, filesep);
    if (length(idx) >= 4)
        ms.dateNum = datenum(str2double(dataFolder((idx(end-2)+1):(idx2(end)-1))), ... %year
            str2double(dataFolder((idx2(end-1)+1):(idx(end-3)-1))), ... %month
            str2double(dataFolder((idx(end-3)+1):(idx(end-2)-1))), ... %day
            str2double(dataFolder((idx2(end)+2):(idx(end-1)-1))), ...%hour
            str2double(dataFolder((idx(end-1)+2):(idx(end)-1))), ...%minute
            str2double(dataFolder((idx(end)+2):end)));%second
    end
end

