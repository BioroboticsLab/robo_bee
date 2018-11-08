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
Q                   = cat(1, UD.T{:});
UD.idx              = min(Q(:, 1)) : max(Q(:, 1));  % find the earliest start index in all tracks
UD.img              = read(UD.vidobj, UD.idx(1));   % earliest frame where sth is tracked
UD.colors           = 'ymbgrcymbgrc';               % color array for different tracks
UD.ending           = Params.fileending;


% for rectified images needed for the conversion
if ~strcmp(UD.ending,'*.raw')
    UD.Trans = Params.Trans; %transformation matrix
    [width, height, xStartPixel, yStartPixel] = initializeWorldCoordsToPixel(UD);
    UD.width = width;
    UD.height = height;
    UD.xStartPixel = xStartPixel;
    UD.yStartPixel = yStartPixel;
    
    % iterate over the entire track to convert mm to pixel
    UD = rectified_track_to_pixel(UD);
end


% line handles to remove path segments
storage = java.util.PriorityQueue(5);% matlab.DiscreteEventSystem.queueFIFO('handle', 20);



% initialize the start points of the lines for the trajectories
% and the bounding boxes
for i = 1:length(UD.T)
   
    UD.roi{i}(1,:)     = UD.T{i}(1, 2:6);  
    UD.box{i} = gobjects(0); % empty box
end




     
% iterate over all frames where we have tracked data
for frameIdx = 1 : length(UD.idx)
   
    % display the current frame with correct title
    UD.i = frameIdx;
    UD.img = read(UD.vidobj, UD.idx(UD.i));
    
    % for rectified video, we need to flip the image
    if ~strcmp(UD.ending,'*.raw')
        UD.img = flipud(UD.img);
    end
    
    hFig.Name = printText(UD);
    hIm.CData = UD.img;
    
    % iterate over all available trajectories
    for p = 1:length(UD.T)
        
        % if trajectory has data for current frame index
        j{p} = find( UD.idx(UD.i) == UD.T{p}(:,1) );
        if ~isempty(j{p})        
            
            % plot the lines following the trajectories
            linePoints = getLinePoints(UD, j, p);
            h = plot(hAx, linePoints(1,:), linePoints(2,:), UD.colors(p));
            %storage.add(h);
            
            % never show more than 5 line segments
            %if storage.size() >= 5
             %   handle = storage.remove();
                %disp(handle);
                %delete(handle);
            %end
            
            % TODO: do not hardcode 27x10 as box sizes; deal with flipped
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
% UD: userdata contains all tracks
% j: stores data from current frame index
% p: idx of track (if there are several tracks in UD.T
function points = getLinePoints(UD, j, p)
% safe the old values to use them in the line
xOld = UD.roi{p}(1,1); % UD.roi has 5 values (not the frame index), thus x is first value, y second
yOld = UD.roi{p}(1,2);


xPixel = UD.T{p}(j{p}, 2); % UD.T still has 6 values, first one being frame index
yPixel = UD.T{p}(j{p}, 3);
    

% we need to subtract from height as video is flipped 
points = [xOld xPixel; UD.vidobj.Height-yOld UD.vidobj.Height-yPixel];

% if the rectified or spline interpolated tracks are given, their world 
% coordinates need to be converted to pixel coodinates for plotting.
% udata: image width in pixel
% vdata: image height in pixel
function [width, height, xStartPixel, yStartPixel] = initializeWorldCoordsToPixel(UD)%v_in, Trans)
    pic = UD.img; %reads the first frame

    udata = [1 640];  
    vdata = [1 480];

    [~,xdata,ydata] = imtransform(pic,UD.Trans,'bicubic','udata',udata,...
                                                    'vdata',vdata,...
                                                    'size',size(pic),...
                                                    'fill',128);

    % xdata: leftmost and rightmost image coord in mm 
    % (after rectification) e.g. [-30.0 157.8]  
    % y data: similar for lowest and highest
    width = xdata(2) - xdata(1); %width of frame in mm
    height = ydata(2) - ydata(1); %height of frame in mm

    xStartPixel = xdata(1)/width * UD.vidobj.Width; % leftmost image coord in pixel
    yStartPixel = ydata(1)/height * UD.vidobj.Width; % most up image coord in pixel

    
% given a raw angle, display the rectified version of it
% UD: userdata contains all tracks
% j: row pf track
% p: idx of track (if there are several tracks in UD.T
% IMPORTANT: to be executed while track has still mm and no pixel
function angle = convertAngleToRectified(UD, p,j)
xpos1 = UD.T{p}(j, 2);
ypos1 = UD.T{p}(j, 3);


raw_angle = UD.T{p}(j, 6);

% introduce a new point p2 that lies 10 mm away from this point
xpos2 = xpos1 + 10*cos(-raw_angle); 
ypos2 = ypos1 + 10*sin(-raw_angle);  


% transform both points to pixel coordinates 
xpixel1 = xpos1/ UD.width * UD.vidobj.Width - UD.xStartPixel;
ypixel1 = ypos1/ UD.height * UD.vidobj.Height - UD.yStartPixel;
xpixel2 = xpos2/ UD.width * UD.vidobj.Width - UD.xStartPixel;
ypixel2 = ypos2/ UD.height * UD.vidobj.Height - UD.yStartPixel;

% with the x and y diffs and the hypothenose (distance between points, we
% can calculate the angle
% tan(alpha) = gk / ak
xdiff = abs(xpixel1 - xpixel2); 
ydiff = abs(ypixel1 - ypixel2); 
% we need to do minus because in the plot function we flip the angle
% for raw video
angle = -atan(ydiff/xdiff);



% iterates over a rectified track and converts all mm-coordinates to pixel
function UD = rectified_track_to_pixel(UD)
Tracks = UD.T;

% iterate over all tracks
for i = 1:length(Tracks)
    
    % iterate over all rows in the track
    for j = 1:length(Tracks{i})
        % calculate the angle 
        Tracks{i}(j, 6) = convertAngleToRectified(UD, i,j); %i equals p, jth row
        % calculate the pixel
        xPixel = Tracks{i}(j, 2)/ UD.width * UD.vidobj.Width - UD.xStartPixel;
        yPixel = Tracks{i}(j, 3)/ UD.height * UD.vidobj.Height - UD.yStartPixel;
        % and overwrite the milimeter data with pixel data
        Tracks{i}(j, 2) = xPixel;
        Tracks{i}(j, 3) = yPixel;
    end

    UD.T = Tracks;
end

