% function to perform the rectification and spline interpolation on all
% tracks in the folder (the dancer(s) and each follower)
% provide path to robodance data
roboDancePath = 'C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\robotic_dances\';

% get all subfolders -- code from: https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
d = dir(roboDancePath);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..','_'})) = [];


for n = 1 : length(nameFolds)
    
    % all folders that end with _ should be excluded,
    % they are missing values like I matrix or H matrix
      if nameFolds{n}(end) == '_'
          continue
      end
  
   
    
    % process the individual folder
    currentFolder = strcat(roboDancePath, nameFolds{n});
    
    % load all parameters from that folder. T contains the tracks.
    Params = loadTrajectoryFilesFromFolder(currentFolder, '*.raw');
    
    % iterate over all trajectories
    for i = 1 : length(Params.T)
        
        
        % rectification
        rectPath = strcat(currentFolder, '\trajectories\', Params.filenames{i}, '.rect');
        rectifiedTrack = rectifyTrack(Params, i);
        % save the rectified track in Params
        Params.Tr{i} = rectifiedTrack;
        saveTrack(rectifiedTrack, rectPath, Params.headers{i})
        
        % interpolation and upsampling
        splinePath = strcat(currentFolder,'\trajectories\',Params.filenames{i}, '.ups');
        splineInterpolatedTrack = splineInterpolateTrack(Params, i);
        saveTrack(splineInterpolatedTrack, splinePath, Params.headers{i})
        
    end 
    

end