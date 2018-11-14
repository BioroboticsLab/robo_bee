% Pr: Robot trajectory with indices consistent with follower trajectory
% Pf: Follower trajectory with indices consistent with robot trajectory
% fields are per row [xpos, ypos, angle]
% W: converted waggle indices -> starting at 1 and synchronized between
% dancer and follower
% framerate: as given in the video
function [waggle_distances, waggle_angles, return_distances,return_angles] = getMeanDistanceAndAngle_WaggleReturnSeperated(Pr, Pf, W, framerate)
% waggle_distances: distances between head/body for waggle, but scaled to 40
% waggle_angles: angles between bees for waggle, but scaled to 40
% return_distances: distances between head/body for return run, but scaled to 160
% return_angles: angles between bees for for return run, but scaled to 160

if nargin < 4
    framerate = 100;
end

% get Head Distance to Body Axis
% 5 comes from bee length 14mm; 5mm from middle, there is head/rear
[d R F] = plot_HeadDistance(Pr, Pf, 5);

% Iborders contains the indices in d where follower and dancers are close
% enough to show following behavior
% one 10th of a second (and less) is considered noise
% one second (and shorter) gaps are tolerated
Iborders = FindWhenNearDancer(d, framerate/10, framerate);

% get relative angle between both
a = plot_RelativeAngle(Pr(:,3), Pf(:,3), '');

%resample the function to a certain number of values
resample_waggle = 40;
resample_return = 160;
%will hold data
waggle_distances = [];
waggle_angles = [];
return_distances = [];
return_angles = [];
for i = 2 : length(W)
    
    start_waggle = W(i-1, 1); % start is the beginn of the previous waggle
    stop_waggle  = W(i-1, 2); % and the end of the previous waggle
    start_return = W(i-1, 2)+1; % after the end of waggle, return run starts
    stop_return  = W(i, 1)-1; % return run lasts until next waggle begins
    
    % if waggle starts after data, skip this waggle
    % e.g. if follower stated first
    if ~(stop_return < length(d) & start_waggle < length(d))
        fprintf('Sequence #%d (%d : %d) out of global data bounds. Continuing.\n', i - 1, start_waggle , stop_return)
        continue
    end
    
    % raw head distance data from start of last to start of current waggle
    q_waggle = d(start_waggle : stop_waggle);
    q_return = d(start_return : stop_return);
    
    % both waggle start indices within "good" head distance? 
    Blinks  = start_waggle >= Iborders(:,1);
    Brechts = stop_return  <= Iborders(:,2);
    
    % if no such sequence exists in Iborders, the waggle-return-sequence is
    % skipped and not integrated in C1 / C2
    if sum(Blinks & Brechts) == 0
        fprintf('Sequence #%d (%d : %d) out of local (follower distance) bounds. Continuing.\n', i-1,start_waggle, stop_return)
        continue
    end
    
    
    % resample data
    % scale waggle to 40 
    Q = resample( q_waggle, resample_waggle, length(q_waggle));
    Q = mean(q_waggle)*Q/mean(Q);
    waggle_distances = [waggle_distances; Q];
    
    % angles between flw/robot from start of last to start of current waggle
    q = a(start_waggle : stop_waggle);
    Q = resample( q, resample_waggle, length(q));
    Q = mean(q)*Q/mean(Q);
    waggle_angles = [waggle_angles; Q];
    
    % and scale return run to 160 (sum of both is 200)
    Q = resample( q_return, resample_return, length(q_return));
    Q = mean(q_return)*Q/mean(Q);
    return_distances = [return_distances; Q];
    
    % angles between flw/robot from start of last to start of current waggle
    q = a(start_return : stop_return);
    Q = resample( q, resample_return, length(q));
    Q = mean(q)*Q/mean(Q);
    return_angles = [return_angles; Q];
       
end

fprintf('Total # sequences collected: %d\n', size(C1, 1))

