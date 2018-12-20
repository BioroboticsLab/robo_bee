% loads tracks for follower and dancer from one folder
% currently the file endings are
% - '*.raw': raw data unprocessed
% - '*.rect': rectified version
% - '*.ups': upsampled and spline interpolation
function Params = loadRobotTrajectoryFilesFromFolder(folder)

% we load the raw files, variable used to load the trajectories
fileending = '*.raw';

% load transformation matrix
trans_path = strcat(folder,'\video\Transform.mat');
Trans = importdata(trans_path);
Params.Trans = Trans;

% load H homography
hPath = strcat(folder, '\video\H.mat');
H = importdata(hPath);
Params.H = H;

% load waggle index matrix
i_path = strcat(folder,'\video\I.mat');
I = importdata(i_path);
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
    
    % find the row numbers that have valid data (not NaNs)
    % put these rows in Params.T
    idx_nnan    = find(isnan(T(:,2)) == 0);
    Params.T{i} = T(idx_nnan, :); 
    
    % also calculate the rectified und spline interpolated track
    Params.Tr{i} = rectifyTrack(Params, i);
    Params.Ts{i} = splineInterpolateTrack(Params, i);
    
    % save the header line from that file
    Params.headers{i} = header;
    % the file name stripped off from the file extension
    % needed when saving a rescaled/interpolated version of it
    Params.filenames{i} = strtok(D(i).name,'.');

end
  
    % save the data type
    Params.fileending = fileending;
    %framerate
    Params.framerate = 50; % for all robotic dances, framerate is 50
     
    % robotic dances do have space norm 5
    % HACK: 5 / 5 is 1--> for robotic dances (and s_n is (5cm / s_n pixel))
    % this is not specified in the file header
    Params.space_norm = 5; 
   
end
