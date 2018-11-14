% Params contains all trajectories 
% id_dancer: id of where in the trajectories the robot lies
% id_flw: id of where the follower lies
function [Pr, Pf, W] = getDancerAndFollowerTrajectorySyncd(Params, id_dancer, id_flw)
% Pr: path (trajectory) of robot: starting at the same time with follower;
% fields are [xpos, ypos, angle] per row
% Pf: same for follower
% W: converted waggle indices -> starting at 1 and synchronized between
% dancer and follower


% check which trajectory starts first 
% it has to be cut to have matching starting times
if Params.T{id_dancer}(1,1) <= Params.T{id_flw}(1,1)  % dancer starts first
    t_start = Params.T{id_flw}(1,1);         % starting time in the other trajectory
    i_start_dancer = find(Params.T{id_dancer}(:,1) == t_start); %starting index for dancer
    i_start_flw = 1;
    
    % space norm in the robot dances is always 5
    % Pr = [ 5*Params.T{id_dancer}(i_start_dancer : end, 2:3)/Params.space_norm Params.T{id_dancer}(i_start_dancer : end, 6) ];
    % Pf = [ 5*Params.Trs{id_flw}(:, 2:3)/Params.space_norm Params.Trs{id_flw}(:, 6) ]; 

    Pr = [ Params.T{id_dancer}(i_start_dancer : end, 2:3) Params.T{id_dancer}(i_start_dancer : end, 6) ];
    Pf = [ Params.Trs{id_flw}(:, 2:3) Params.Trs{id_flw}(:, 6) ]; 

    
    % convert the waggle indices into the synchronised index system
    W = round(Params.I / 10) - (i_start_dancer-1) + 1; 
    
    % all waggles happening before the following behavior starts is discarded
    i_neg = find(W(:,1) < 1);
    W(i_neg, :) = [];    
    fprintf('First %d waggles discarded.\n', length(i_neg))
    
    
else % follower starts first
    t_start = Params.T{id_dancer}(1,1);         
    i_start_flw = find(Params.T{id_flw}(:,1) == t_start); %starting index for follower  
    i_start_dancer = 1;

    % space norm in the robot dances is always 5
    % Pr = [ 5*Params.T{id_dancer}(:, 2:3)/Params.space_norm Params.T{id_dancer}(:, 6) ];
    % Pf = [ 5*Params.Trs{id_flw}(i_start_flw : end, 2:3)/Params.space_norm Params.Trs{id_flw}(i_start_flw : end, 6) ]; 

    Pr = [ Params.T{id_dancer}(:, 2:3) Params.T{id_dancer}(:, 6) ];
    Pf = [ Params.Trs{id_flw}(i_start_flw : end, 2:3) Params.Trs{id_flw}(i_start_flw : end, 6) ]; 

    W = round(Params.I / 10);
end

[len, i_min] = min([length(Pr), length(Pf)]);

fprintf('dancer starts: %d\nfollower starts: %d\nIndex in dancer to match follower: %d\nIndex in follower:%d\n', Params.T{id_dancer}(1,1), Params.T{id_flw}(1,1), i_start_dancer, i_start_flw)



% check which trajectory is shorter
% the longer one must be shortened to match length
if i_min == 1
    Pf(len + 1 : end , :) = [];
else
    Pr(len + 1 : end , :) = [];
end
