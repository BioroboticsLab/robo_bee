% this function gets a track and saves it to the given path 
% usually needs to be called with track.' 
% which has to be /folder/filename.ending
% headerLine: first line that should be written to the file
function saveTrack(track, path, headerLine)
    
    % bring track to the right form
    track = track.';
    
    fileID = fopen(path,'w');
    
    if nargin == 3 % if headerLine given
        fprintf(fileID,'%s\n',headerLine);
    end
    
    fprintf(fileID,'%d %5f %5f %5f %5f %5f\r\n',track);
    fclose(fileID);
    
end