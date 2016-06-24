function dist = trackletAffinity(t1,t2,I,show)

% crop tracks to maximum length of n frames
n  = 10;
t1 = t1(end-min(n,size(t1,1))+1:end,:);
t2 = t2(1:min(n,end),:);

% compute distance measures
dist_geo = distGeometry(t1,t2,0);
if dist_geo>=1.5
  dist = inf;
else
  dist_cor = distCorrelation(t1,t2,I,show);
  if dist_cor<=0.35
    dist = dist_geo*dist_cor;
  else
    dist = inf;
  end
end

if show
  fprintf('dist_geo: %2.2f, dist_cor: %2.2f, dist: %2.2f\n',dist_geo,dist_cor,dist);
  keyboard;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = distGeometry(t1,t2,show)

% scale tracklets (using mean bbox width of t1 and t2)
scale = max(min(mean(t1(:,4)),mean(t2(:,4))),20);
t1(:,2:5) = t1(:,2:5)/scale;
t2(:,2:5) = t2(:,2:5)/scale;

n = [size(t1,1) size(t2,1)];
t{1} = t1;
t{2} = t2;
tt = [t1;t2]; % joint trajectory

if show
  figure;
  for i=1:4
    subplot(2,2,i),plot(tt(:,1),tt(:,i+1),'xb');
  end
end

for i=1:4
  for j=1:2
    H = [t{j}(:,1).*t{j}(:,1) t{j}(:,1) ones(n(j),1)];
    HtH = H'*H;
    HtH(1,1) = HtH(1,1)+2000;
    x = t{j}(:,i+1);
    if rank(HtH)<3
      d = inf;
      return;
    end
    y{j}(i,:) = (HtH\(H'*x))';
  end
end

det = [];
pred = [];
for i=1:4
  for j=1:2
    if j==1
      z = t2(1,1);
      det(i,j)  = t2(1,i+1);
      pred(i,j) = y{j}(i,1)*z.*z+y{j}(i,2)*z+y{j}(i,3);
      if show
        x = t1(1,1):t2(1,1);
        c = [1 0 0];
        subplot(2,2,i); hold on;
        plot(z,det(i,j),'s','Color',c);
        plot(z,pred(i,j),'o','Color',c);
      end
    else
      z = t1(end,1);
      det(i,j)  = t1(end,i+1);
      pred(i,j) = y{j}(i,1)*z.*z+y{j}(i,2)*z+y{j}(i,3);
      if show
        x = t1(end,1):t2(end,1);
        c = [0 0.8 0];
        subplot(2,2,i); hold on;
        plot(z,det(i,j),'s','Color',c);
        plot(z,pred(i,j),'o','Color',c);
      end
    end
    if show
      plot(x,y{j}(i,1)*x.*x+y{j}(i,2)*x+y{j}(i,3),'-','Color',c);
    end
  end
end

du1 = abs(det(1,1)-pred(1,1));
du2 = abs(det(1,2)-pred(1,2));
dd(1) = det(3,1)/det(3,2);
dd(2) = det(4,1)/det(4,2);
dd(dd<1) = 1./dd(dd<1);
dw = max(dd(1)-1.5,0);
dh = max(dd(2)-1.5,0);

d = 0.8*min(du1,du2) + 0.2*mean([du1,du2]) + dw + dh;

if show
  fprintf('d: %2.2f, du1: %2.2f, du2: %2.2f, dw: %2.2f, dh: %2.2f\n',d,du1,du2,dw,dh);
  keyboard;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = distCorrelation(t1,t2,I,show)

% get indices of non inter-/extrapolated boxes 
i1 = find(t1(:,end)~=0);
i2 = find(t2(:,end)~=0);

k=1;
c=[]; d=[];
for i=max(length(i1),1)-2:length(i1)
  for j=1:min(3,length(i2))
    [c1,duv1] = correlate(t1(i1(i),1:5),t2(i2(j),1:5),I,show);
    [c2,duv2] = correlate(t2(i2(j),1:5),t1(i1(i),1:5),I,show);
    dd(k) = norm(duv1+duv2);
    
    % consistency check
    if dd(k)<0.15
      c(k) = max(c1,c2);
    else
      c(k) = 0;
    end
    k=k+1;
  end
end

d = 1-max(c);
