function detections = convertFromKITTI (detections_kitti,model_type) 

% convert from KITTI format
for k=1:length(detections_kitti)

  % get bounding box
  bbox = [];
  if ~isempty(detections_kitti{k})
    bbox(:,1) = [detections_kitti{k}.x1]';
    bbox(:,2) = [detections_kitti{k}.y1]';
    bbox(:,3) = [detections_kitti{k}.x2]';
    bbox(:,4) = [detections_kitti{k}.y2]';
    bbox(:,5) = [detections_kitti{k}.alpha]';
    bbox(:,6) = [detections_kitti{k}.score]';
    
    % remove low-scoring and non model_type detections
    idx_score = bbox(:,6)>0;
    idx_type = compareModelType(detections_kitti{k},model_type);
    bbox = bbox(idx_score & idx_type,:);
  end

  % set detections
  detections{k}.bbox  = bbox;
  detections{k}.frame = k-1;
end

function idx_type = compareModelType (detections,model_type)

idx_type = zeros(length(detections),1);
for i=1:length(detections)
  if strcmp(detections(i).type,model_type)
    idx_type(i) = true;
  end
end
