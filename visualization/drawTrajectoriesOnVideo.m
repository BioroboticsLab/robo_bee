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
UD.colors           = 'ymbgrymbgrrgbmy';            % color array for different tracks
%UD.fig              = figure(1); 

% initialize the start points of the lines
for i = 1:length(Params.T)
    UD.roi{i}(1,:)     = UD.T{i}(1, 2:6);     % contains data of track start
    UD.lineHandle{i}   = [0 0 0]; %?? was macht das?

    % is for the current frame data is available, plot it
    %if ( UD.roi{i}(1,1) == UD.idx(1) )
    %    UD = plotROI(UD, i, 1, [ ':' UD.colors(i) ]); % plot ROI #1
    %end
end

% iterate over all frames where we have tracked data
for frameIdx = 1 : length(UD.idx)
    UD.i = frameIdx;
   % UD = readNewFrameAndDisplay(UD);
    UD.img = read(UD.vidobj, UD.idx(UD.i));
    hIm.CData = UD.img;
    for p = 1:length(UD.T)
        %index in UD.T where trajectory data is available for the current frame index
        j{p} = find( UD.idx(UD.i) == UD.T{p}(:,1) );
        
        if ~isempty(j{p})        
            j{p}
            xOld = UD.roi{p}(1,1); % UD.roi has 5 values (not the frame index)
            xPixel = UD.T{p}(j{p}, 2); % UD.T still has 6 values, first one being frame index
            yOld = UD.roi{p}(1,2);
            yPixel = UD.T{p}(j{p}, 3);
        
   
            plot(hAx, [xOld xPixel], [UD.vidobj.Height-yOld UD.vidobj.Height-yPixel], UD.colors(p));
            UD.roi{p}(1,:)     = UD.T{p}(j{p}, 2:6)';
            
        end
    end
    F = getframe(hAx);
end


%UD.N                = length(UD.idx);
%close all


function printText(UD)
minutes = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate * 60));
seconds = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate) - minutes * 60);

s = sprintf('Showing frame %d / %d (%d:%d) - frameID:%d.', UD.i, length(UD.idx), minutes, seconds, UD.idx(UD.i));
title(s);

function UD = readNewFrameAndDisplay(UD)
UD.img = read(UD.vidobj, UD.idx(UD.i));                 %get new image
%figure(UD.fig);
%hold off                                                %hold off to erase old data
%imshow(UD.img);                                         %draw it
% hold on                                                 %hold plot
% printText(UD);                                          %draw information on figure
%hIm.CData = UD.img;
for i = 1:length(UD.T)
    UD.lineHandle{i} = zeros(1,3);                             %delete all (now invalid) handles
end
