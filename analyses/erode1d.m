function R = erode1d(A, iterations, preserveStartAndEnd)
R = zeros(size(A));

if nargin < 3
    preserveStartAndEnd = 0;
end

if preserveStartAndEnd
    R(1) = 1;
    R(end) = 1;
end

for iter = 1:iterations

    for i = 2:length(A)-1
        if (A(i))    
            if (A(i-1) & A(i+1))
                R(i) = 1;
            else
                R(i) = 0;
            end
        end
    end
    
    A = R;
    
end