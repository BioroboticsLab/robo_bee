% L: [VecX VecY X Y] direction from the hind quarters of the bee to the head 
% and point of robot hind quarters
% p: [X Y] head point of the follower
function [d, a, d2] = point_line_dist(L, p)
% d from point distance to line of bee axis
% a defines where the orthogonal hits the given line segment
% (0 <= a <= 1 when orthogonal hits the line segment)
% orthogonal might hit the line, but in front of or behind the bee
% d2 distance to line segment representing the bee from head to back
% this is what we are looking for, as the distance to the line of the bee
% is not interesting, if it hits a lot in front of or after



% vector of direction
v = L(1:2);
% point of back of bee 
b = L(3:4);
n = size(p, 1);

% where does the orthoganal hit the line (in front of/behind/on the bee)?
a = (p*v' - b*v') ./ (v*v');

% points where the orthogonal hits the line
s = p - (repmat(a, 1, 2).*repmat(v, n, 1) + repmat(b, n, 1) );

% distance between point and line 
d = sqrt(s(:,1).^2 + s(:,2).^2);


%d2 contains the points for head to line segement distances with a<0 and a>1
d2      = d; % for points 0<=a<=1, d2 equals d
l       = norm( L(1:2) ); % length of the line segment
i       = find( a > 1 ); % distance to bee head
d2(i)   = sqrt( (a(i)*l - l).^2 + d(i).^2 ); 
i       = find( a < 0 ); % distance to bee rear
d2(i)   = sqrt( (a(i)*l).^2 + d(i).^2 );


% TAKEN FROM THAT RECIPE: (irgendein forum)

% I. Bilde den allg. Ortsvektor für einen Punkt auf der Geraden. (ich nenn den mal $ \vec{p}) $
% 
% II. Bilde den Vektor zwischen $ \vec{p} $ und dem Ortsvektor deines Punktes. Es ergibt sich der Vekotr (ich nenn den) $ \vec{s} $
% 
% III. RV (Richtungsvektor) der Geraden muss ja senkrecht auf $ \vec{s} $ stehen, also muss deren Skalarpodukt 0 ergeben.
% Also folgende Gleichung auflösen: $ \vec{s}\cdot{}RV=0 $
% 
% IV. Ergebnis aus III. in $ \vec{s} $ einsetzen.
% 
% V. $ |\vec{s}| $ ist dann der gesuchte Abstand.
