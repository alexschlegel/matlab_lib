function x = repto(x,s)
% repto
% 
% Description:	repmat x to the specified size
% 
% Syntax:	x = repto(x,s)
% 
% Updated: 2011-02-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%size of x filled with ones
	sx	= [size(x) ones(1,numel(s)-ndims(x))];
%potentially overshoot
	x	= repmat(x,max(1,s-sx+1));
%crop x
	if any(size(x)>s)
		sCrop	= arrayfun(@(n) 1:n,s,'UniformOutput',false);
		x		= x(sCrop{:});
	end
