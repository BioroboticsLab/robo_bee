function rectifyVideo(trackFolder)

    videoPath = strcat(trackFolder, '\video.avi');
    transPath = strcat(trackFolder,'\Transform.mat');

    % we need the video and the transformation data
    Trans = importdata(transPath);
    v_in = VideoReader(videoPath);

    % for output
    outputPath = 'here.avi'; %strcat(trackFolder, '\preprocessedData\rectifiedVideo.avi');
    v_out = VideoWriter(outputPath);
    v_out.FrameRate = v_in.FrameRate;
    open(v_out);
    
    while hasFrame(v_in)

        % flipud to reverse what readFrame internally does
        pic = flipud(readFrame(v_in));

        % processing of 'pic' into rectified version

        %source frame -- copied from draw polygone
        udata = [1 640];  
        vdata = [1 480];

        [B,~,~] = imtransform(pic,Trans,'bicubic','udata',udata,...
                                                    'vdata',vdata,...
                                                    'size',size(pic),...
                                                    'fill',128);

        
        writeVideo(v_out, B);
    end
    close(v_out);

end



