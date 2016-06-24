% UW ADAS Activity 2

clear all; close all; clc;

vidIn= VideoReader('videos/binaryActivity2Video.mp4');
vidOut = VideoWriter('videos/activity2_UW');

% Constanta
minArea = 350;
diskArea = 50;

shapeInserter = vision.ShapeInserter('Shape','Rectangles','BorderColor', ...
    'Custom','CustomBorderColor', uint8([0 100 255]));

% vidIn.CurrentTime = 12;
open(vidOut)
while hasFrame(vidIn)
    I = readFrame(vidIn);
    BW = im2bw(I);          % convert to binary
    BW_filt = bwareaopen(BW , minArea); % remove white noise < minArea

    BW_close = imclose(BW_filt, strel('disk', diskArea));     % fill in blob
    BW_OR = BW_close | BW;      % combine blob with original video
    RGB = 255*uint8(cat(3, BW_OR, BW_OR, BW_OR));   % convert to RGB

    % Apply bounding rectangle
    props = regionprops(BW_close, 'BoundingBox');  % bounding box for blobs
    n_boxes = 0;
    for j = 1:size(props,1)     % for each bounding box
        rect = int32(props(j).BoundingBox); % rectangle object
        ratio = 100*rect(4)/rect(3);    % ratio of box height to width
        area = rect(4)*rect(3);         % filter out outlier rectangles
        if (ratio > 30 && ratio < 500 && area > 1000 && area < 9000)
            n_boxes = n_boxes + 1;  % box counter
            I_rect = step(shapeInserter, RGB, rect);    % draw rectangle
            x_center = int2str(rect(1) + round(rect(3)/2));   % Add text
            y_center = int2str(rect(2) + round(rect(4)/2));
            string = [int2str(rect(4)), ' x ' int2str(rect(3)), ...
                ' C : (', x_center, ' , ', y_center, ')'];
            RGB = insertText(I_rect,[rect(1), rect(2) + rect(4)],string, ...
            'TextColor','green', 'FontSize', 15, 'BoxOpacity', 0);
        end
        numBoxes = ['Boxes : ', int2str(n_boxes)];
        final = insertText(RGB,[0, 1000],numBoxes, ...
        'TextColor','green', 'FontSize', 24, 'BoxOpacity', 0);  % insert text
    end
    % imshow(BW_close) % display frames
     writeVideo(vidOut, final);
end
close(vidOut)
