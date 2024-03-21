function [M] = ml_nlx_convert_header_to_struct(Header)

    H = Header;
    
    % Find the empty cells
    indEmpty = find(cellfun(@isempty, H, 'Uniformoutput', true));


    H(indEmpty) = [];

    % meta info lines containing creation information
    indMeta = find(cellfun(@(x)(~strcmp(x(1), '-')),H));

    H(indMeta) = [];

    % M will be the struct we create.
    M = [];
    for i = 1:length(H)
       x = H{i};
       x = split(x(2:end), ' ');
       vName = x{1};
       vName = strrep(vName, ':','');
       vName = strrep(vName, '_', '');
       vName = strrep(vName, 'µs', 'microseconds');
       vValue = x{2};
       
       % If it should be a number, then convert it.
       vTmp = str2num(vValue);
       if ~isempty(vTmp)
           vValue = vTmp;
       end
       
       % Store
       M.(vName) = vValue;
    end
end % function
