function [c,d] = correlate_full(t1,t2,I)

% compute bounding boxes
bbox_tmp = round(posScaleToBbox(t1(2:5)));
bbox_img = round(posScaleToBbox(t2(2:5)));

% enlarge search area by 25%
m = ceil(0.25*t2(4));
bbox_img(1) = max(bbox_img(1)-m,1);
bbox_img(2) = max(bbox_img(2)-m,1);
bbox_img(3) = min(bbox_img(3)+m,size(I{t2(1)},2));
bbox_img(4) = min(bbox_img(4)+m,size(I{t2(1)},1));

% clip template
bbox_tmp(1) = max(bbox_tmp(1),1);
bbox_tmp(2) = max(bbox_tmp(2),1);
bbox_tmp(3) = min(bbox_tmp(3),size(I{t1(1)},2));
bbox_tmp(4) = min(bbox_tmp(4),size(I{t1(1)},1));

% extract template and search area
T = I{t1(1)}(bbox_tmp(2):bbox_tmp(4),bbox_tmp(1):bbox_tmp(3));
S = I{t2(1)}(bbox_img(2):bbox_img(4),bbox_img(1):bbox_img(3));

% crop template upper and lower part by 15 %
m = round(0.15*size(T,1));
T = T(m+1:end-m,:);

% crop template left and right part by 15 %
m = round(0.15*size(T,2));
T = T(:,m+1:end-m);

% compute correlation score
[c,d] = xcorr(T,S);
