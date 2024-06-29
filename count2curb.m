function [max_Curb,mode_Curb,mean_Curb,median_Curb] = count2curb(ddddd,resolution)
%count curb width at each void medium
D = ddddd;
k = size (D,2);
Width_Curb_sum = 0;
for l = 1:k 
    Width = l;
    i = 1;
    Width_Curb = nnz(D(:,Width));
    if Width_Curb > 0
    Width_Curb_sum = cat(1,Width_Curb_sum,Width_Curb);
    else
    end
end
Width_Curb_sum= Width_Curb_sum (2:end);
max_Curb1 = max(Width_Curb_sum);
Curb_gap = find(Width_Curb_sum < max_Curb1 * 0.95);
Width_Curb_sum(Curb_gap,:) = [];
max_Curb = max_Curb1 * resolution *1000;
mode_Curb = mode(Width_Curb_sum) * resolution *1000;
mean_Curb = mean(Width_Curb_sum)* resolution *1000;
median_Curb = median(Width_Curb_sum) * resolution *1000;
end