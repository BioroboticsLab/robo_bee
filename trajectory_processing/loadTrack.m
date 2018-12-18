% this function gets a path to a track and loads it in matrix form
function [space_norm, T] = loadTrack(trackPath)
    % load track from file
    fid     = fopen(trackPath, 'r');
    
    % extract information from the header and then do not use it for fscanf
    header = fgetl(fid);  % first line header line
    
    % robotic dances do have space norm 5
    % HACK: 5 / 5 is 1 --> for robotic dances
    % this is not specified in the file header
    k = strfind(header,'space_norm'); % indeces of where space norm start
    disp(k);
    if isempty(k)
        space_norm = 5;
    else
        k1 = k(1);
        disp(k1);
        kvalue = k1 +11; % index of there the value for space_norm starts
        space_norm = header(kvalue : kvalue +1); % two number digit for the sn    
    end
    
    
    R       = fscanf(fid, '%d %f %f %f %f %f');
    T       = reshape(R, 6, length(R)/6)';
    fclose(fid);
end