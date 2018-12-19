% this function gets a path to a track and loads it in matrix form
function [header, T] = loadTrack(trackPath)
    % load track from file
    fid     = fopen(trackPath, 'r');
    
    % extract information from the header and then do not use it for fscanf
    header = fgetl(fid);  % first line header line    
    R       = fscanf(fid, '%d %f %f %f %f %f');
    T       = reshape(R, 6, length(R)/6)';
    fclose(fid);
end