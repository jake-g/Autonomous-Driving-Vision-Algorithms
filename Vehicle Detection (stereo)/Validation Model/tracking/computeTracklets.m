function tracklets = computeTracklets(detection,img_dir, img_ext, tracking_benchmark)

% tracking_benchmark = 1: use KITTI tracking benchmark directory structure
% default: use KITTI RAW directory structure
if nargin<4
  tracking_benchmark = 0;
end

disp('STAGE 0: Loading images ...');

% pre-load images
first_frame = detection{1}.frame;
last_frame = detection{end}.frame;
for i=first_frame:last_frame
  if tracking_benchmark
    im = imread([img_dir '/' num2str(i,'%06d') img_ext]);
  else
    im = imread([img_dir '/' num2str(i,'%010d') img_ext]);
  end
  if length(size(im))==3
    im = rgb2gray(im);
  end
  I{i-first_frame+1} = im;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   STAGE 1                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tracklets  = [];
kfstate    = [];
active     = [];

% for all frames do
for i=1:length(detection)
  
  % output
  fprintf('STAGE 1: Processing frame %d/%d\n',i,length(detection));
  
  % extract bounding box
  bbox = detection{i}.bbox;
  
  % convert to object detection representation
  object = bboxToPosScale(bbox);
  
  % active tracklets
  idx_active = find(active);
  
  % if active tracklets exist => try to associate
  if ~isempty(idx_active)
    
    % dist matrix
    dist = zeros(length(idx_active),size(object,1));
    
    % predict state and compute distance to detections
    for j=1:length(idx_active)
      
      % index of this tracklet
      track_idx = idx_active(j);
      
      % predict state
      kfstate{track_idx} = kfpredict(kfstate{track_idx});
      
      % set tracklet row of dist matrix
      if size(object,1)>0
        dist(j,:) = trackletLocation(object(:,1:4),tracklets{track_idx},I);
      end
    end
    
    % gating + hungarian assignment
    dist(dist>0.2) = inf;
    assignment = assignmentoptimal(dist);
    
    % extend active tracklets
    for j=1:length(idx_active)
      
      % index of this tracklet
      track_idx = idx_active(j);
            
      % assigned object detection index
      obj_idx = assignment(j);
      
      % if a detection has been assigned => update state
      if obj_idx>0

        kfstate{track_idx}.z = object(obj_idx,1:4)';
        kfstate{track_idx}   = kfcorrect(kfstate{track_idx});
        tracklets{track_idx} = [tracklets{track_idx}; i kfstate{track_idx}.x(1:4)' object(obj_idx,5:end)];

      % if no detection has been assigned => deactivate
      else
        active(track_idx) = 0;
      end
    end
    
    % remove assigned detections from object list
    object(assignment(assignment>0),:) = [];
  end
  
  % add remaining detections as new tracks
  for j=1:size(object,1)
    
    tracklets{end+1} = [i object(j,:)];
    kfstate{end+1}   = kfinit(object(j,:),1,5);
    active(end+1)    = 1;
    
  end
end

% remove short tracklets (smaller than 3 frames)
if 1
  idx = [];
  for i=1:length(tracklets) 
    if size(tracklets{i},1)<3
      idx = [idx i];
    end
  end
  tracklets(idx) = [];
end

% add tracklet id
for i=1:length(tracklets)
  tracklets{i} = [tracklets{i} i*ones(size(tracklets{i},1),1)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   STAGE 2                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dist = inf*ones(length(tracklets));
for i=1:length(tracklets)
  
  % output
  fprintf('STAGE 2: Processing tracklet %d/%d\n',i,length(tracklets));
  
  for j=i+1:length(tracklets)
    
    % if non-successive or distance between tracklets too large
    if tracklets{i}(end,1)<tracklets{j}(1,1) && tracklets{j}(1,1)-tracklets{i}(end,1)<=20
      dist(i,j) = trackletAffinity(tracklets{i},tracklets{j},I,0);
    end
  end
end

% gating
dist(dist>0.2) = inf;

% hungarian assignment
assignment = assignmentoptimal(dist);

% link tracklets
tracklets_linked = [];
for i=1:length(assignment)
  
  % add tracklet if assignment valid
  if assignment(i)>=0
    tracklets_linked{end+1} = tracklets{i};
  end
  
  % linked tracklet
  k = assignment(i);
  while k>0
    
    obj1  = tracklets_linked{end}(end,1:end-1);
    obj2  = tracklets{k}(1,1:end-1);
    
    % interpolate between 2 tracklets
    if obj2(1)-obj1(1)>1
      alpha = ((1:obj2(1)-obj1(1)-1)/(obj2(1)-obj1(1)))';
      tracklet_ipol          = zeros(obj2(1)-obj1(1)-1,7);
      tracklet_ipol(:,1)     = obj1(1)+1:obj2(1)-1;
      tracklet_ipol(:,2:5)   = (1-alpha)*obj1(2:5)+alpha*obj2(2:5);
      tracklet_ipol(:,6:end) = ones(size(tracklet_ipol,1),1)*obj1(6:end);
      tracklets_linked{end} = [tracklets_linked{end}; ...
                               tracklet_ipol zeros(size(tracklet_ipol,1),1); ...
                               tracklets{k}];
                             
    % create new tracklet
    else
      tracklets_new = tracklets{k};
      tracklets_new(1:obj1(1)-obj2(1)+1,:) = [];
      tracklets_linked{end} = [tracklets_linked{end}; ...
                               tracklets_new];
    end
    k_new = assignment(k);
    assignment(k) = -1;
    k = k_new;
  end
end

% replace tracklets by tracklets linked in stage 2
tracklets = tracklets_linked;
