%% Import las and picture show
tStart = tic;  
lasReader = lasFileReader('Railing1_median_045.las');%check the correct file
PtCloud_railing = readPointCloud(lasReader);
%imput parameter
resolution = 0.003;
x_scanner = 0;
y_scanner = 0;
z_scanner = 92.74125;% from scene scanner position
z_range_min = 0.5;%railing middle z min range
z_range_max = 0.8;%railing middle z max range
maxDistance1 = 0.01;%%small, fit floor plane
maxDistance2 = 0.005;%small, fit curb plane
sampleSize = 2; % number of points to sample per trial
maxDistance= 3; % max allowable distance for inliers
y_width1 = 0.3; %set restricted y range of roi rotate railing
y_width2 = 0.3; %set restricted y range of roi rotate railing curb cut
z_curb = 0.2; %set curb cut height range
filename = 'data_1_0718.xlsx';
filenumber = 3;%%high resolustion 2，median resolution 3，low resolustion 4
%% Fit plane to recognize floor and seperate floor and wall
referenceVector = [0,0,1];
maxAngularDistance = 5;
[model1,inlierIndices,outlierIndices] = pcfitplane(PtCloud_railing,...
            maxDistance1,referenceVector,maxAngularDistance);
Floor = select(PtCloud_railing,inlierIndices);
PtCloud_withoutfloor = select(PtCloud_railing,outlierIndices);
z_floor = Floor.Location(:,3);
z_floor1 = median(z_floor);

% Find Railing middle part using roi
[X0,Y0,Z0] = XYZ_ptC(PtCloud_withoutfloor);
roi = [min(X0) max(X0) min(Y0) max(Y0) min(Z0)+z_range_min min(Z0)+z_range_max];%select Z range
indices = findPointsInROI(PtCloud_withoutfloor,roi);
PtCloud_middle = select(PtCloud_withoutfloor,indices);

% Convert to image in XoY plane
I = pointcloud2image_XOY( PtCloud_middle,PtCloud_middle,resolution);
img0 = I;

%Morphological processing
cc = bwmorph(img0, 'clean'); %Removing small objects from binary images
ccc = bwmorph(cc,'close'); % morphological operation 
img0 = ccc;

%Find connected region
[L, num] = bwlabel(img0);
stats = regionprops(L,'Area','BoundingBox','Centroid');
areas = [stats.Area];
rects = cat(1,stats.BoundingBox);
centroids = cat(1,stats.Centroid);

p = median(areas(:));%delete small noise
T1= round(0.3 * p);
R0 = bwareaopen(img0,T1);

CC = bwconncomp(R0);%delete big noise
stats = regionprops(CC,'Area');
areas = [stats.Area];
p = median(areas(:));
T1= 2 * p;
numPixels = cellfun(@numel,CC.PixelIdxList);
R=zeros(size(R0));
j=1;
for i=1:CC.NumObjects
    if areas(i)<=T1
       R(CC.PixelIdxList{i})=j; 
      j=j+1;
    else R(CC.PixelIdxList{i})= 0;
    end
end

img0 = R;
[L, num] = bwlabel(img0);
stats = regionprops(L,'Area','BoundingBox','Centroid');
areas = [stats.Area];
rects = cat(1,stats.BoundingBox);
centroids = cat(1,stats.Centroid);

%seperate by ransac line
points = centroids;
% figure
plot(points(:,1),points(:,2),'o');
hold on

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

[modelRANSAC, inlierIdx] = ransac(points,fitLineFcn,evalLineFcn, ...
  sampleSize,maxDistance);

modelInliers = polyfit(points(inlierIdx,1),points(inlierIdx,2),1);
inlierPts = points(inlierIdx,:);
x = [min(inlierPts(:,1)) max(inlierPts(:,1))];
y = modelInliers(1)*x + modelInliers(2);
plot(x, y, 'g-')
legend('Centroids','Robust fit');
hold off

%Rotate use ransac
[X1,Y1,Z1] = XYZ_ptC(PtCloud_railing);
p1 = model1.Parameters;

theta1 = atand(-modelInliers(1));
theta = (theta1)/180*pi;
rot = [cos(theta) sin(theta) 0; ...
      -sin(theta) cos(theta) 0; ...
           0          0      1];
