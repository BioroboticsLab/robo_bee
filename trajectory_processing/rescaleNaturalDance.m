% this skript gets the name of a folder 
% which contains all information about ONE trajectory 
% filename: string -- the name of the output file eg. 'follower'
function rescaledTrack = rescaleNaturalDance(Params, i)
% it rescales the trajectory according to the space norm

    T = Params.T{i};
    space_norm = Params.space_norm;

    % extract 
    X = T(:,2);
    Y= T(:,3);
    
    % we know that 5cm / space_norm =  Xcm / pixel
    % <=> X = 5/space_norm * pixel 
    
    X = X*5/space_norm;
    Y = Y*5/space_norm;
    rescaledTrack = [T(:,1) X Y T(:,4) T(:,5) T(:,6)];

end

