% folder: leads to the upper folder of trajectories and video
% e.g. C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\
function analyzeMotionDynamics( folder )
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
    Params = loadRobotTrajectoryFilesFromFolder(subfolder);
    
    [Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params);

    % only get the follower
    %T = Params.T{Params.id_flw};
    %[dx, dy] = getForwardAndSidewardVelocities(T);
    
    %waggle foreward velocity (wfv), w sideward velocity (swv), w angle (wan)
    % return fv (rfv), (rsv), (ran)
    [wfv, wsv, wan, rfv, rsv, ran] = getMeanVelocitiesAndAngles_Seperated(Pr, Pf, W, Params.framerate);


    %write it out
    wfv_name = strcat(subfolder,'_wfv.csv');
    wsv_name = strcat(subfolder,'_wsv.csv');
    wan_name = strcat(subfolder,'_wan.csv');
    rfv_name = strcat(subfolder,'_rfv.csv');
    rsv_name = strcat(subfolder,'_rsv.csv');
    ran_name = strcat(subfolder,'_ran.csv');

    csvwrite(wfv_name,wfv);
    csvwrite(wsv_name,wsv);
    csvwrite(wan_name,wan);
    csvwrite(rfv_name,rfv);
    csvwrite(rsv_name,rsv);
    csvwrite(ran_name,ran);
end
end

