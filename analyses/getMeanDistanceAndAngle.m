% Pr: Robot trajectory with indices consistent with follower trajectory
% Pf: Follower trajectory with indices consistent with robot trajectory
% fields are per row [xpos, ypos, angle]
% W: converted waggle indices -> starting at 1 and synchronized between
% dancer and follower
% framerate: as given in the video
function [C1, C2] = getMeanDistanceAndAngle(Pr, Pf, W, framerate)
% C1: distances between head/body, but scaled to 200
% C2: angles between bees, but scaled to 200

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
resample_size = 200;
%will hold data
C1 = [];
C2 = [];
for i = 2 : length(W)
    
    start   = W(i-1, 1);
    stop    = W(i, 1);
    
    % if waggle starts after data, skip this waggle
    % e.g. if follower stated first
    if ~(stop < length(d) & start < length(d))
        fprintf('Sequence #%d (%d : %d) out of global data bounds. Continuing.\n', i - 1, start , stop)
        continue
    end
    
    % raw head distance data from start of last to start of current waggle
    q = d(start : stop);
    
    % both waggle start indices within "good" head distance? 
    Blinks  = start >= Iborders(:,1);
    Brechts = stop  <= Iborders(:,2);
    
    % if no such sequence exists in Iborders, the waggle-return-sequence is
    % skipped and not integrated in C1 / C2
    if sum(Blinks & Brechts) == 0
        fprintf('Sequence #%d (%d : %d) out of local (follower distance) bounds. Continuing.\n', i-1,start, stop)
        continue
    end
    
    
    % resample data
    % scale to 200
    Q = resample( q, resample_size, length(q));
    Q = mean(q)*Q/mean(Q);
    C1 = [C1; Q];
    
    % now q is angles between flw/robot from start of last to start of current waggle
    q = a(start : stop);
    Q = resample( q, resample_size, length(q));
    Q = mean(q)*Q/mean(Q);
    C2 = [C2; Q];
    
    
end

fprintf('Total # sequences collected: %d\n', size(C1, 1))

