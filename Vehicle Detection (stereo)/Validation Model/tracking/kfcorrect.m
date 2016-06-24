function s = kfcorrect(s)

% x = Ax + w, w ~ N(0,Q)
% z = Hx + v, v ~ N(0,R)

K   = (s.P*s.H')/(s.H*s.P*s.H'+s.R);
s.x = s.x + K*(s.z-s.H*s.x);
s.P = s.P - K*s.H*s.P;
