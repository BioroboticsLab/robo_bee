% splineInterpolation works ONLY on rectified tracks
% filename: string -- the name of the output file eg. 'follower'
function spTrack = splineInterpolateTrack(trackFolder, filename)

    % load the rectified to be spline interpolated
    trackPath = strcat(trackFolder, '\trajectories\', filename, '.rect'); 

    [~, T] = loadTrack(trackPath);
    
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
    % 0.5 steps to upsample from 50 to 100 Hz (only robot)
    ts      = (T(1,1) : .5 :  T(end,1))'; 

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
    
    % write the upsampled data
    writePath = strcat(trackFolder, '\trajectories\', filename, '.ups');

    saveTrack(spTrack.', writePath);
    
end