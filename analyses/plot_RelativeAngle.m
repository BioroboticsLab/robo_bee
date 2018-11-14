% Ar: Robot angles with indices consistent with follower trajectory
% Af: Follower angles with indices consistent with robot trajectory
% s: plot option string
function [d] = plot_RelativeAngle(Ar, Af, s)
% d: array of angle distances between robot and follower

% vectors for robot and follower
vR = [ sin(Ar) cos(Ar) ]';
vF = [ sin(Af) cos(Af) ]';

d = dot(vR, vF);
% plot(4*dot(vR, vF), s)