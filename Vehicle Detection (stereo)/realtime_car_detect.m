%****************************************************************************
% Car Detect and Track
% University of Washington
% EcoCAR 3 ADAS Team
% Jake Garrison, John Bjorge, Taylor Bradley
%*****************************************************************************

clc; clear; close all
set(0,'DefaultFigureWindowStyle','docked')
tic

%% Settings
weight = [2 5 8 12 17 25 27 30]; % older sample less weight
n_bins = length(weight);    % buffer size for weighted sum
choose_roi = false;         % Toggle manual roi
roi = [663 408 312 123];    % hardcoded roi
% roi = [743  405  155 1485] % smaller roi

% Load data
load stereoParams
left_img = imageSet(fullfile('frames/', 'left'));
right_img = imageSet(fullfile('frames/', 'right'));
output_path = 'output.mp4';
detector = vision.CascadeObjectDetector('CarDetector.xml');

% Other settings
disp_rng = [0 64]; % disparity min and max distance
thresholds=[-5 5; -5 10; 0 30];
W = weight/sum(weight); % normalized weight
text_location = [700 600]; % [x y] coordinates
shift = [roi(1,1) roi(1,2) 0 0];

% Manual ROI selection
% Draw region of interest and double click
if choose_roi
    L_frame = imread(left_img.ImageLocation{1});
    R_frame = imread(right_img.ImageLocation{1});
    [nr,nc] = size(L_frame);
    [L_rect, R_rect] = rectifyStereoImages(L_frame, R_frame, stereoParams);
    figure; imshow(L_rect);
    disp('select roi then double click')
    h = imrect(); wait(h);
    roi = getPosition(h);
end

% Initialize vars and data structures
vid_player = vision.VideoPlayer;
% vid_writer = vision.VideoFileWriter(output_path);
vid_writer = VideoWriter(output_path, 'MPEG-4');
open(vid_writer);
box_count = 0; pred_count = 0; % for debug
n_frames = left_img.Count;
rect_pred = roi; frame_info = [roi 0 0];
data = [];  % growing array of boxes
results = NaN(n_frames, 8);  % prediction results

%% Process Frames
for f = 1:n_frames
    % Read frame
    L_frame = imread(left_img.ImageLocation{f});
    R_frame = imread(right_img.ImageLocation{f});
    [nr,nc] = size(L_frame);

    % Rectify the Images
    [L_rect, R_rect] = rectifyStereoImages(L_frame, R_frame, stereoParams);
     frame = L_rect; % display left frame

    % Generate Disparity Map
    disp_map = disparity(rgb2gray(L_rect),rgb2gray(R_rect),'DisparityRange',disp_rng);

    % Reconstruct Point Cloud
    pt_cloud = reconstructScene(disp_map, stereoParams);
    pt_cloud = pt_cloud/1000; % millimeters to meters.
    pt_cloud = thresholdPC(pt_cloud,thresholds);

    % Extract ROI
    L_crop = imcrop(L_rect,roi);
    R_crop = imcrop(R_rect,roi);

    % Increase Brightness in ROI
    L_crop = rgb2ycbcr(L_crop); % convert colorspace
    L_crop(:, :, 1) = L_crop(:, :, 1) + 100; % brighness++
    L_crop = ycbcr2rgb(L_crop); % back to rgb

    % Detect cars
    boxes = step(detector,L_crop);
    boxes = boxes + repmat(shift, size(boxes, 1), 1); % shift to correct box coord

    %% Score each detected box
    % The box with the highest score is green. Score is measured in pixles
    % Score is the current rectangles overlap with the last green box
    prev_score = 20; % min acceptable score
    for i = 1:size(boxes, 1) % for each box
        % Parameterize box
        x1 = boxes(i,1);        y1 = boxes(i,2);
        dx = boxes(i,3);        dy = boxes(i,4);
        x2 = boxes(i,1) + dx;   y2 = boxes(i,2) + dy;
        x_c = x1 + 0.5*dx - 0.5*size(frame,2); 
        y_c = y1 + 0.5*dy - 0.5*size(frame,1);
        box_depth = pt_cloud(y1:y2,x1:x2,3);
        distance = mean(box_depth(:),'omitnan');  % avg distance to box
        frame_info = [x1 y1 dx dy distance f]; % store info on each box
        curr_score = rectint([x1 y1 dx dy], rect_pred); % calculate overlap
        box_str = sprintf('D: %d m C: %dx%d px', round(distance), round(x_c), round(y_c));

        % Green Box (tracking)
        % Indicates same car is being detected and tracked
        if curr_score >= prev_score
            frame = insertObjectAnnotation(frame,'rectangle',boxes(i, :), ...
                box_str, 'FontSize',12, 'LineWidth',4,'Color', 'green');
            frame = insertText(frame,text_location,'Tracking...', ...
                'TextColor','green', 'FontSize', 40, 'BoxOpacity', 0);
            box_count = box_count + 1;

        % Red Box (ignored)
        % Outlier detections or false alarms
        else
            frame = insertObjectAnnotation(frame,'rectangle',boxes(i, :), ...
                box_str, 'FontSize',12, 'LineWidth',4, 'Color', 'red');
        end
        prev_score = curr_score;
    end

    %% Predict the corner of the next rectagle
    data = vertcat(data, frame_info); % data structure for all boxe info
    s = size(data, 1);
    if s > n_bins % need n frames first
        % Queue with n_bins rows and [X, Y, dX, dY, distance] as columns
        queue(:, :) = data((s - n_bins + 1):s,1:5);

        if size(boxes, 1) == 0  % predict if no box detected
            pred = sum(repmat(W.',1, size(queue,2)) .* queue);  % weighted sum
            rect_pred = pred(1:4); % predicted rectangle
            x_c = pred(1)+ 0.5*pred(3) - 0.5*size(frame,2);
            y_c = pred(2)+ 0.5*pred(4) - 0.5*size(frame,1);

            % Prediction Error (between 0 and 1)
            min_area = min(frame_info(3)*frame_info(4), rect_pred(3)*rect_pred(4));
            overlap_err = 1 - rectint(frame_info(1, 1:4), rect_pred) / min_area;
            dist_err = abs(pred(5) - data(s, 5))/max(pred(5), data(s, 5));
            results(f, 1:7) = [pred overlap_err dist_err];  % store results

            box_str = sprintf('D: %d m C: %dx%d px', round(distance), round(x_c), round(y_c));
            err_str = sprintf('Prediction Error: %0.2f percent', 100*(dist_err+overlap_err));

            % Blue Box (predicted)
            % If no car detected, but prediction seems accurate
            if overlap_err < 0.3
                pred_count = pred_count + 1;
                frame = insertObjectAnnotation(frame,'rectangle', ...
                    rect_pred, box_str,'FontSize',12, 'LineWidth',4, 'Color', 'cyan');
                frame = insertText(frame,text_location,'Predicting...', ...
                    'TextColor','cyan', 'FontSize', 40, 'BoxOpacity', 0);
                frame = insertText(frame,[200 700], err_str, ...
                    'TextColor','white', 'FontSize', 16, 'BoxOpacity', 0);
            end
        end
    end
    step(vid_player,frame)
    writeVideo(vid_writer,frame)
end

toc
release(detector)
close(vid_writer)
release(vid_player)

%% Results
pred_count
box_count
box_count+pred_count

% Distance to car plot
figure
plot(data(:,5))
xlabel('Frame'); ylabel('Distance to car ahead (m)')
ylim([15 35]); title('Following Distance');
