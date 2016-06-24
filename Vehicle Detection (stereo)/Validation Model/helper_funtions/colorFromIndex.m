function [col,style] = colorFromIndex(idx)

idx = mod(idx,19);

s = 0.8;
switch idx
  case 0,  col = s*[0.0 0.0 0.0]; style = '-';
  case 1,  col = s*[0.0 0.0 1.0]; style = '--';
  case 2,  col = s*[0.0 1.0 0.0]; style = ':';
  case 3,  col = s*[0.0 1.0 1.0]; style = '-.';
  case 4,  col = s*[1.0 0.0 0.0]; style = '-';
  case 5,  col = s*[1.0 0.0 1.0]; style = '--';
  case 6,  col = s*[1.0 1.0 0.0]; style = ':';
  case 7,  col = s*[0.0 1.0 0.5]; style = '-.';
  case 8,  col = s*[0.0 0.5 1.0]; style = '-';
  case 9,  col = s*[0.0 0.7 0.7]; style = '-';
  case 10, col = s*[0.5 0.0 1.0]; style = '-';
  case 11, col = s*[1.0 0.0 0.5]; style = '-';
  case 12, col = s*[0.7 0.0 0.7]; style = '-';
  case 13, col = s*[0.5 1.0 0.0]; style = '-';
  case 14, col = s*[1.0 0.5 0.0]; style = '-';
  case 15, col = s*[0.7 0.7 0.0]; style = '-';
  case 16, col = s*[0.5 1.0 1.0]; style = '-';
  case 17, col = s*[1.0 0.5 1.0]; style = '-';
  case 18, col = s*[1.0 1.0 0.5]; style = '-';
end
