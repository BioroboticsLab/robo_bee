% Params as provided from the loadTrajectoryFilesFromFolder
function drawTrajectoriesOnVideo(Params)

UD.vidobj           = VideoReader(Params.videoFilename);

% varibales for visualization of video frames and trajectories
hFig = figure('Name','trajectory',...
    'Units','pixels',...
    'Position',[100 100 UD.vidobj.Width UD.vidobj.Height]);
hAx = axes('Parent',hFig,...
    'Units','pixels',...
    'Position',[0 0 UD.vidobj.Width UD.vidobj.Height],...
    'NextPlot','add',...
    'Visible','off',...
    'XTick',[],...
    'YTick',[]);
hIm = image(uint8(zeros(UD.vidobj.Height,UD.vidobj.Width,1)),...
    'Parent',hAx);

UD.i                = 1;            %current frame (relative, is index to idx)
UD.T                = Params.T;     %trajectory

% Q holds all Trajectories, in order to find the indices in which data is
% available
Q                   = cat(1, Params.T{:});
UD.idx              = min(Q(:, 1)) : max(Q(:, 1));  % find the earliest start index in all tracks
UD.img              = read(UD.vidobj, UD.idx(1));   % earliest frame where sth is tracked
UD.colors           = 'ymbgrcymbgrc';               % color array for different tracks

% initialize the start points of the lines for the trajectories
% and the bounding boxes
for i = 1:length(Params.T)
    UD.roi{i}(1,:)     = UD.T{i}(1, 2:6);  
    UD.box{i} = gobjects(0);
end

% iterate over all frames where we have tracked data
for frameIdx = 1 : length(UD.idx)
   
    % display the current frame with correct title
    UD.i = frameIdx;
    UD.img = read(UD.vidobj, UD.idx(UD.i));
    hFig.Name = printText(UD);
    hIm.CData = UD.img;
    
    % iterate over all available trajectories
    for p = 1:length(UD.T)
        
        % if trajectory has data for current frame index
        j{p} = find( UD.idx(UD.i) == UD.T{p}(:,1) );
        if ~isempty(j{p})        
            
            % plot the lines following the trajectories
            linePoints = getLinePoints(UD, j, p);
            plot(hAx, linePoints(1,:), linePoints(2,:), UD.colors(p));
                        
            % TODO: do not hardcode 27x10 as box sizes; deal with flipped
            % y-axis and thus flipped angle for robot; do not make it look
            % overloaded
            delete(UD.box{p})
            UD.box{p} = plot_RotatedRectangle(linePoints(:,2)', -UD.T{p}(j{p},6),27,UD.colors(p),10);
            
            % update the roi to the current line in trajectory
            UD.roi{p}(1,:)     = UD.T{p}(j{p}, 2:6)';
        end
    end
    F = getframe(hAx);
end

% make the title for the graphic window
function s = printText(UD)
minutes = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate * 60));
seconds = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate) - minutes * 60);

s = sprintf('Showing frame %d / %d (%d:%d) - frameID:%d.', UD.i, length(UD.idx), minutes, seconds, UD.idx(UD.i));

% gets the start and end x/y-points for the lines/boxes
function points = getLinePoints(UD, j, p)
xOld = UD.roi{p}(1,1); % UD.roi has 5 values (not the frame index), thus x is first value, y second
xPixel = UD.T{p}(j{p}, 2); % UD.T still has 6 values, first one being frame index
yOld = UD.roi{p}(1,2);
yPixel = UD.T{p}(j{p}, 3);
% we need to subtract from height as video is flipped 
points = [xOld xPixel; UD.vidobj.Height-yOld UD.vidobj.Height-yPixel];

