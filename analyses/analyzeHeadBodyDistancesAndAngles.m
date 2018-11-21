% folder: leads to the upper folder of trajectories and video
function analyzeHeadBodyDistancesAndAngles( folder )
% analyzes the head body distances and angles of bees and followers

Params = loadTrajectoryFilesFromFolder(folder, '*.ups');

[Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params);
getMeanDistanceAndAngle_WaggleReturnSeperated(Pr, Pf, W, Params.framerate)

end

