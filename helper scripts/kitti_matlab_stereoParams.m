%% Camera 1
IntrinsicMatrix =  [978.6977         0         0; 
                           0  971.7435         0; 
                    691.0000  250.7222    1.0000];
RadialDistortion = [ -0.3793    0.2121   -0.0761];
TangentialDistortion = [0.0009    0.0019];

camera1 = cameraParameters( ...
    'IntrinsicMatrix',IntrinsicMatrix, ...
    'RadialDistortion',RadialDistortion, ...
    'TangentialDistortion', TangentialDistortion)


%% Camera 2
IntrinsicMatrix =  [989.2043         0         0; 
                           0  983.2048         0; 
                    703.0000  262.6538    1.0000];
RadialDistortion = [-0.3721    0.1944   -0.0631];
TangentialDistortion = [-0.0001   -0.0001];

camera2 = cameraParameters( ...
    'IntrinsicMatrix',IntrinsicMatrix, ...
    'RadialDistortion',RadialDistortion, ...
    'TangentialDistortion', TangentialDistortion)

%% Stereo Params
% Rotation and Translation relative to camera 1
RotationMatrix = [0.9993    0.0183   -0.0313;
                 -0.0186    0.9998   -0.0082;
                  0.0311    0.0087    0.9995];
TranslationVector = [   -0.5370    0.0056   -0.0120];

stereoParams = stereoParameters(camera1,camera2,RotationMatrix,TranslationVector)
save('stereoParams_kitti', 'stereoParams')


%% Original Kitti cam params
% calib_time: 09-Jan-2012 13:59:33
% corner_dist: 9.950000e-02
% S_00: 1.392000e+03 5.120000e+02
% K_00: 9.786977e+02 0.000000e+00 6.900000e+02 0.000000e+00 9.717435e+02 2.497222e+02 0.000000e+00 0.000000e+00 1.000000e+00
% D_00: -3.792567e-01 2.121203e-01 9.182571e-04 1.911304e-03 -7.605535e-02
% R_00: 1.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00
% T_00: -1.850372e-17 6.938894e-17 -7.401487e-17
% S_rect_00: 1.226000e+03 3.700000e+02
% R_rect_00: 9.999280e-01 8.085985e-03 -8.866797e-03 -8.123205e-03 9.999583e-01 -4.169750e-03 8.832711e-03 4.241477e-03 9.999520e-01
% P_rect_00: 7.070912e+02 0.000000e+00 6.018873e+02 0.000000e+00 0.000000e+00 7.070912e+02 1.831104e+02 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00
% S_01: 1.392000e+03 5.120000e+02
% K_01: 9.892043e+02 0.000000e+00 7.020000e+02 0.000000e+00 9.832048e+02 2.616538e+02 0.000000e+00 0.000000e+00 1.000000e+00
% D_01: -3.720803e-01 1.944116e-01 -1.077099e-04 -9.031379e-05 -6.314998e-02
% R_01: 9.993424e-01 1.830363e-02 -3.129928e-02 -1.856768e-02 9.997943e-01 -8.166432e-03 3.114337e-02 8.742218e-03 9.994767e-01
% T_01: -5.370000e-01 5.591661e-03 -1.200541e-02
% S_rect_01: 1.226000e+03 3.700000e+02
% R_rect_01: 9.996960e-01 -1.040961e-02 2.234966e-02 1.031552e-02 9.999375e-01 4.321301e-03 -2.239324e-02 -4.089439e-03 9.997409e-01
% P_rect_01: 7.070912e+02 0.000000e+00 6.018873e+02 -3.798145e+02 0.000000e+00 7.070912e+02 1.831104e+02 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00
% S_02: 1.392000e+03 5.120000e+02
% K_02: 9.591977e+02 0.000000e+00 6.944383e+02 0.000000e+00 9.529324e+02 2.416793e+02 0.000000e+00 0.000000e+00 1.000000e+00
% D_02: -3.725637e-01 1.979803e-01 1.799970e-04 1.250593e-03 -6.608481e-02
% R_02: 9.999805e-01 -4.971067e-03 -3.793081e-03 4.954076e-03 9.999777e-01 -4.475856e-03 3.815246e-03 4.456977e-03 9.999828e-01
% T_02: 6.030222e-02 -1.293125e-03 5.900421e-03
% S_rect_02: 1.226000e+03 3.700000e+02
% R_rect_02: 9.999019e-01 1.307921e-02 -5.015634e-03 -1.307809e-02 9.999144e-01 2.561203e-04 5.018555e-03 -1.905003e-04 9.999874e-01
% P_rect_02: 7.070912e+02 0.000000e+00 6.018873e+02 4.688783e+01 0.000000e+00 7.070912e+02 1.831104e+02 1.178601e-01 0.000000e+00 0.000000e+00 1.000000e+00 6.203223e-03
% S_03: 1.392000e+03 5.120000e+02
% K_03: 9.035972e+02 0.000000e+00 6.979803e+02 0.000000e+00 8.979356e+02 2.392935e+02 0.000000e+00 0.000000e+00 1.000000e+00
% D_03: -3.726025e-01 1.973869e-01 -5.746215e-04 7.444947e-05 -6.699658e-02
% R_03: 9.994995e-01 1.667420e-02 -2.688514e-02 -1.673122e-02 9.998582e-01 -1.897204e-03 2.684969e-02 2.346075e-03 9.996367e-01
% T_03: -4.747879e-01 5.631988e-03 -5.233709e-03
% S_rect_03: 1.226000e+03 3.700000e+02
% R_rect_03: 9.998007e-01 -8.628355e-03 1.800315e-02 8.666473e-03 9.999604e-01 -2.040364e-03 -1.798483e-02 2.195981e-03 9.998358e-01
% P_rect_03: 7.070912e+02 0.000000e+00 6.018873e+02 -3.334597e+02 0.000000e+00 7.070912e+02 1.831104e+02 1.930130e+00 0.000000e+00 0.000000e+00 1.000000e+00 3.318498e-03
