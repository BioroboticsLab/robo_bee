% currently the file endings are
% - '*.raw': raw data unprocessed
% - '*.rect': rectified version
% - '*.ups': upsampled by spline interpolation
function displayAllTrajectoriesInFolder(folder, videoPath, fileending)

Params = loadTrajectoryFilesFromFolder(folder, fileending);
Params.videoFilename    = videoPath;
%displayTrajectoryOnVideo(Params)
drawTrajectoriesOnVideo(Params)