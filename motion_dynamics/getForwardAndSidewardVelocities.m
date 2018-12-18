%resample and store the forward velocity
% T: trajectory (N x 3) x, y, angle (rad)
function [dx, dy] = getForwardAndSidewardVelocities(T)
dx = diff(T(:,1)); % index 2, also x daten in track
dy = diff(T(:,2));
for k = 1:length(dx)
    w = T(k, 3);
    A = rotationMatrix(-w); % *substract* the body angle 
    v = A*[dx(k);dy(k)]; 
    dx(k) = v(1); % vorwärtskoordinaten
    dy(k) = v(2); %seitwärtskoordinaten
end

function A = rotationMatrix(angle)
c = cos(angle);
s = sin(angle);
A = [c -s; s c];