% Author: Stefanie Jegelka (stefje@eecs.berkeley.edu)

function [d] = ellipApp(f, n, ismatroid, tmpfile)
%
% Goemans et al.'s submodular function approximation
%
% f: a function handle to cost function
% n: number of elements (ground set size)
% ismatroid: flag, if =1, then function is matroid rank function and more
%            efficient algorithm can be used
% tmpfile: file name of a temporary file (string). This code can be slow,
%          and will therefore save intermediate results in the temp file
%          in case the job breaks

if ~exist(tmpfile, 'file')
    d = zeros(n,1);
    
    for i=1:n
        d(i) = n/f(i)^2;
    end
else
    load(tmpfile);
    if length(d) ~= n
        d = zeros(n,1);
        
        for i=1:n
            d(i) = n/f(i)^2;
        end

    end
end

converged = 0;
lim = (n + 1);

disp(size(d))

while ~converged
   [z] = maxnorm(d, f, ismatroid); 
   %disp(z');
   l = (z.^2)' * d;
   fprintf('l-lim=%1.2e, length(d)=%d\n', l - lim, length(d));
    
    if l > lim+1e-6
       
        B = n/l * (l-1)/(n-1) * diag(d) + n/l^2 * (1 - (l-1)/(n-1)) * diag(d) * z*z' * diag(d);
        d = 1./ (diag(inv(B)) );
        
    else
        converged = 1;
    end    
    save(tmpfile, 'd');
    if length(d) ~= n
        keyboard;
    end
    
    %disp(d);
end

d = 1./d;










function z = maxnorm(d, f, ismatroid)
%
% maximum norm algorithm

z = zeros(length(d),1);

if ismatroid
    % greedy
   [dsrt, inds] = sort(d, 'descend');
   tmp = f([]);
   for i=1:length(d)
       tmp1 = f(inds(1:i));
       z( inds(i) ) = tmp1 - tmp;
       tmp = tmp1;
   end
   
else
    % todo
    n = length(d);
    c = sqrt(d);
    T = zeros(1,length(d));

    aug = zeros(n,1);
    tmp = 0;
    y = aug;

    g = @(A) makeG(A, c, f);
    
    for k=1:n
       % find T_k 
       for j=1:n
           if ~isnan(aug(j))              
               aug(j) = g([T(1:(k-1)) j]);
           end
       end
       
       [gm, jj] = max(aug);
       aug(jj) = NaN;
       T(k) = jj;
       %disp(T);
       
       y(jj) = gm - tmp;
       tmp = gm;
       
    end
    z = y./c;
    z = z / (2 + 2/3*log(n));
    
end



function y = makeG(A, c, f)

cc = c(A);
[csrt, inds] = sort(cc, 'ascend');
y = 0;
k = length(A);

for i=1:k 
    y = y + csrt(i) * (f( A(inds(i:k)) ) - f( A(inds((i+1):k)) ) );
end    
