% P: center point (maybe list of points)
% a: angle (maybe list of angles)
% l: half box length
% s: plot style
% w: paint every w box (when list is passed)
function b = plot_RotatedRectangle(P, a, l, s, w)

I       = 1:w:length(a);

sina    = l * sin(a(I));
cosa    = l * cos(a(I));

sinb    = 0.35*l * sin(a(I) + pi/2); 
cosb    = 0.35*l * cos(a(I) + pi/2);

XM1     = P(I, 1) + cosa;
XM2     = P(I, 1) - cosa;

YM1     = P(I, 2) + sina;
YM2     = P(I, 2) - sina;

X1      = XM1 + cosb;
Y1      = YM1 + sinb;

X2      = XM1 - cosb;
Y2      = YM1 - sinb;

X3      = XM2 + cosb;
Y3      = YM2 + sinb;

X4      = XM2 - cosb;
Y4      = YM2 - sinb;

% original one
b = plot([X1 X2 X4 X3 X1 XM1 X3 XM1 X4]', [Y1 Y2 Y4 Y3 Y1 YM1 Y3 YM1 Y4]', s);

% adapted to the fact that the image is flipped by y in our visualization 
%b = plot([X1 X2 X4 X3 X1 XM2 X1 XM2 X2]', [Y1 Y2 Y4 Y3 Y1 YM2 Y1 YM2 Y2]', s);