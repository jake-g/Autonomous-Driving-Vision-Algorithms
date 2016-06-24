function s = kfinit(object,std_process,std_measurement)

s.A      = eye(8);                     % system matrix
s.A(1,5) = 1;
s.A(2,6) = 1;
s.A(3,7) = 1;
s.A(4,8) = 1;
s.Q      = std_process^2*eye(8);       % process noise
s.H      = [eye(4) zeros(4,4)];        % observation matrix
s.R      = std_measurement^2*eye(4);   % measurement noise
s.x      = [object(1:4)'; zeros(4,1)]; % state
s.P      = 1000^2*eye(8);              % state covariance