trans = [0, 0, 0];
tform = rigid3d(rot,trans);%obtain tform
Railing_rotate = pctransform(PtCloud_railing,tform);
Railing_rotate_curb = pctransform(PtCloud_withoutfloor,tform);
%seperate wall by ransac
rot2 = [cos(theta) sin(theta); ...
       -sin(theta) cos(theta)];
trans2 = [0, 0];
tform2 = rigid2d(rot2,trans2);%2d, rotate points' corrdinates on the ransac

x = [min(inlierPts(:,1)) max(inlierPts(:,1))];
xmin = min(x);%before rotation
xmax = max(x);
ymin = modelInliers(1)*xmin + modelInliers(2);
ymax = modelInliers(1)*xmax + modelInliers(2);
distance = sqrt((xmax- xmin)^2 + (ymax - ymin)^2);
distance1 = distance * resolution;%length of railing

[X0,Y0,Z0] = XYZ_ptC(PtCloud_middle);%Before rotation, get the boundary
X0min = min(X0);
Y0min = min(Y0);

X_area_min0 = X0min + abs(xmin*resolution) -0.1;%Before rotation
Y_area_min0 = Y0min + abs(ymin*resolution) -0.1;
L_area_min0 = [X_area_min0, Y_area_min0];%xmin, Before rotation
L_area_min = transformPointsForward(tform2,L_area_min0);%xmin, after rotation
S_area_min0 = [x_scanner, y_scanner];
S_area_min = transformPointsForward(tform2,S_area_min0);%scanner position，after rotation

X_area_min = L_area_min(:,1);
Y_area_min = L_area_min(:,2);
X_area_max = X_area_min + distance1;
roi = [X_area_min X_area_max Y_area_min-y_width1 Y_area_min+y_width1 -inf inf];
indices = findPointsInROI(Railing_rotate,roi);%include floor, increase accuracy when calculate height
Railing = select(Railing_rotate,indices);
figure
pcshow(Railing.Location)
title('Railing')

roi = [X_area_min X_area_max Y_area_min-y_width2 Y_area_min+y_width2 -inf inf];
indices = findPointsInROI(Railing_rotate_curb,roi);%without floor, increase accuracy when fit curb
Railing_curb = select(Railing_rotate_curb,indices);
% figure
% pcshow(Railing_curb.Location)
% title('Railing curb')
%% roi to test effective scanning distance (y range to scanner position)
%roi to restrict railing y distance range in 3m 
[Railing2,X_scanner] = roi2within(S_area_min,Railing);
%seperate railing part in 1m
roi = [X_scanner-1 X_scanner+1 -inf inf -inf inf];
indices = findPointsInROI(Railing2,roi);
Railing_in = select(Railing2,indices);
figure
pcshow(Railing_in.Location)
title('Railing within 1m')

%select railing part from 1 to 3m
roi = [X_scanner-3 X_scanner-1 -inf inf -inf inf];
indices = findPointsInROI(Railing2,roi);%without floor, increase accuracy when fit curb
Railing_out1 = select(Railing2,indices);
roi = [X_scanner+1 X_scanner+3 -inf inf -inf inf];
indices = findPointsInROI(Railing2,roi);
Railing_out2 = select(Railing2,indices);
figure
pcshow(Railing_out1.Location)
hold on
pcshow(Railing_out2.Location)
title('Railing out')
hold off
%% Convert ptclouds to images
I = pointcloud2image_XOZ(Railing2,Railing2,resolution);
img = I;
%The picture is the opposite because the point cloud and the picture have different coordinate origins, so you don't have to turn it.
%% Remove small objects
[ccccc] = processXOZrailing(img);
%% Count point to obtain width
[count,max_void,median_void,max_width,median_width] = count2width(ccccc,z_scanner,z_floor1,resolution);
%% Count the height of railing
[min_Height_fromcurb,median_Height_fromcurb, ...
    min_Height_fromfloor,median_Height_fromfloor,curb_sum,...
    Height_sum_fromfloor,Height_sum_fromcurb,x_sum] = count2height(ccccc,count,resolution);
