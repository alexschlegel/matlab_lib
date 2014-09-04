function z = fisherz(r)
% fisherz
% 
% Description:	perform a Fisher transformation on correlations
% 
% Syntax:	z = fisherz(r)
% 
% Updated: 2012-06-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
z	= atanh(r);
