function s = kfpredict(s)

% x = Ax + w, w ~ N(0,Q)
% z = Hx + v, v ~ N(0,R)

s.x = s.A*s.x;
s.P = s.A*s.P*s.A' + s.Q;

if s.x(3)<20
  s.x(3) = 20;
end

if s.x(4)<20
  s.x(4) = 20;
end
