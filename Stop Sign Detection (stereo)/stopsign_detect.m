%****************************************************************************
% Stop Sign Detect
% University of Washington
% EcoCAR 3 ADAS Team
% Jake Garrison, Novin Changizi
%*****************************************************************************


%% Initialize System Objects
vid_reader = VideoReader('comp_provided.mp4'); % ecocar vid
% vid_reader = VideoReader('team_provided.mp4'); % UW vid
vid_writer = VideoWriter('output.mp4', 'MPEG-4'); % output
detector = vision.CascadeObjectDetector('stopSignDetector_10_10.xml');
open(vid_writer);
vid_player = vision.VideoPlayer;

roi = [1000 100 800 200]; % provided video
% roi = [397 310 576 256]; % extra video
text_loc = [700 750];

%% Loop Through Frames
pred_box_count = 0; color_box_count = 0;
shift = [roi(1,1) roi(1,2) 0 0];
while hasFrame(vid_reader)
    frame = readFrame(vid_reader);
    frame_crop = imcrop(frame,roi); % extract roi

    % Try Stopsign Object Detector
    boxes = step(detector, frame_crop);
    boxes = boxes + repmat(shift, size(boxes, 1), 1); % shift to correct box coord
    if ~isempty(boxes)    % Found stopsign
        % Annotate Stopsign
        for i=1:size(boxes,1)
            box = boxes(i,:);
            pred_box_count = pred_box_count + 1;
            box_str = annotate_box(box, size(frame,2), size(frame,1));
            frame = insertObjectAnnotation(frame, 'rectangle', box, ...
                box_str, 'FontSize',14, 'LineWidth',4,'Color', 'cyan');
            frame = insertText(frame,text_loc,'Using Cascade Object Detector', ...
                'TextColor','cyan', 'FontSize', 40, 'BoxOpacity', 0);
        end


%     % Try Color Based Detector
    else
        BW = extract_red_sign(frame_crop); % extract red blobs
        props = regionprops(BW, 'BoundingBox');  % bounding box for blobs
        for j = 1:size(props,1)     % for each bounding box
            box = props(j).BoundingBox; % rectangle object
            box = box + repmat(shift, size(box, 1), 1); % shift to correct box coord

            % Annotate Stopsign
            if box(3)/box(4) > 0.5 && box(3)/box(4) < 1.5
                color_box_count = color_box_count+1;
                box_str = annotate_box(box, size(frame,2), size(frame,1));
                frame = insertObjectAnnotation(frame, 'rectangle', box, ...
                    box_str, 'FontSize',14, 'LineWidth',4,'Color', 'green');
                frame = insertText(frame,text_loc,'Using Color Based Detector', ...
                    'TextColor','green', 'FontSize', 40, 'BoxOpacity', 0);
            end
        end
    end

    writeVideo(vid_writer,frame)
    step(vid_player, frame)
end

%% Release System Objects
release(detector)
close(vid_writer)
release(vid_player)

%% Results
pred_box_count
color_box_count
color_box_count + pred_box_count
