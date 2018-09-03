% splineInterpolation works ONLY on rectified tracks
% robot: bool -- want to track the robot (TRUE) or the follower (FALSE)
% write: bool -- want to write the result to the folder
function spTrack = splineInterpolateTrack(trackFolder, robot, write)

    % get the rectified track for the given trackFolder
    if robot
        trackPath = strcat(trackFolder, '\trajectories\robot.rect'); 
    else
        trackPath = strcat(trackFolder, '\trajectories\followers.rect');
    end
    
    T = loadTrack(trackPath);
    
    % do the spline interpolation
    n       = length(T);
    t       = T(:,1); %time in frames
    x       = T(:,2);
    y       = T(:,3);
    a       = T(:,6);
    sina    = sin(a);
    cosa    = cos(a);

    % integer steps from first to last position (original data typically has
    % gaps pf ~ 10 frames)
    ts      = (T(1,1) : T(end,1))'; 

    csx     = csaps(t, x);
    csy     = csaps(t, y);
    cs_sina = csaps(t, sina);
    cs_cosa = csaps(t, cosa);

    xs      = fnval(csx, ts);
    ys      = fnval(csy, ts);
    sinas   = fnval(cs_sina, ts);
    cosas   = fnval(cs_cosa, ts);
    as      = atan2(sinas,cosas);

    mw      = repmat(nanmean(T(:,4)), length(ts), 1); %mean width in metric units
    mh      = repmat(nanmean(T(:,5)), length(ts), 1); %mean height

    spTrack = [ts xs ys mw mh as];
    
    if write
        if robot
            writePath = strcat(trackFolder, '\trajectories\robot.ups');
        else
            writePath = strcat(trackFolder, '\trajectories\followers.ups');
        end
        fileID = fopen(writePath,'w');
        % save the transposed version to have the correct format in the
        % file
        fprintf(fileID,'%d %5f %5f %5f %5f %5f\r\n',spTrack.');
        fclose(fileID);
    end

end