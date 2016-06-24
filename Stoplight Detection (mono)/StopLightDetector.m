clear all; close all; clc;

%% Setup
vidReader = vision.VideoFileReader('U:\EcoCar\StoplightColorCycle.mp4');
vidReader.VideoOutputDataType = 'double';

diskElem = strel('disk',5,4);

shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor', ...
    'Custom','CustomBorderColor', double([0.0 1.0 0.0]));
    
%Create TextInserter object to insert # of objects detected
hTextIns = vision.TextInserter('%d','Location',[20 20],'Color',...
    [255 255 0],'FontSize',30);

vidPlayer = vision.DeployableVideoPlayer;

%% Run the algorithm in a loop
while ~isDone(vidReader)
    
    vidFrame = step(vidReader);
    
    [Ibw, maskedLights] = lightMask(vidFrame);
    
    [Ibw, maskedRed] = redLightMask(maskedLights);  
    
    bwOpen = imclose(Ibw,diskElem);
    
    [centers, radii, metric] = imfindcircles(bwOpen, [4 15]);

    position = [0;0;0];
    
    if (~isempty(radii))
        position = int32([centers(:,1) centers(:,2) radii]);
    end
    
    Ishape = step(shapeInserter, vidFrame, position);
    
    % Insert a string of number of objects detected in the video frame.
    numObj = length(radii);
    
    Itext = step(hTextIns,Ishape,int32(numObj));
    
    %Play in the video player
    step(vidPlayer, Itext);

    release(shapeInserter)
end

%% Cleanup
release(vidReader)
release(hTextIns)
release(vidPlayer)
release(shapeInserter)
