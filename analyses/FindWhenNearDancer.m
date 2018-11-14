% d: distances between head of follower and body of dancer
% for erosion and diletation
% remove_noise_width: dependent on framerate, usually framerate/10
% fill_gaps_width: depends on framerate usually
function Iborders = FindWhenNearDancer(d, remove_noise_width, fill_gaps_width)
% Iborders indices of intervals in which the follower is close enough to the dancer

% nargin = number of input arguments
if nargin < 2
    remove_noise_width  = 10;
    fill_gaps_width     = 100;
end


%binary mask
B = zeros([1 length(d)]);
%indices when closer than 8 mm
Inear = find(d < 8);
%fill binary mask
B(Inear) = 1;

%morphological ops
C = erode1d(B, remove_noise_width);     %erase noise
A = dilate1d(C, fill_gaps_width + remove_noise_width);   %fill gaps
A = erode1d(A, fill_gaps_width, 1);    %shorten ends

%where is A == 1
Iones = find(A);
%where are gaps between sequences of 1s? indices of non-consecutive patches
% @TIM: >=1?!, 1-0 ist doch =1
Inconsec = find(diff(Iones) > 1);

% Iborders contains the indices in d where bees are close enough to show
% following behavior (start: 1st column; end: 2nd column)
Iborders = [min(Iones) Iones(Inconsec+1); Iones(Inconsec) max(find(A))]';