function [count1] = heightcount(B,Width)
%railing height
i = 1; count1 = 0;
       for j = 1:size(B,1)-1 
          if B(j,Width) == B(j+1,Width) 
             i = i + 1;  
          else          
             count1 = cat(1,count1,i);
             i = 1;          
          end
       end
end