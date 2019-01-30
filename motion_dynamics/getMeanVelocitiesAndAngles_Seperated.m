% Pr: Robot trajectory with indices consistent with follower trajectory
% Pf: Follower trajectory with indices consistent with robot trajectory
% fields are per row [xpos, ypos, angle]
% W: converted waggle indices -> starting at 1 and synchronized between
% dancer and follower
% framerate: as given in the video
% this function consideres the waggle and the return run seperately
function [waggle_fv, waggle_sv,waggle_ang,return_fv,return_sv,return_ang] = getMeanVelocitiesAndAngles_Seperated(Pr, Pf, W, framerate)
% waggle_distances: distances between head/body for waggle, but scaled to 40
% waggle_angles: angles between bees for waggle, but scaled to 40
% return_distances: distances between head/body for return run, but scaled to 160
% return_angles: angles between bees for for return run, but scaled to 160

if nargin < 4
    framerate = 100;
end

dx = diff(Pf(:,1)); % x positions
dy = diff(Pf(:,2)); % y positions
da = angDiff(Pf(1:end-1, 3), Pf(2:end, 3)); % angle Differences
vx = cos(Pf(:,3));
vy = sin(Pf(:,3));
[v_forw, v_side] = getForwardAndSidewardVelocities(Pf); 




%resample the function to a certain number of values
% analyze a whole period consisting of 2 waggeles and 2 returns
resample_waggle1 = 40;
resample_return1 = 160;
%resample_waggle2 = resample_waggle1;
%resample_return2 = resample_return1;

%will hold data
waggle_fv = [];
waggle_sv = [];
waggle_ang = [];
return_fv = [];
return_sv = [];
return_ang = [];



for i = 2 : size(W,1)-1
    
    start_waggle = W(i-1, 1); % start is the beginn of the previous waggle
    stop_waggle  = W(i-1, 2); % and the end of the previous waggle
    start_return = W(i-1, 2)+1; % after the end of waggle, return run starts
    stop_return  = W(i, 1)-1; % return run lasts until next waggle begins
    
   
    % so sah es im alten code aus. aber wird da nicht i zwei mal verwendet?
    % müsste man nicht eigentlich in 2-er schritten hochzählen?
    % und manche I matrizen (z.B. erste haben ungerade Anzahl Elemente?
    %for i = 2 : size(W,1)-1
    %   start   = W(i-1, 1);
    %   stop    = W(i+1, 1) - 1;
    
    % if waggle starts after data, skip this waggle
    if ~(stop_return < length(dx))
        fprintf('Sequence #%d (%d : %d) out of global data bounds. Continuing.\n', i - 1, W(i-1, 1), W(i+1, 1))
        continue
    end
    
    % do not use them double --> do not start with left
    disp(W(i-1, 2));
    disp(W(i-1, 2)+ 250);
    if sum(da(W(i-1, 2) : W(i-1, 2) + 250)) < 0
        fprintf('left turn? %d\n', i)
        continue
    end
    
    % forward velocities
    q       = v_forw( start_waggle : stop_waggle );
    Q       = resampleZeroPaddingResistant(q, resample_waggle1);
    waggle_fv  = [waggle_fv; Q'];
    
    q       = v_forw( start_return : stop_return );
    Q       = resampleZeroPaddingResistant(q, resample_return1);
    return_fv  = [return_fv; Q'];
    
    % sideward velocities 
    q       = v_side( start_waggle : stop_waggle );
    Q       = resampleZeroPaddingResistant(q, resample_waggle1);
    waggle_sv  = [waggle_sv; Q'];
    
    q       = v_side( start_return : stop_return );
    Q       = resampleZeroPaddingResistant(q, resample_return1);
    return_sv  = [return_sv; Q'];
    
    % angles
    q       = da( start_waggle : stop_waggle );
    Q       = resampleZeroPaddingResistant(q, resample_waggle1);
    waggle_ang  = [waggle_ang; Q'];
    
    q       = da( start_return : stop_return );
    Q       = resampleZeroPaddingResistant(q, resample_return1);
    return_ang  = [return_ang; Q'];
    
    
%     q   = dx( start : stop );
%     Q   = resample_around_mean(q, resample_size);
%     DX  = [DX; Q'];
%     
%     q   = dy( start : stop );
%     Q   = resample_around_mean(q, resample_size);
%     DY  = [DY; Q'];
%         
%     q   = vx( start : stop);
%     Q   = resample_around_mean(q, resample_size);
%     DVX = [DVX; Q'];
%     
%     q   = vy( start : stop);
%     Q   = resample_around_mean(q, resample_size);
%     DVY = [DVY; Q'];
    
end
