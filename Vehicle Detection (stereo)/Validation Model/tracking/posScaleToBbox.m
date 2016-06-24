function bbox = posScaleToBbox(object)
% inverse of bboxToPosScale.m

u1 = object(:,1)-object(:,3)/2;
v1 = object(:,2)-object(:,4)/2;
u2 = object(:,1)+object(:,3)/2;
v2 = object(:,2)+object(:,4)/2;

bbox = [u1 v1 u2 v2 object(:,5:end)];
