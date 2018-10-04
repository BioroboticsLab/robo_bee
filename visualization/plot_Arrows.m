
% P : Points [x1 y1; x2 y2; ...; xn yn]
% a : angles (rad)
% length of arrow
% s: style
function plot_Arrows(P, a, l, s, w)

I = 1:w:length(a);

sina = l * sin(a(I));
cosa = l * cos(a(I));

X1 = P(I, 1) - cosa;
X2 = P(I, 1) + cosa;

Y1 = P(I, 2) - sina;
Y2 = P(I, 2) + sina;

plot([X1 X2]', [Y1 Y2]', s)