function I = pointcloud2image_XOY( img_full,img,resolution)
tic
ptC = img_full;
[X,Y,Z] = XYZ_ptC(ptC);

[a,b] = meshgrid((min(X)-0.1):resolution:(max(X)+0.1),(min(Y)-0.1):resolution:(max(Y)+0.1)); 
[numr,numc] = size(a);

ptC = img;
[x,y,z] = XYZ_ptC(ptC);
grid_centers = [a(:),b(:)];

% classification
clss = knnsearch(grid_centers,[x,y],'Distance','euclidean'); 

% data_grouping
% class_stat = accumarray(clss,d,[numr*numc 1],local_stat);
class_stat = zeros(numr*numc, 1);
class_stat(clss) = 1;

% 2D reshaping
I  = reshape(class_stat , size(a)); 

% figure;  imshow(I,[]);
toc
end

