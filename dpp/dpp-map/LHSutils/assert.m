function [] = assert(condition,message)
% ASSERT  Assert than some condition holds.
%
% ASSERT(condition)
% ASSERT(condition, message)
%
% If condition does not hold, 

if nargin == 1; message = '<no message>'; end
if nargin < 1; error('not enough arguments'); end

if ~condition
    ddd = dbstack;

    if length(ddd) > 1
        dname = ddd(2).name; 
    else 
        dname='command line'; 
    end

    fprintf(1, '!!! Assert failure in function "%s": %s\n', dname, message); 
    error('');
end
