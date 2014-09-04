function k = GetNextDimension(x)
% GetNextDimension
% 
% Description:	get the first singleton dimension of x
% 
% Syntax:	k = GetNextDimension(x)
% 
% Updated:	2008-11-05
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

nd	= ndims(x);
s	= size(x);

if nd==2
	if s(1)==1
		k	= 1;
	elseif s(2)==1
		k	= 2;
	else
		k	= 3;
	end
else
	kS	= find(s==1);
	
	if numel(kS)>0
		k	= kS(1);
	else
		k	= nd+1;
	end
end
