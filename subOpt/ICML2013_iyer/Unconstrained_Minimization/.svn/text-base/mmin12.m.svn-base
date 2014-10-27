% Implementation of MMin-I/ II
% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [A, B] = mmin12(F, V)
% Implementation of the IMA-1 algorithm with the minimal modular minimizers
% at every iteration.
A = [];
B = V;
while(1)
   VsubA = setdiff(V, A);
   addset = [];
   stuck = 1;
   valA = F(A);
   for i = 1 : length(VsubA)
        if(F([A, VsubA(i)]) - valA < 0)
            addset = [addset, VsubA(i)];
            stuck = 0;
        end
   end  
   A = [A, addset];
   if(stuck == 1)
       break;
   end
end

while(1)
   remset = [];
   stuck = 1;
   valB = F(B);
   for i = 1 : length(B)
        if(F(sfo_setdiff_fast(B, B(i))) - valB < 0)
            remset = [remset B(i)];
            stuck = 0;
        end
   end  
   B = sfo_setdiff_fast(B, remset);
   if(stuck == 1)
       break;
   end
end