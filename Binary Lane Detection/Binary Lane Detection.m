% UW ADAS Activity 3

clear all; close all; clc;

vidIn = VideoReader('videos/rawActivity3Video.mp4');
vidOut = VideoWriter('videos/activity3_UW');

minArea = 2000;
ROI = [300 830]; % road region

% feedback vars for scaling thresh
prev_W = 28812;     % white pixel count for first frame
max_diff = 10000;   % arbitrary value
c = .03;            % confidence scalars

open(vidOut)
thresh = 0.7;

while hasFrame(vidIn)
    I = readFrame(vidIn);
    HSV = rgb2hsv(I);
    BW = im2bw(HSV(:,:,3), thresh);     % convert to binary
    BW_XOR = bwareaopen(BW,minArea);  % remove white noise with area < minArea

    mask = false(size(BW)); % black mask
    mask(ROI(1):ROI(2), :) = 1; % set ROI to white
    BW_AND = mask & BW_XOR; s% combine ROI mask with frame
    
    curr_W = sum(sum(BW_AND)); % get current count of white pixels
    diff = prev_W - curr_W; % compare change in count
    if(diff > 0 && thresh > .5) % if image 'brightens'
        thresh = thresh - diff/max_diff*c; % decrease threshold
    end
    prev_W = curr_W; % update previous pixel counts   
    
    RGB = 255*uint8(cat(3, BW_AND, BW_AND, BW_AND));   % convert to RGB

%     imshow(RGB);
    writeVideo(vidOut, RGB);

%     break
end
close(vidOut)
