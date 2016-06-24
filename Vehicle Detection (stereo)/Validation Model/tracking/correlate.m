function [c,duv] = correlate(t1,t2,I,show)

% compute bounding boxes
bbox_tmp = round(posScaleToBbox(t1(2:5)));
bbox_img = round(posScaleToBbox(t2(2:5)));

% extract template
bbox_tmp(1) = max(bbox_tmp(1),1);
bbox_tmp(2) = max(bbox_tmp(2),1);
bbox_tmp(3) = min(bbox_tmp(3),size(I{t1(1)},2));
bbox_tmp(4) = min(bbox_tmp(4),size(I{t1(1)},1));

% extract search area (enlarge by 30%)
m = ceil(0.3*t2(4));
bbox_img(1) = max(bbox_img(1)-m,1);
bbox_img(2) = max(bbox_img(2)-m,1);
bbox_img(3) = min(bbox_img(3)+m,size(I{t2(1)},2));
bbox_img(4) = min(bbox_img(4)+m,size(I{t2(1)},1));

% width
width = bbox_img(3)-bbox_img(1);

% extract template and search area
T = I{t1(1)}(bbox_tmp(2):bbox_tmp(4),bbox_tmp(1):bbox_tmp(3));
S = I{t2(1)}(bbox_img(2):bbox_img(4),bbox_img(1):bbox_img(3));

% scale template to object scale (+/- 15 %)
c = 0; duv = [inf inf];
for scale = [0.9 1.0 1.1]*t2(5)/t1(5)
  
  % crop template upper and lower part by 15 %
  m_crop = round(0.15*size(T,1));
  Ts = T(m_crop+1:end-m_crop,:);
  
  % rescale template (doesn't affect upper-left corner)
  Ts = imresize(Ts,scale);

  % compute correlation scores for left and right 66%
  m  = round(size(Ts,2)*0.66);
  if any(size(Ts(:,1:m))+1>=size(S))
    continue;
  end
  [c1,d1,u1,v1,C1] = xcorr(Ts(:,1:m),S);
  [c2,d2,u2,v2,C2] = xcorr(Ts(:,end-m:end),S);

  if c1>c2
    if d1<0.15 && c1>c
      c = c1;
      u = u1;
      v = v1-m_crop;
      duv = (bbox_img(1:2)+[u v]-bbox_tmp(1:2))/width;
    end
  else
    if d2<0.15 && c2>c
      c = c2;
      u = u2-(size(Ts,2)-m); % account for 66%
      v = v2-m_crop;
      duv = (bbox_img(1:2)+[u v]-bbox_tmp(1:2))/width;
    end
  end
  
  if show
    fprintf('%d%d -> scale: %2.2f, c1: %2.2f, c2: %2.2f, d1: %2.2f, d2: %2.2f\n',t1(1),t2(1),scale,c1,c2,d1,d2);
    if 0
      figure;
      subplot(2,2,1);imagesc(Ts);
      subplot(2,2,2);imagesc(S);
      subplot(2,2,3);imagesc(C1);
      subplot(2,2,4);imagesc(C2);
      colormap gray;
      keyboard;
    end
  end
end
