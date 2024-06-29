function [ccccc] = processXOZrailing(img)
%Remove small objects
%1Remove small objects
cc = bwmorph(img,'clean');
ccc = bwareaopen(cc, 4); 
cccc = bwmorph(ccc,'bridge'); 
%2Dilation Erosion (bwmorph Closing)
ccccc = bwmorph(cccc,'close');
figure
imshow(ccccc)
end