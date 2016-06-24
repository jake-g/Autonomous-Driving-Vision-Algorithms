close all; clear; clc
%% Create video reader and video player objects
vr = vision.VideoFileReader('vippedtracking.avi');
vp = vision.DeployableVideoPlayer;

%% Create a people detector
peopleDetector = vision.PeopleDetector(...
    'UprightPeople_96x48',...
    'WindowStride',[6 6]);
k = 1;

%% Detect people using the people detector object
while(~isDone(vr))
    %% Get current frame
    I = step(vr);

    %% Detect people
    bboxes = step(peopleDetector,I);
    
    %% Annotate detected people
    I = insertShape(I,'rectangle',bboxes);
    step(vp,I)
    
    numPeople(k) = size(bboxes,1);
    k = k+1;
        
end

%% Clean up
release(vr)