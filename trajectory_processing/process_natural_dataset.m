% function to perform the rectification and spline interpolation on all
% tracks in the folder (the dancer(s) and each follower)
% provide path to robodance data
naturalDancePath = 'C:\Users\Franzi\Downloads\Arbeitsergebnisse\tmp\natural_dances\';

% get all subfolders -- code from: https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
d = dir(naturalDancePath);
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
    currentFolder = strcat(naturalDancePath, nameFolds{n});
    
    % load all parameters from that folder. T contains the tracks.
    Params = loadNaturalTrajectoryFilesFromFolder(currentFolder);
    
    % iterate over all trajectories
    for i = 1 : length(Params.T)
        
        
        % rectification
        rescaledPath = strcat(currentFolder, '\trajectories\', Params.filenames{i}, '.rect');
        rescaledTrack = Params.Tr{i};
        saveTrack(rescaledTrack, rescaledPath, Params.headers{i})
        
        % actually not needed, but to be consistend with robot dataset
        % save the rescaled version with extention .ups 
        % Params.Tr{i} = Params.Ts{i} (see
        % loadNaturalTrajectoryFilesFromFolder.m)
        splinePath = strcat(currentFolder,'\trajectories\',Params.filenames{i}, '.ups');
        splineInterpolatedTrack = Params.Ts{i};
        saveTrack(splineInterpolatedTrack, splinePath, Params.headers{i})
        
    end 
    

end