function displayAllTrajectoriesInFolder(folder, videoPath)

Params = loadTrajectoryFilesFromFolder(folder);
Params.videoFilename    = videoPath;
%displayTrajectoryOnVideo(Params)
drawTrajectoriesOnVideo(Params)