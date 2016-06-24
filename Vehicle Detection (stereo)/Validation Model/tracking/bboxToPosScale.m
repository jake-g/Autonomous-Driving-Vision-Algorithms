function object = bboxToPosScale(bbox)
% convert bounding box in (u1,v1,u2,v2) coordinates
% to (cu,cv,w,h) representation (center+size)

if isempty(bbox)
  object = [];
  return;
end

u = (bbox(:,1)+bbox(:,3))/2;
v = (bbox(:,2)+bbox(:,4))/2;
w = bbox(:,3)-bbox(:,1);
h = bbox(:,4)-bbox(:,2);

object = [u v w h bbox(:,5:end)];
