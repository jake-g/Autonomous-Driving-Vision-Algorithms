function [c,d,u1,v1,C] = xcorr(T,S)
% u1,v1 = search area pixel where upper left template corner is anchored

if size(T,1)>size(S,1) || size(T,2)>size(S,2)
  c  = -1;
  d  = 1;
  u1 = 0;
  v1 = 0;
  return;
end

% correlate
C = normxcorr2(T,S);

% crop
m1 = floor((size(C,1)-(size(S,1)-size(T,1)))/2);
m2 = floor((size(C,2)-(size(S,2)-size(T,2)))/2);
c  = max(max(C(m1+1:end-m1,m2+1:end-m2)));

% find bbox
[i,j] = find(C==c,1,'first');
u1 = j-size(T,2)+1;
u2 = j;
v1 = i-size(T,1)+1;
v2 = i;

% compute SAD
if u1<1 || u2>size(S,2) || v1<1 || v2>size(S,1)
  d = 1;
else
  D = imabsdiff(T,S(v1:v2,u1:u2));
  d = double(mean(D(:)))/256.0;
end
