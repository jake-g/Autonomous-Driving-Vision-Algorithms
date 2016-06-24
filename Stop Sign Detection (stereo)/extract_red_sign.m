%****************************************************************************
% Extracts Stopsign based off color
% University of Washington
% EcoCAR 3 ADAS Team
% Jake Garrison
%*****************************************************************************

function BW = extract_red_sign(input)

I = rgb2hsv(input);

% HSV Threshhold
h_min = 0.936; h_max = 0.043;
s_min = 0.244; s_max = 1.000;
v_min = 0.205; v_max = 1.000;

% Mask based off HSV threshold
BW = ( (I(:,:,1) >= h_min) | (I(:,:,1) <= h_max) ) & ...
    (I(:,:,2) >= s_min ) & (I(:,:,2) <= s_max) & ...
    (I(:,:,3) >= v_min ) & (I(:,:,3) <= v_max);

% Remove white regions smaller than 70px
BW = bwareaopen(BW , 70); % remove noise
BW = imclose(BW, strel('disk', 15));     % fill in blob
