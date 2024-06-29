function [count,max_void,median_void,max_width,median_width] = count2width(ccccc,z_scanner,z_floor1,resolution)
%Count point to obtain width
A = ccccc;
j = 1; count = 0; 
height = round (abs((z_scanner - z_floor1) / resolution)); 
for i = 1:size(A,2)-1 
    if A(height,i) == A(height,i+1)
        j = j+1;  
    else          
        count = cat(1,count,j);
        j = 1;  
    end
end
count = count(2:end);  
width_all = reshape(count,2,[])'; 
void = width_all(:,1); 
void = void(2:end); 
max_void = max(void) * resolution *1000;
width = width_all(:,2); 
max_width = max(width) * resolution *1000;
median_width = median(width) * resolution *1000; 
median_void = median(void) * resolution *1000;
end