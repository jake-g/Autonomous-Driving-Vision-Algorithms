function bbox = detect (im,model,interval,thresh)

% set interval to use less scales (default: 10)
if nargin==3
  model.interval = interval;
end

% set threshold
if nargin==4
  params.thresh = thresh;
else
  params.thresh = -1;
end

% parameters for upscaled detection at horizon
% hard-coded to fit KITTI data
scale   = 2;
horizon = 190;
margin  = 40;

% first stage
pyra1 = featpyramid(im,model);
bbox1 = gdetect(pyra1,model,params.thresh);

% second stage
im2   = imresize(im(horizon-margin:horizon+margin,:,:),scale,'bilinear');
pyra2 = featpyramid(im2,model);
bbox2 = gdetect(pyra2,model,params.thresh);
bbox2(:,1:4)   = bbox2(:,1:4)/scale;
bbox2(:,[2 4]) = bbox2(:,[2 4])+(horizon-margin)-1;
bbox = [bbox1; bbox2];

% non-maximal-suppression
bbox = bbox(nms(bbox,0.2),:);
