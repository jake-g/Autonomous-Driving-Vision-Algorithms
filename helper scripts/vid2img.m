%% Extracting & Saving of frames from a Video file through Matlab Code
clc; close all; clear all;

input = '../datastore/StopSignDetect/stopsign_drive2.mp4';
output = '../datastore/StopSignDetect/frames2';

mov = VideoReader(input);
if ~exist(output, 'dir')
    mkdir(output);
end

n_frames = mov.NumberOfFrames;
frames_written = 0;
for i = 1 : n_frames
    f = read(mov, i);    
    opBaseFileName = sprintf('%010d.png', i);
    filename = fullfile(output, opBaseFileName);
    imwrite(f, filename, 'png');  
    str = sprintf('Wrote frame %4d of %d.', i, n_frames);
    disp(str);
    frames_written = frames_written + 1;
end    
str = sprintf('Wrote %d frames to folder "%s"',frames_written, output);
disp(str);