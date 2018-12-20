% loads tracks for follower and dancer from one folder
% currently the file endings are
% - '*.raw': raw data unprocessed
% - '*.rect': rectified version
% - '*.ups': upsampled by spline interpolation
function Params = loadNaturalTrajectoryFilesFromFolder(folder, fileending)

% default we assume raw files
if nargin < 2
    fileending = '*.raw';
end

% load waggle index matrix
i_path = strcat(folder,'\video\I.csv');
I = csvread(i_path);
Params.I = I;

% all tracks
folder = strcat(folder,'\trajectories');
D = dir(fullfile(folder, fileending));

% iterate over track
for i = 1:length(D)
    
    % safe at what index the robot is 
    if strncmpi(D(i).name,'followers',9) %followers has 9 letters
        Params.id_flw = i;
    else
        Params.id_dancer = i;
    end
    
    % load the track and its header line
    [header, T]          = loadTrack([folder '\' D(i).name]);
    
    Params.T{i} = T; 
    
    % extract space_norm from header -- needed for rescaling
    indices = strfind(header,'space_norm'); % indeces of where space norm start
    if isempty(indices)
        space_norm = 39; %default value
    else
        k1 = k(indices);
        kvalue = k1 +11; % index of where the value for space_norm starts
        space_norm = header(kvalue : kvalue +1); % two numbers for the space_norm    
    end
    Params.space_norm = space_norm; 
    
    % natural dances do not need rectification, only rescaling
    % they also have data at each point, thus the scaled version is also
    % already the upsampled one
    Params.Tr{i} = rescaleNaturalDance(Params, i);
    Params.Ts{i} = Params.Tr{i};
    
    % save the header line from that file
    Params.headers{i} = header;
    % the file name stripped off from the file extension
    % needed when saving a rescaled/interpolated version of it
    Params.filenames{i} = strtok(D(i).name,'.');

end
  
    % save the data type
    Params.fileending = fileending;
    %framerate
    Params.framerate = 100; % for all natural dances, framerate is 100
     

   
end
