function tracklets = labels_read (filename)

% read files in directory and concatenate tracklets
if isdir(filename)
  dirname = filename;
  files = dir([dirname '/*.txt']);
  tracklets = [];
  for i=1:length(files)
    tracklets_curr = read_file([dirname '/' files(i).name]);
    for j=1:length(tracklets_curr)
      if length(tracklets)<j
        tracklets{j} = tracklets_curr{j};
      else
        tracklets{j} = [tracklets{j} tracklets_curr{j}];
      end
    end
  end
  
% read a single file
else
  tracklets = read_file(filename);
end

function tracklets = read_file (filename)

% parse input file
fid = fopen(filename);
try
  C = textscan(fid, '%d %d %s %d %d %f %f %f %f %f %f %f %f %f %f %f %f %f');
catch
  keyboard;
  error('This file is not in KITTI tracking format or the file does not exist.');
end
fclose(fid);

% for all objects do
tracklets = {};
nimages = max(C{1});
for f=0:nimages
  objects = [];
  idx = find(C{1}==f);  
  for i = 1:numel(idx)
    o=idx(i);

    % extract label, truncation, occlusion
    lbl = C{3}(o);                   % for converting: cell -> string
    objects(i).frame      = f;       % frame
    objects(i).id         = C{2}(o); % tracklet id
    objects(i).type       = lbl{1};  % 'Car', 'Pedestrian', ...
    objects(i).truncation = C{4}(o); % truncated pixel ratio ([0..1])
    objects(i).occlusion  = C{5}(o); % 0 = visible, 1 = partly occluded, 2 = fully occluded, 3 = unknown
    objects(i).alpha      = C{6}(o); % object observation angle ([-pi..pi])

    % extract 2D bounding box in 0-based coordinates
    objects(i).x1 = C{7}(o); % left
    objects(i).y1 = C{8}(o); % top
    objects(i).x2 = C{9}(o); % right
    objects(i).y2 = C{10}(o); % bottom

    % extract 3D bounding box information
    objects(i).h    = C{11} (o); % box width
    objects(i).w    = C{12}(o); % box height
    objects(i).l    = C{13}(o); % box length
    objects(i).t(1) = C{14}(o); % location (x)
    objects(i).t(2) = C{15}(o); % location (y)
    objects(i).t(3) = C{16}(o); % location (z)
    objects(i).ry   = C{17}(o); % yaw angle
    objects(i).score = C{18}(o); % score
  end
  tracklets{f+1} = objects;
end