%% measure the width of curb
curb_sum = curb_sum (2:end);
median_curb = median(curb_sum);
height_curb = median_curb * resolution;
%find the curb in ptcloud
[curb] = findcurb(Railing_curb,height_curb,z_curb,maxDistance2);
% figure
% pcshow(curb.Location)
% title('curb')
% Convert ptclouds to images
[X2,Y2,Z2] = XYZ_ptC(curb);
I = pointcloud2image_XOY(curb,curb,resolution);
img_curb = I;
% Dilation Erosion (bwmorph Closing)
[ddddd] = processXOYcurb(img_curb);
%count curb width at each void medium
[max_Curb,mode_Curb,mean_Curb,median_Curb] = count2curb(ddddd,resolution);
% Compare curb and 150mm, decide where the height is calculated from
if max_Curb <= 150
   Height_curb = Height_sum_fromfloor;
else          
   Height_curb = Height_sum_fromcurb;
end
median_Height = median(Height_curb) * resolution;
min_Height = min(Height_curb) * resolution;

%% mesaurement finish here
%Next is the code that validates and writes to the form
%Comments need to be uncommented to activate the run

% %% Test floor in railing
% [X,Y,Z] = XYZ_ptC(Railing2);
% Zmin = min(Z);
% roi = [-inf inf -inf inf Zmin Zmin+0.05];
% indices = findPointsInROI(Railing2,roi);%include floor, increase accuracy when calculate height
% Railing_low = select(Railing2,indices);
% figure
% pcshow(Railing_low.Location)
% title('Railing low')
% 
% I = pointcloud2image_XOZ(Railing_low,Railing_low,resolution);
% B = I;
% figure
% imshow(B)
% %count height at each void medium
% k = size (x_sum,1);
% Height_floor_sum = 0;
% for l = 1:k 
%     Width = round(x_sum(l));
%     [count1] = heightcount(B,Width);
%     Height_floor = sum(count1(3:end));;
%     Height_floor_sum = cat(1,Height_floor_sum,Height_floor);
% end
% Height_floor_sum = Height_floor_sum(2:end);
% x1 = Height_floor_sum * resolution * 1000;
% nbins = 20;
% figure
% h1 = histogram(x1,nbins);
% title('floor')
% counts1 = h1.Values;
% range1 = h1.BinEdges;
% %% Test curb height and first handrail height
% %Measure curb height and rail height, i.e. first white and last white
% %Count the height of railing
% B = ccccc;
% %count height at each void medium
% Height_sum_curb = 0;
% Height_sum_handrail = 0;
% for  l = 1:k 
%     Width = round(x_sum(l));
%     [count1] = heightcount(B,Width);
%      if length(count1) > 4 
%      Height_curb = count1(3,1);%First white, curb height
%      Height_sum_curb = cat(1,Height_sum_curb,Height_curb);
%      Height_handrail = count1(end,1);%The last white, the height of the handrail, the top row of railings
%      Height_sum_handrail = cat(1,Height_sum_handrail,Height_handrail);
%      else
%      end
%      end
% Height_sum_curb = Height_sum_curb (2:end);%Remove the first 0 added by cat
% Height_sum_handrail = Height_sum_handrail (2:end);
% 
% x2 = Height_sum_curb * resolution * 1000;
% nbins = 20;
% figure
% h2 = histogram(x2,nbins);
% title('curb')
% counts2 = h2.Values;
% range2 = h2.BinEdges;
% 
% x3 = Height_sum_handrail * resolution * 1000;
% nbins = 20;
% figure
% h3 = histogram(x3,nbins);
% title('handrail')
% counts3 = h3.Values;
% range3 = h3.BinEdges;
% 
% x4 = Height_sum_fromcurb * resolution * 1000;
% nbins = 20;
% figure
% h4 = histogram(x4,nbins);
% title('Height from curb')
% counts4 = h4.Values;
% range4 = h4.BinEdges;
% 
% x5 = Height_sum_fromfloor * resolution * 1000;
% nbins = 20;
% figure
% h5 = histogram(x5,nbins);
% title('Height from floor')
% counts5 = h5.Values;
% range5 = h5.BinEdges;
% %% process within 1m
% [min_Height_fromcurb_in,median_Height_fromcurb_in, ...
%     min_Height_fromfloor_in,median_Height_fromfloor_in, ...
%     max_void_in,median_void_in,max_width_in,median_width_in,...
%     Height_sum_fromfloor_in,Height_sum_fromcurb_in] = process2part ...
%     (Railing_in,resolution,z_scanner,z_floor1);
% %find the curb in ptcloud
% [curb_in] = findcurb_part(X_scanner,Railing_curb,height_curb,z_curb,maxDistance2,-1,1);
% figure
% pcshow(curb_in.Location)
% title('curb in')
% % Convert ptclouds to images
% [X2,Y2,Z2] = XYZ_ptC(curb_in);
% I = pointcloud2image_XOY(curb_in,curb_in,resolution);
% img_curb = I;
% % Dilation Erosion (bwmorph Closing)
% [ddddd] = processXOYcurb(img_curb);
% %count curb width at each void medium
% [max_Curb_in,mode_Curb_in,mean_Curb_in,median_Curb_in] = count2curb(ddddd,resolution);
% %% process railing out 1
% [min_Height_fromcurb_out1,median_Height_fromcurb_out1, ...
%     min_Height_fromfloor_out1,median_Height_fromfloor_out1, ...
%     max_void_out1,median_void_out1,max_width_out1,median_width_out1,...
%     Height_sum_fromfloor_out1,Height_sum_fromcurb_out1] = process2part ...
%     (Railing_out1,resolution,z_scanner,z_floor1);
% %find the curb in ptcloud
% [curb_out1] = findcurb_part(X_scanner,Railing_curb,height_curb,z_curb,maxDistance2,-3,-1);
% figure
% pcshow(curb_out1.Location)
% title('curb out1')
% % Convert ptclouds to images
% [X2,Y2,Z2] = XYZ_ptC(curb_out1);
% I = pointcloud2image_XOY(curb_out1,curb_out1,resolution);
% img_curb = I;
% % Dilation Erosion (bwmorph Closing)
% [ddddd] = processXOYcurb(img_curb);
% %count curb width at each void medium
% [max_Curb_out1,mode_Curb_out1,mean_Curb_out1,median_Curb_out1] = count2curb(ddddd,resolution);
% %% process railing out 2
% [min_Height_fromcurb_out2,median_Height_fromcurb_out2, ...
%     min_Height_fromfloor_out2,median_Height_fromfloor_out2, ...
%     max_void_out2,median_void_out2,max_width_out2,median_width_out2,...
%     Height_sum_fromfloor_out2,Height_sum_fromcurb_out2] = process2part ...
%     (Railing_out2,resolution,z_scanner,z_floor1);
% %find the curb in ptcloud
% [curb_out2] = findcurb_part(X_scanner,Railing_curb,height_curb,z_curb,maxDistance2,1,3);
% figure
% pcshow(curb_out2.Location)
% title('curb out2')
% % Convert ptclouds to images
% [X2,Y2,Z2] = XYZ_ptC(curb_out2);
% I = pointcloud2image_XOY(curb_out2,curb_out2,resolution);
% img_curb = I;
% % Dilation Erosion (bwmorph Closing)
% [ddddd] = processXOYcurb(img_curb);
% %count curb width at each void medium
% [max_Curb_out2,mode_Curb_out2,mean_Curb_out2,median_Curb_out2] = count2curb(ddddd,resolution);
% 
% %% export data from matlab to excel
% %max void，high write in sheet2，median sheet3，low sheet4
% writematrix(max_void,filename,'Sheet',filenumber,'Range','B3');
% writematrix(max_void_in,filename,'Sheet',filenumber,'Range','B7');
% writematrix(max_void_out1,filename,'Sheet',filenumber,'Range','B12');
% writematrix(max_void_out2,filename,'Sheet',filenumber,'Range','B17');
% %median void
% writematrix(median_void,filename,'Sheet',filenumber,'Range','B4');
% writematrix(median_void_in,filename,'Sheet',filenumber,'Range','B8');
% writematrix(median_void_out1,filename,'Sheet',filenumber,'Range','B13');
% writematrix(median_void_out2,filename,'Sheet',filenumber,'Range','B18');
% %max width
% writematrix(max_width,filename,'Sheet',filenumber,'Range','C3');
% writematrix(max_width_in,filename,'Sheet',filenumber,'Range','C7');
% writematrix(max_width_out1,filename,'Sheet',filenumber,'Range','C12');
% writematrix(max_width_out2,filename,'Sheet',filenumber,'Range','C17');
% %median width
% writematrix(median_width,filename,'Sheet',filenumber,'Range','C4');
% writematrix(median_width_in,filename,'Sheet',filenumber,'Range','C8');
% writematrix(median_width_out1,filename,'Sheet',filenumber,'Range','C13');
% writematrix(median_width_out2,filename,'Sheet',filenumber,'Range','C18');
% 
% %min height from curb
% writematrix(min_Height_fromcurb,filename,'Sheet',filenumber,'Range','G3');
% writematrix(min_Height_fromcurb_in,filename,'Sheet',filenumber,'Range','G7');
% writematrix(min_Height_fromcurb_out1,filename,'Sheet',filenumber,'Range','G12');
% writematrix(min_Height_fromcurb_out2,filename,'Sheet',filenumber,'Range','G17');
% %median height from curb
% writematrix(median_Height_fromcurb,filename,'Sheet',filenumber,'Range','G4');
% writematrix(median_Height_fromcurb_in,filename,'Sheet',filenumber,'Range','G8');
% writematrix(median_Height_fromcurb_out1,filename,'Sheet',filenumber,'Range','G13');
% writematrix(median_Height_fromcurb_out2,filename,'Sheet',filenumber,'Range','G18');
% %min height from floor
% writematrix(min_Height_fromfloor,filename,'Sheet',filenumber,'Range','H3');
% writematrix(min_Height_fromfloor_in,filename,'Sheet',filenumber,'Range','H7');
% writematrix(min_Height_fromfloor_out1,filename,'Sheet',filenumber,'Range','H12');
% writematrix(min_Height_fromfloor_out2,filename,'Sheet',filenumber,'Range','H17');
% %median height from floor
% writematrix(median_Height_fromfloor,filename,'Sheet',filenumber,'Range','H4');
% writematrix(median_Height_fromfloor_in,filename,'Sheet',filenumber,'Range','H8');
% writematrix(median_Height_fromfloor_out1,filename,'Sheet',filenumber,'Range','H13');
% writematrix(median_Height_fromfloor_out2,filename,'Sheet',filenumber,'Range','H18');
% 
% %max curb width
% writematrix(max_Curb,filename,'Sheet',filenumber,'Range','K3');
% writematrix(max_Curb_in,filename,'Sheet',filenumber,'Range','K7');
% writematrix(max_Curb_out1,filename,'Sheet',filenumber,'Range','K12');
% writematrix(max_Curb_out2,filename,'Sheet',filenumber,'Range','K17');
% %mode curb width
% writematrix(mode_Curb,filename,'Sheet',filenumber,'Range','L3');
% writematrix(mode_Curb_in,filename,'Sheet',filenumber,'Range','L7');
% writematrix(mode_Curb_out1,filename,'Sheet',filenumber,'Range','L12');
% writematrix(mode_Curb_out2,filename,'Sheet',filenumber,'Range','L17');
% %mean curb width
% writematrix(mean_Curb,filename,'Sheet',filenumber,'Range','M3');
% writematrix(mean_Curb_in,filename,'Sheet',filenumber,'Range','M7');
% writematrix(mean_Curb_out1,filename,'Sheet',filenumber,'Range','M12');
% writematrix(mean_Curb_out2,filename,'Sheet',filenumber,'Range','M17');
% %median curb width
% writematrix(median_Curb,filename,'Sheet',filenumber,'Range','N3');
% writematrix(median_Curb_in,filename,'Sheet',filenumber,'Range','N7');
% writematrix(median_Curb_out1,filename,'Sheet',filenumber,'Range','N12');
% writematrix(median_Curb_out2,filename,'Sheet',3,'Range','N17');

tEnd = toc(tStart)