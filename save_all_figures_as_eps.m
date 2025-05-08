function save_all_figures_as_eps(filenames)
% Save all open figures as .eps files using specified filenames
% Saving is done in creation order
% Input: filenames - a cell array of strings (e.g., {'fig1', 'fig2', ...})

    filenames = cellstr(filenames);
    filenames = regexprep(filenames, '[^\w]', '_');  % replace non-word chars with _
    figs = findall(0, 'Type', 'figure');
    [~, idx] = sort([figs.Number]);
    figs = figs(idx);  % ordered by figure number

    nFigs = length(figs);
    
    if length(filenames) < nFigs
        error('Not enough filenames for the number of open figures.');
    end
    output_folder = 'figures';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    for k = 1:nFigs
        filenames{k} = fullfile(output_folder, filenames{k});
    end
    

    for k = 1:nFigs
        figure(figs(k));
        print(filenames{k}, '-depsc');
        fprintf('Saved figure %d as %s.eps\n', k, filenames{k});
    end
end
