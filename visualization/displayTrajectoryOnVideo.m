function displayTrajectoryOnVideo(Params)

    close all

    UD.vidobj           = VideoReader(Params.videoFilename);
    UD.i                = 1;            %current frame (relative, is index to idx)
    UD.T                = Params.T;     %trajectory
    if isfield(Params, 'Trect')
        UD.Tr               = Params.Trect; %rectified Trajectory
    end
    if isfield(Params, 'Trs')
        UD.Trs              = Params.Trs;   %spline-interpolated Trajectory
    end
    if isfield(Params, 'Trans')
        UD.Trans            = Params.Trans;
    end

    % Q holds all Trajectories, in order to find the indices in which data is
    % available
    Q                   = cat(1, Params.T{:});
    UD.idx              = min(Q(:, 1)) : max(Q(:, 1));
    UD.img              = read(UD.vidobj, UD.idx(1));

    UD.colors           = 'ymbgrymbgrrgbmy';
    UD.fig              = [figure(1) figure(2)]; %normal and rectified frame 

    readNewFrameAndDisplay(UD);

    for i = 1:length(Params.T)
        disp(i)
        UD.roi{i}(1,:)     = UD.T{i}(1, 2:6);     %currently displayed roi

        if isfield(UD, 'Tr')
            UD.roi{i}(2,:)     = UD.Tr{i}(1, 2:6);    %rectified data
        end

        if isfield(UD, 'Trs')
            UD.roi{i}(3,:)     = UD.Trs{i}(1,2:6)     %rectified and spline interpolated
        end

        UD.lineHandle{i}   = [0 0 0];
        if ( UD.roi{i}(1,1) == UD.idx(1) )
            UD                 = plotROI(UD, i, 1, [ ':' UD.colors(i) ]); % plot ROI #1
        end
    end
    UD.N                = length(UD.idx);
    %in mm
    UD.TargetRect       = [0 115 115 0 0; 115 115 0 0 115; 1 1 1 1 1];
    UD.clicked          = 0; %mouse clicked 
    UD.userMovedBox     = 0;


    UD.allowUserInput   = 0;

    set(UD.fig(1), 'UserData',              UD);
    %set(UD.fig(1), 'WindowButtonMotionFcn', @mouseMove);
    %set(UD.fig(1), 'WindowButtonDownFcn',   @mouseDown);
    %set(UD.fig(1), 'WindowButtonUpFcn',     @mouseUp);
    set(UD.fig(1), 'KeyPressFcn',           @keyPressed);
    %set(UD.fig(1), 'WindowScrollWheelFcn',  @mouseWheel);
    set(UD.fig(1), 'Interruptible',         'off');

    eval('waitfor(UD.fig(1))')

    close all

%%
% function mouseWheel(object, eventdata)
% UD = get(gcbo, 'UserData');
% if UD.allowUserInput
%     UD.roi(3:4) = UD.roi(3:4) * (1 - eventdata.VerticalScrollCount / 10);
%     set(gcbo, 'UserData', UD);
%     moveROIinFigure(UD.lineHandle(1), UD.roi);
% end

% function mouseMove(object, eventdata)
% UD = get(gcbo, 'UserData');
% if UD.allowUserInput
%     if UD.clicked
%         coords = get(gca,'CurrentPoint');
%         if (UD.clicked == 2)
%             UD.roi(5) = UD.angle + ( UD.y - coords(1, 2)) / 40;
%         else
%             UD.roi(1:2) = coords(1, 1:2);
%         end
%         set(gcbo, 'UserData', UD);
%         moveROIinFigure(UD.lineHandle(1), UD.roi);
%     end
% end

