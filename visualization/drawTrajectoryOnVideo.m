% this skript gets the name of a folder 
% e.g. 'C:\Users\Franzi\Downloads\AnalysisOfDanceFollowing\trajectories\Folgeläufe am Roboter\capture (2011-09-10 at 14-04-09)_NG71follows_part1_'

function drawTrajectoriesOnVideo(trackFolder)        
    if splineInterpolated
        rectified = 1;
    end 
    if rectified
        % get the track - .rbt load robot track, .flw follower track
        trackPath = strcat(trackFolder, '\trajectories\followers.rect');
        videoPath = strcat(trackFolder, '\video\rectified.avi');
        % the Transform matrix is needed to convert between world
        % coordinates and pixels
        v_in        = VideoReader(videoPath);   % reader object
        transPath = strcat(trackFolder,'\video\Transform.mat');
        Trans = importdata(transPath);
        % retrieve values needed to conversion
        [width, height, xStartPixel, yStartPixel] = initializeWorldCoordsToPixel(v_in, Trans);

    else
        trackPath = strcat(trackFolder, '\trajectories\followers.raw');
        videoPath = strcat(trackFolder, '\video\original.avi');
        v_in        = VideoReader(videoPath);   % reader object
    end
    
    % is splineInterpolated: take the spline interpolated track
    if splineInterpolated
        trackPath = strcat(trackFolder, '\trajectories\followers.ups');
    end
    
    T = loadTrack(trackPath);

    
    
    
    % find from which frame the tracking has started
    % only from then on, a track needs to be plotted
    trackStart = T(1:1);

    % varibales for visualization of video frames and trajectories
    hFig = figure('Name','trajectory',...
        'Units','pixels',...
        'Position',[100 100 v_in.Width v_in.Height]);
    hAx = axes('Parent',hFig,...
        'Units','pixels',...
        'Position',[0 0 v_in.Width v_in.Height],...
        'NextPlot','add',...
        'Visible','off',...
        'XTick',[],...
        'YTick',[]);
    hIm = image(uint8(zeros(v_in.Height,v_in.Width,1)),...
        'Parent',hAx);

    %output video -- optional
    % v_out = VideoWriter('drawTrack.avi');
    % v_out.FrameRate = v_in.FrameRate;
    % open(v_out);

    % assert to start the reader in the first frame
    v_in.CurrentTime    = 0; 
    frameIdx            = 1;                        %current frame 
    % remember the x and y pixel to plot a line
    xOld = NaN;
    yOld = NaN;
    % box is the rotated box to be drawn on the frame
    box = gobjects(0);
    while hasFrame(v_in)

        pic = readFrame(v_in);
        
        % the rectified videos we have do have other encoding and need to
        % be flipped on the y axis to be correctly displayed
        if rectified
            pic = flipud(pic);
        end
       
        hIm.CData = pic;

        % the frames for which no tracking exists are left as they were
        % the others need the point for where the robot was
        if frameIdx >= trackStart
            
            % clear the old box
            delete(box);
            
            % only if a value is found in the track
            % we draw a line between the old point and the new one
            if ~isnan(T(frameIdx-trackStart+1,2)) 
                % verify that we get data from the correct index
                % disp(T(frameIdx-trackStart+1,1));
                
                if rectified
                    % then convert by rule of three the mm from the track
                    % to pixel to fit ontop of the video frame
                    xPixel = T(frameIdx-trackStart+1,2)/ width * v_in.Width - xStartPixel;
                    yPixel = T(frameIdx-trackStart+1,3)/ height * v_in.Height - yStartPixel;
                else
                    xPixel = T(frameIdx-trackStart+1,2);
                    yPixel = T(frameIdx-trackStart+1,3);
                end
                    
                % for the start point of the line -- TODO: more efficient way
                if isnan(xOld) && isnan(yOld)
                    xOld = xPixel;
                    yOld = yPixel;
                end

                % hack: while the picture is read with the correct y axis
                % the plot has still the reversed y axis
                % we therefore do plot v_in.Height - actual hight (flip)
                plot(hAx, [xOld xPixel], [v_in.Height-yOld v_in.Height-yPixel], 'g');
                
                % plot the box around the objects
                points = [xPixel v_in.Height-yPixel];
                box = plot_RotatedRectangle(points, -T(frameIdx-trackStart+1,6),27,'r',10);
                xOld = xPixel;
                yOld = yPixel;
                
                
            end
            

        end

        % make a video frame out of the loaded frame and the plot on top
        F = getframe(hAx);
        frameIdx = frameIdx+1;

        % write it to output video
        % writeVideo(v_out, F);

    end

% close output video
% close(v_out);

end 

% if the rectified or spline interpolated tracks are given, their world 
% coordinates need to be converted to pixel coodinates for plotting.
% udata: image width in pixel
% vdata: image height in pixel
% 
function [width, height, xStartPixel, yStartPixel] = initializeWorldCoordsToPixel(v_in, Trans)
    pic = readFrame(v_in); %reads the first frame

    udata = [1 640];  
    vdata = [1 480];

    [~,xdata,ydata] = imtransform(pic,Trans,'bicubic','udata',udata,...
                                                    'vdata',vdata,...
                                                    'size',size(pic),...
                                                    'fill',128);

    % xdata: leftmost and rightmost image coord in mm 
    % (after rectification) e.g. [-30.0 157.8]  
    % y data: similar for lowest and highest
    width = xdata(2) - xdata(1); %width of frame in mm
    height = ydata(2) - ydata(1); %height of frame in mm

    xStartPixel = xdata(1)/width * v_in.Width; % leftmost image coord in pixel
    yStartPixel = ydata(1)/height * v_in.Width; % most up image coord in pixel
end 
