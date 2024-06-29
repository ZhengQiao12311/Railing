function [min_Height_fromcurb,median_Height_fromcurb, ...
    min_Height_fromfloor,median_Height_fromfloor, ...
    max_void,median_void,max_width,median_width,...
    Height_sum_fromfloor,Height_sum_fromcurb] = process2part ...
    (Railing,resolution,z_scanner,z_floor1)
% process within 1m
I = pointcloud2image_XOZ(Railing,Railing,resolution);
img = I;
% Remove small objects
[ccccc] = processXOZrailing(img);
% Count point to obtain width
[count,max_void,median_void,max_width,...
    median_width] = count2width(ccccc,z_scanner,z_floor1,resolution);
% Count the height of railing
[min_Height_fromcurb,median_Height_fromcurb, ...
min_Height_fromfloor,median_Height_fromfloor,curb_sum,...
Height_sum_fromfloor,Height_sum_fromcurb,x_sum] = count2height(ccccc,count,resolution);
% measure the width of curb
curb_sum = curb_sum (2:end);
median_curb = median(curb_sum);
height_curb = median_curb * resolution;
end