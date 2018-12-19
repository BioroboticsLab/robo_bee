% currently the file endings are
% - '*.raw': raw data unprocessed
% - '*.rect': rectified version
% - '*.ups': upsampled by spline interpolation
function Params = loadTrajectoryFilesFromFolder(folder, fileending)

% default we assume raw files
if nargin < 2
    fileending = '*.raw';
end

% transformation matrix
trans_path = strcat(folder,'\video\Transform.mat');
disp(trans_path);
% for the matrix with the waggle indices
i_path = strcat(folder,'\video\I.mat');
Trans = importdata(trans_path);
Params.Trans = Trans;

% load the matrix that contains the start and stop indices for waggles
I = importdata(i_path);
Params.I = I;

%framerate
Params.framerate = 50; % for all robotic dances, framerate is 50

% tracks
folder = strcat(folder,'\trajectories');
D = dir(fullfile(folder, fileending));

k = 1;
for i = 1:length(D)
    
    % safe at what position the robot is 
    if strncmpi(D(i).name,'followers',9) %followers has 9 letters
         Params.id_flw = i;
    else
        Params.id_dancer = i;
    end
    
    [space_norm, T]          = loadTrack([folder '\' D(i).name]);

    % find the row numbers that have valid data (not NaNs)
    idx_nnan    = find(isnan(T(:,2)) == 0);

    % put these rows in Params.T
    Params.T{k} = T(idx_nnan, :);
    k = k + 1;
    Params.fileending = fileending;
    
    Params.space_norm = space_norm; 
     
%     this is an example of how we saved the I's to the folders
%     I = [   232 250
%             366 386
%             500 520 
%             634 653 
%             769 788 
%             904 922 
%             1037 1056 
%             1171 1190
%             1306 1325
%             1441 1459   ];
% 
%     I = 10*(I - Params.T{1}(1,1));
%     
%     save(i_path, 'I');
end