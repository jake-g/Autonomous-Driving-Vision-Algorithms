clear all; close all;

%% Set Up
% Set Paths
%seq_dir = '../../datastore/kitti/2011_09_26/2011_09_26_drive_0056/';
%img_dir = [seq_dir 'image_02/data'];
%img_ext = '.png';
seq_dir = '../../datastore/CarDetectStereo/';
img_dir = [seq_dir 'mono'];
img_ext = '.jpg';
obj_dir = [img_dir '_obj'];
out_dir = [img_dir '_results'];
track_file = [img_dir '_tracking_results.txt'];

% save tracking results
save_to_file = 0;   % 1 = SAVE

% load model
model_file = 'models/car_2_2012_10_04-20_13_57_model.mat';
model_type = 'Car';
model_bins = 16;
intervals = 3; % faster, less accurate (default: 10)

% image, object and output directories
addpath('detection');
addpath('tracking');
addpath('helper_funtions');
warning off MATLAB:MKDIR:DirectoryExists;
mkdir(obj_dir);
mkdir(out_dir);

%% Rename images (optional)
% Image frames need to be named as 10 digit numbers
% Example: 0000000179.jpg
% img_rename(img_dir, img_ext)

%% Detection
disp('Detecting...')
disp('this step takes 5-10 sec per image....be patient')
% load object detector model, binning refers to the orientations
load(model_file);
binning = linspace(-pi+pi/(model_bins/2),pi,model_bins);

% process all images
figure;
files = dir([img_dir '/*' img_ext]);
for i=1:length(files)
  fprintf('Processing: %s (%d/%d)\n',files(i).name,i,length(files));
  
  % load files
  img_file = [img_dir '/' files(i).name];
  obj_file = [obj_dir '/' files(i).name(1:end-4) '.txt'];
  im = imread(img_file);    % load image
  
  bbox = detect(im,model,intervals);  % detect objects
  
  % write in single file (tracking format)
  tracklets = [];
  for j=1:size(bbox,1)
    tracklets{1}(j).frame = str2num(files(i).name(1:end-4));
    tracklets{1}(j).id    = -1;
    tracklets{1}(j).type  = model_type;
    tracklets{1}(j).x1    = bbox(j,1);
    tracklets{1}(j).y1    = bbox(j,2);
    tracklets{1}(j).x2    = bbox(j,3);
    tracklets{1}(j).y2    = bbox(j,4);
    tracklets{1}(j).alpha = binning(bbox(j,5));
    tracklets{1}(j).score = bbox(j,6);
  end
  
  % save to file and display
  labels_write(tracklets,obj_file);
  clf; plot_bbox(im,bbox);
  refresh; pause(0.1);
end
fprintf('done!\n');

%% Tracking
disp('Tracking...')
% read detections in KITTI tracking format
detections_kitti = labels_read(obj_dir);

% convert from KITTI format to tracking format
detections = convertFromKITTI(detections_kitti,model_type);

% compute tracklets
tracklets = computeTracklets(detections, img_dir, img_ext);

% convert from tracking format to KITTI tracking format
tracklets_kitti = convertToKITTI(tracklets,length(detections_kitti),model_type);

% save to file and display
labels_write(tracklets_kitti, track_file);
fprintf('done!\n');

%% Results
disp('Showing results...')
tracklets = labels_read(track_file); % load tracklets

h = figure('Position',[10 100 1200 360]); axes('Position',[0 0 1 1]);
for i=1:length(tracklets)
  bbox = [];
  if ~isempty(tracklets{i})
    bbox(:,1) = [tracklets{i}.x1]';
    bbox(:,2) = [tracklets{i}.y1]';
    bbox(:,3) = [tracklets{i}.x2]';
    bbox(:,4) = [tracklets{i}.y2]';
    bbox(:,5) = [tracklets{i}.alpha]';
    bbox(:,6) = [tracklets{i}.score]';
    bbox(:,7) = [tracklets{i}.id]';
  end
  im = imread(sprintf(['%s/%010d', img_ext],img_dir,i-1));
  cla; plot_bbox(im,bbox);
  refresh; pause(0.05);
  if save_to_file
    export_fig(h,sprintf(['%s/%010d', img_ext],out_dir,i-1));
  end
end

fprintf('done!\n');