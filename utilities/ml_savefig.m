function ml_savefig(hFig, outputFolder, fnPrefix, formats)
    for iFormat = 1:length(formats)
       format = formats{iFormat};
       fn = [];
       if ismember(format, {'png', 'pdf', 'svg'})
           fn = fullfile(outputFolder, sprintf('%s.%s', fnPrefix, format));
           saveas(hFig, fn);
       elseif strcmp(format, 'fig')
           fn = fullfile(outputFolder, sprintf('%s.fig', fnPrefix));
           savefig(hFig, fn);
       else
           warning('Can not save figure with the format %s.\n', format);
       end
       
       if ~isempty(fn)
           fprintf('Figure saved: %s\n', fn);
       end
    end
end