% function mouseDown(object, eventdata)
% UD = get(gcbo, 'UserData');
% if UD.allowUserInput
%     coords = get(gca,'CurrentPoint');
%     if strcmp(get(gcbo,'SelectionType'), 'normal')
%         UD.clicked = 1;
%         UD.roi(1:2) = coords(1, 1:2);
%     else
%         UD.clicked = 2;
%         UD.angle = UD.roi(5);
%         UD.y = coords(1, 2);
%     end
%     set(gcbo, 'UserData', UD);
%     moveROIinFigure(UD.lineHandle(1), UD.roi);
% end
% 
% function mouseUp(object, eventdata)
% UD = get(gcbo, 'UserData');
% if UD.allowUserInput
%     UD.clicked = 0;
%     UD.userMovedBox = 1;
% 
%     if UD.mode
%         i = UD.i;
%         %update the source roi for tracking
%         UD.tld.source.rotROI    = UD.roi;
%         %update the tracker's input image
%         UD.tld.img{i}           = img_get(UD.tld.source,UD.idx(i)); 
%         %update the tracker's current bounding box
%         UD.tld.bb(:, i)            = beeTLD_getCenteredBB(UD.tld.img{i}.input, UD.roi(3:4));
%     end
%     set(gcbo, 'UserData', UD);               %write user data back to figure
% end

function j = fwd(i, N, steps)
    j = min(N, i + steps);
    
function j = rwd(i, N, steps)
    j = max(1, i - steps); 

function keyPressed(object, eventdata)
global R i;
UD      = get(gcf, 'UserData');
i       = UD.i;
reload  = 0;
eventdata.Key
switch eventdata.Key
    %Video control+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    case 'numpad3'  % fwd frame
        UD.i = fwd(i, UD.N, 1)
        reload = 1;
    case 'numpad1'  % rwd frame
        UD.i = rwd(i, UD.N, 1)
        reload = 1;
    case 'numpad6'  % fwd 10 frames
        UD.i = fwd(i, UD.N, 10)
        reload = 1;
    case 'numpad4'  % rwd 10 frames
        UD.i = rwd(i, UD.N, 10)
        reload = 1;
    case 'numpad9'  % fwd 1000 frames
        UD.i = fwd(i, UD.N, 1000)
        reload = 1;
    case 'numpad7'  % rwd 1000 frames
        UD.i = rwd(i, UD.N, 1000)
        reload = 1;
    case 'numpad5' % jump to next data point
        reload = 1;
        Q               = UD.T{1}(:,1) - UD.idx(UD.i);
        Q(find(Q<=0))    = Inf;
        [m,q]           = min(Q);
        UD.i            = find( UD.idx == UD.T{1}(q,1));
    %-----------------------------------------------------end Video Control
    
      
    case 'escape'
        R = UD.roi;
        f = gcf;
        close(f);
        waitfor(f)
    otherwise
end

%paint the whole figure again (gets rid of all past graphic objects)
if reload
    % display frame
    UD = readNewFrameAndDisplay(UD);    
        
    for p = 1:length(UD.T)
        %index in UD.T where trajectory data is available for the current frame index
        j{p} = find( UD.idx(UD.i) == UD.T{p}(:,1) );
        
        if ~isempty(j{p})        
            j{p}
            UD.roi{p}(1,:)     = UD.T{p}(j{p}, 2:6)'; 
            
            if isfield(UD, 'Tr')
                UD.roi{p}(2,:)     = UD.Tr{p}(j{p}, 2:6)'; 
                UD                 = plotROI(UD, p, 2, '');    % plot ROI #2
            end
            
            UD                 = plotROI(UD, p, 1, '');    % plot ROI #1
            
        end
        
        if isfield(UD, 'Trs')
            k{p} = find( UD.idx(UD.i) == UD.Trs{p}(:,1) );
        
            if ~isempty(k{p})        
                UD.roi{p}(3,:)     = UD.Trs{p}(k{p}, 2:6)'; 
                UD                 = plotROI(UD, p, 3, '');  % plot ROI #3
            end
        end
    end
    
end

if (gcbo)
    set(gcbo, 'UserData', UD);               %write user data back to figure
end
        
        

function printText(UD)
minutes = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate * 60));
seconds = floor(UD.idx(UD.i) / (UD.vidobj.FrameRate) - minutes * 60);

