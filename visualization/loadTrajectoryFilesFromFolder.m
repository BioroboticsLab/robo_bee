function Params = loadTrajectoryFilesFromFolder(folder)


D = dir(fullfile(folder, '*.raw'));

k = 1;
for i = 1:length(D)
    
    T          = loadTrack([folder '\' D(i).name]);

    % find the row numbers that have valid data (not NaNs)
    idx_nnan    = find(isnan(T(:,2)) == 0);

    % put these rows in Params.T
    Params.T{k} = T(idx_nnan, :);
    k = k + 1;
    
end