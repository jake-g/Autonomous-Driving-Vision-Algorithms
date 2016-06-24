%****************************************************************************
% Creates annotation for frame
% University of Washington
% EcoCAR 3 ADAS Team
% Jake Garrison
%*****************************************************************************

function box_str = annotate_box(box, frame_w, frame_h)
%annotate_box returns str for box annotation

    x = box(1); y = box(2);
    w = box(3); h = box(4);
    x_c = x + w/2 - 0.5 * frame_w; 
    y_c = y + h/2 - 0.5 * frame_h;

    % Annotate Stopsign
    box_str = sprintf('Dim: %dx%d px Center: %dx%d px', ...
        round(w), round(h), round(x_c), round(y_c));
end
