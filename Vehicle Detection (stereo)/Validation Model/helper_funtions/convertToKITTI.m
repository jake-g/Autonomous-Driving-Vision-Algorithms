function tracklets_kitti = convertToKITTI(tracklets,num_frames,model_type)

for i=1:num_frames
  k=1;
  for j=1:length(tracklets)
    idx = find(tracklets{j}(:,1)==i);
    if ~isempty(idx)
      bbox = posScaleToBbox(tracklets{j}(idx,2:5));
      tracklets_kitti{i}(k).frame = i-1;
      tracklets_kitti{i}(k).id = j-1;
      tracklets_kitti{i}(k).type = model_type;
      tracklets_kitti{i}(k).x1 = bbox(1);
      tracklets_kitti{i}(k).y1 = bbox(2);
      tracklets_kitti{i}(k).x2 = bbox(3);
      tracklets_kitti{i}(k).y2 = bbox(4);
      tracklets_kitti{i}(k).alpha = tracklets{j}(idx,6);
      tracklets_kitti{i}(k).score = tracklets{j}(idx,7);
      k=k+1;      
    end
  end
end
