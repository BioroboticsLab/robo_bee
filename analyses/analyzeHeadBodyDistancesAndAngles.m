% folder: leads to the upper folder of trajectories and video
%   e.g. C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\
% isRobotic (bool) is 1, if we are working on the robot dance dataset and 0 if we
%   work on the natural dances
% writeFiles (bool) 1: write the data to files (for plotting with python)
function analyzeHeadBodyDistancesAndAngles( folder , isRobotic, writeFiles)
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
        % ending with an underscore (they do not have all data necessary)
        
        continue
    end
    
    subfolder = strcat(folder, D(i).name);
    if isRobotic
        Params = loadRobotTrajectoryFilesFromFolder(subfolder);
    else
        Params = loadNaturalTrajectoryFilesFromFolder(subfolder);
    end

    [Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params);
    [wd, wa, rd, ra] = getMeanDistanceAndAngle_WaggleReturnSeperated(Pr, Pf, W, Params.framerate);
    


    %write it out to a subfolder in your folder 
    % underscode needed in the load trajectory function (it ignores folders
    % with underscore)
    sf = 'hbd_and_angles_\';
    
    if writeFiles
        wd_name = strcat(folder,sf, D(i).name,'_wd.csv');
        wa_name = strcat(folder,sf, D(i).name,'_wa.csv');
        rd_name = strcat(folder,sf, D(i).name,'_rd.csv');
        ra_name = strcat(folder,sf, D(i).name,'_ra.csv');
        
        csvwrite(wd_name,wd);
        csvwrite(wa_name,wa);
        csvwrite(rd_name,rd);
        csvwrite(ra_name,ra);
    end


end


end

