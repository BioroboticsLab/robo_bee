function R = dilate1d(A, iterations)

R = zeros(size(A));

for iter = 1:iterations

    for i = 2:length(A)-1
        if (A(i))
            R(i) = 1;
            R(i+1) = 1;
            R(i-1) = 1;       
        end
    end
    
    A = R;
    
end