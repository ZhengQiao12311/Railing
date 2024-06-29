function [ddddd] = processXOYcurb(img_curb)
%Dilation Erosion (bwmorph Closing) 
dd = bwmorph(img_curb,'bridge'); 
ddd = bwmorph(dd,'close');
dddd = bwmorph(ddd,'clean');

[L, num] = bwlabel(dddd);
stats = regionprops(L,'Area');
areas = [stats.Area];
P = max(areas(:));
P = round(P *0.2);
ddddd = bwareaopen(dddd,P);
figure
imshow(ddddd)
end