function b = uniform(x)
% uniform
% 
% Description:	test whether all elements of x are the same
% 
% Syntax:	b = uniform(x)
% 
% Updated: 2011-11-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= numel(x);
if n<2
	b	= true;
	return;
end

if isnumeric(x)
	b	= all(x(2:end)==x(1));
else
	switch class(x)
		case 'cell'
			b	= all(cellfun(@(c) isequal(c,x{1}),x(2:end)));
		otherwise
			b	= true;
			for k=2:n
				if ~isequal(x(k),x(1))
					b	= false;
					return;
				end
			end
	end
end
