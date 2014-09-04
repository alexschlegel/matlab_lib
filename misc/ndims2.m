function nd = ndims2(x)
% ndims2
% 
% Description:	number of dimensions of x, correct for scalars and empty arrays
% 
% Syntax:	nd = ndims2(x)
% 
% Updated: 2010-05-04
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isempty(x)
	nd	= 0;
elseif isscalar(x)
	nd	= 1;
else
	nd	= ndims(x);
end
