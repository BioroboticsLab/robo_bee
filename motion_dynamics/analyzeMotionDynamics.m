% folder: leads to the upper folder of trajectories and video
% e.g. C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\
% isRobotic (bool) is 1, if we are working on the robot dance dataset and 0 if we
%   work on the natural dances
% writeFiles (bool) 1: write the data to files (for plotting with python)
function analyzeMotionDynamics( folder, isRobotic, writeFiles)
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

    %waggle foreward velocity (wfv), w sideward velocity (swv), w angle (wan)
    % return fv (rfv), (rsv), (ran)
    [wfv, wsv, wan, rfv, rsv, ran] = getMeanVelocitiesAndAngles_Seperated(Pr, Pf, W, Params.framerate);


    %write it out to a subfolder in your folder 
    % underscode needed in the load trajectory function (it ignores folders
    % with underscore)
    sf = 'motion_dynamics_\';
    
    if writeFiles
        
        wfv_name = strcat(folder,sf, D(i).name,'_wfv.csv');
        wsv_name = strcat(folder,sf, D(i).name,'_wsv.csv');
        wan_name = strcat(folder,sf, D(i).name,'_wan.csv');
        rfv_name = strcat(folder,sf, D(i).name,'_rfv.csv');
        rsv_name = strcat(folder,sf, D(i).name,'_rsv.csv');
        ran_name = strcat(folder,sf, D(i).name,'_ran.csv');
        

        csvwrite(wfv_name,wfv);
        csvwrite(wsv_name,wsv);
        csvwrite(wan_name,wan);
        csvwrite(rfv_name,rfv);
        csvwrite(rsv_name,rsv);
        csvwrite(ran_name,ran);
    end 
    
end
end

