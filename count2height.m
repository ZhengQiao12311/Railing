function [min_Height_fromcurb,median_Height_fromcurb, ...
    min_Height_fromfloor,median_Height_fromfloor,curb_sum,...
    Height_sum_fromfloor,Height_sum_fromcurb,x_sum] = count2height(ccccc,count,resolution)
%Count the height of railing
B = ccccc;
S = size(count, 1);
x_sum = 0;
for i = 3:2:S
x = sum(count(1:i)) - 0.5*count(i);
x_sum = cat(1,x_sum,x);
end
x_sum = x_sum(2:end);
%count height at each void medium
k = size (x_sum,1);
Height_sum_fromfloor = 0;
Height_sum_fromcurb = 0;
curb_sum = 0;
for l = 1:k 
    Width = round(x_sum(l));
    [count1] = heightcount(B,Width);
    if length(count1) > 4 
     Height_fromfloor = sum(count1(3:end));
     Height_sum_fromfloor = cat(1,Height_sum_fromfloor,Height_fromfloor);
     Height_fromcurb = sum(count1(4:end));
     Height_sum_fromcurb = cat(1,Height_sum_fromcurb,Height_fromcurb);
     % count the curb to decide how to measure height
     curb1 = count1(3,1);
     curb_sum = cat(2,curb_sum,curb1);
     else
     end
end
Height_sum_fromfloor= Height_sum_fromfloor (2:end);
Height_sum_fromcurb= Height_sum_fromcurb (2:end);
median_Height_fromfloor = median(Height_sum_fromfloor) * resolution * 1000;
min_Height_fromfloor = min(Height_sum_fromfloor) * resolution * 1000;
median_Height_fromcurb = median(Height_sum_fromcurb) * resolution * 1000;
min_Height_fromcurb = min(Height_sum_fromcurb) * resolution * 1000;
end