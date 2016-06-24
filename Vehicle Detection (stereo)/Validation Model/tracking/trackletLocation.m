function dist = trackletLocation(object,tracklet,I)

% intersection over union
bbox1 = posScaleToBbox(object);
bbox2 = posScaleToBbox(tracklet(end,2:5));
dist_geo = 1.0-boxoverlap(bbox1,bbox2)';

for i=1:size(object,1)
  if dist_geo(i)<0.7
    [c,d] = correlate_full(tracklet(end,1:5),[tracklet(end,1)+1 object(i,:)],I);
    if d<0.2
      dist_corr(i) = 1.0-c;
    else
      dist_corr(i) = inf;
    end
  else
    dist_corr(i) = inf;
  end
end

dist = dist_geo.*dist_corr;
idx = dist_corr>0.4 | dist_geo>0.7;
dist(idx) = inf;
