function [ data ] = ml_cai_behavtrackvid_h5_read_all( filename )
% Reads a 'behav_track_vid.hdf5' file specified by the filename given in filename
info = h5info(filename);

h5Fields = {info.Datasets.Name};
matFields = h5Fields;
numFields = length(h5Fields);
data = [];
for iF = 1:numFields
    fieldName = sprintf('/%s', h5Fields{iF});
    data.(matFields{iF}) = h5read( filename, fieldName );
end

% attributes
attribNames = {info.Attributes.Name};
for iF = 1:length(attribNames)
    aName = attribNames{iF};
    data.(aName) = h5readatt(filename, '/', aName);
end

end % function
