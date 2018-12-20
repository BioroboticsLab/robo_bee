% folder: leads to the upper folder of trajectories and video
%   e.g. C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\
% isRobotic is 1, if we are working on the robot dance dataset and 0 if we
%   work on the natural dances
function analyzeHeadBodyDistancesAndAngles( folder , isRobotic)
% analyzes the head body distances and angles of bees and followers

% list all subdirectories
D = dir(folder);
% Get a logical vector that tells which is a directory.
dirFlags = [D.isdir];
% Extract only those that are directories.
D = D(dirFlags);

% for each subdirectory (each following behavior), execute the analyses
for i = 1:length(D)
    
    if strcmp(D(i).name, '.') || strcmp(D(i).name, '..') || strcmp(D(i).name(end), '_')
        % the directories '.' and '..' won't be used as well as directories
        % starting with an underscore (they do not have all data necessary)
        
        continue
    end
    
    subfolder = strcat(folder, D(i).name);
    if isRobotic
        Params = loadRobotTrajectoryFilesFromFolder(subfolder);
    else
        Params = loadNaturalTrajectoryFilesFromFolder(subfolder);
    end

    [Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params);
    getMeanDistanceAndAngle_WaggleReturnSeperated(Pr, Pf, W, Params.framerate)
end


end

