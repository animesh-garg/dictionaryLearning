%--------------------------------------------------------------------------
% This function computes the maximum error between elements of two 
% coefficient matrices
% C: MxN coefficient matrix
% Z: MxN coefficient matrix
% err: infinite norm error between vectorized C and Z
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function err = errorCoef(Z,C)

err = sum(sum( abs(Z-C) )) / (size(Z,1)*size(Z,2));
%err = max(max( abs(Z-C) ));