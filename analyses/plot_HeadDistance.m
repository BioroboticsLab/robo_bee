% Pr: Robot trajectory with indices consistent with follower trajectory
% Pf: Follower trajectory with indices consistent with robot trajectory
% l: length from middle point of a bee to head/tail
% for our images bees are 14mm long, such that l can be chosen 5mm 
% (7 would point to the absolute end/begin of the bee)
function [D R F] = plot_HeadDistance(Pr, Pf, l)
% R : [VecX VecY X Y] direction from the hind quarters of the bee to the head 
% and point of robot hind quarters
% F : [X Y] head point of the follower
% D: distance from head of follower to body of bee


% robot body line
sinR = l * sin(Pr(:,3));
cosR = l * cos(Pr(:,3));
% point on the (hind quarters) bottom of the robot
Xr = Pr(:, 1) - cosR;
Yr = Pr(:, 2) - sinR;

% follower head point
sinF = 1.4*l * sin(Pf(:,3));
cosF = 1.4*l * cos(Pf(:,3));
% point at the extreme front of the bee (1.4*5 = 7, which is half the
% length of a bee
Xf = Pf(:, 1) + cosF;
Yf = Pf(:, 2) + sinF;

% R : direction from the hind quarters of the bee to the head and point of
% robot hind quarters
R = [2*cosR 2*sinR Xr Yr];
% F : head point of the follower
F = [Xf Yf];

% D: distance from head of follower to body of bee
D = [];
for i = 1:length(Pr)
    [d, a, d2] = point_line_dist(R(i, :), F(i, :));
    D = [D d2];
end

