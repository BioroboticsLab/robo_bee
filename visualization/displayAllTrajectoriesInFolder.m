% currently the file endings are
% - '*.raw': raw data unprocessed
% - '*.rect': rectified version
% - '*.ups': upsampled by spline interpolation
% folder leads to the upper folder of trajectories and video
% eg.
% C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\2011-09-03_16-39-39
function displayAllTrajectoriesInFolder(folder, videoPath, fileending)

Params = loadTrajectoryFilesFromFolder(folder, fileending);
Params.videoFilename    = videoPath;
%displayTrajectoryOnVideo(Params)
drawTrajectoriesOnVideo(Params)