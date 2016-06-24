clear all; close all;

% settings
rootdir = '/home/uw/Desktop/ADAS-repo/datastore/CarDetectStereo/';
img_dir = [rootdir '/test'];

% load model
model_file = 'models/car_2_2012_10_04-20_13_57_model.mat';
model_type = 'Car';
model_bins = 16;
intervals = 3; % faster, less accurate (default: 10)
addpath('lsvm4');

% load object detector model, binning refers to the orientations
load(model_file);
binning = linspace(-pi+pi/(model_bins/2),pi,model_bins);

% process all images
figure;
files = dir([img_dir '/*.jpg']);
for i=1:length(files)
  
  fprintf('Processing: %s (%d/%d)\n',files(i).name,i,length(files));
  img_file = [img_dir '/' files(i).name];     % filename
  im = imread(img_file);     % load image and
  bbox = detect(im,model,intervals);   %   detect objects

  clf; plot_bbox(im,bbox);
  refresh; pause(0.01);
end

fprintf('done!\n');