s = sprintf('Showing frame %d / %d (%d:%d) - frameID:%d.', UD.i, length(UD.idx), minutes, seconds, UD.idx(UD.i));
title(s);

% 
% set(gca, 'Units', 'pixels');
% pos = get(gca, 'Position');
% text(-40, pos(4) + 30, figureText(UD.mode));
% switch UD.mode
%     case 1
%         set(gcf,'Color',[128 255 0]/255);
%     case 2
%         set(gcf,'Color',[255 255 0]/255);
%     case 3
%         set(gcf,'Color',[255 128 0]/255);
%     case 7
%         set(gcf,'Color',[1 1 1]);
% end
%128 255 0
%255 255 0
%255 128 0

% pastell
% 184 245 0
% 245 184 0
% 255 102 51


function moveROIinFigure(plotHandle, roi)
[XData, YData] = beeTLD_getPlotDataForRotROI(roi);  %get box data
set(plotHandle, 'XData', XData);                    %move roi xdata
set(plotHandle, 'YData', YData);                    %move roi ydata

function s = figureText(mode)
switch mode
    case 0 %configure mode
        s = ['Left mouse click and drag to position the box. Right click and drag up and down to rotate. ' char(10) ...
            'Mouse wheel to scale. Use numpad 4 and 6 (7 and 9) to rwd and fwd the video 1 (20) frames, resp.'];
    case 1
        s = ['F1: Learning Mode. Move the box on a bee and press Space. Please be precise. ' char(10) 'The model will be trained with some rotational variants'];
    case 2 %semi-automatic tracking
        s = ['F2: Semi-Automatic Tracking. Push space to accept current (yellow) position and ' char(10)   ...
             'advance video for one frame. Use the mouse for adjustments to the yellow box. '];
    case 3 %automatic tracking
        s = ['F3: Automatic tracking. Push Enter to toggle tracking.'];
    case 7 %automatic tracking
        s = ['F7: God Mode. Congratulations.'];
end

% UD : UserData struct
% i  : trajectory ID
% n  : 1->original data, 2->rectified data, 3->spline interpolation
function UD = plotROI(UD, i, n, style)
style = [ UD.colors(i+(n-1)*5) style ];
%if linehandle exists, we move the box according to roi
if UD.lineHandle{i}(n)
    moveROIinFigure(UD.lineHandle{i}(n), UD.roi{i}(n,:));              
else %if it doesnt exist we plot is freshly
    
    if n > 1                                                        %if roi #2 or #3 are plotted, we pull the rectified window to the front
        figure(UD.fig(2));
    else
        figure(UD.fig(1));
    end
    
    [XData, YData]      = beeTLD_getPlotDataForRotROI(UD.roi{i}(n,:)); %get box data
    UD.lineHandle{i}(n) = plot(XData, YData, style);                %plot box and store handle

    figure(UD.fig(1));                                              %bring previous window to front
end
    
function UD = readNewFrameAndDisplay(UD)
UD.img                  = read(UD.vidobj, UD.idx(UD.i));            %get new image

if isfield(UD, 'Trans')
    % make rectified image
    udata                   = [1 size(UD.img, 2)];  
    vdata                   = [1 size(UD.img, 1)];
    [UD.img2, xdata,ydata]  = imtransform(UD.img,UD.Trans,'bicubic','udata',udata,...
                                                            'vdata',vdata,...
                                                            'size',size(UD.img),...
                                                            'fill',128);   
    UD.xdata = xdata;
    UD.ydata = ydata;
    figure(UD.fig(2))

    %erase (old) content of figure
    hold off       

    imshow(UD.img2,'XData',UD.xdata,'YData',UD.ydata)
    hold on
end


figure(UD.fig(1))
hold off                                                %hold off to erase old data
imshow(UD.img);                                         %draw it
hold on                                                 %hold plot
printText(UD);                                          %draw information on figure

for i = 1:length(UD.T)
    UD.lineHandle{i} = zeros(1,3);                             %delete all (now invalid) handles
end




