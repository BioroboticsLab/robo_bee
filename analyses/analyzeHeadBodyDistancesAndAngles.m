% folder: leads to the upper folder of trajectories and video
% e.g. C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\
function analyzeHeadBodyDistancesAndAngles( folder )
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
    Params = loadTrajectoryFilesFromFolder(subfolder, '*.ups');

    [Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params);
    getMeanDistanceAndAngle_WaggleReturnSeperated(Pr, Pf, W, Params.framerate)
end


end
