function  b = ltSym(x,y)
% LTSYM
%
% Description:	less than function for symbolic variables
%
% Syntax:	b = ltSym(x,y)
%
% In:
%	x	- a symbolic variable
%	y	- a symbolic variable
%
% Out:
%	b	- true if x<y, false otherwise
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isa(x,'sym') || isa(y,'sym')
	nX	= numel(x);
	nY	= numel(y);
	
	if nX<nY
		x	= x*ones(size(y));
	elseif nY<nX
		y	= y*ones(size(x));
	end
	
	b	= logical(zeros(size(x)));
	for k=1:numel(x)
		b(k)	= isequal(maple(['evalb(' char(x(k)) '<' char(y(k)) ')']),'true');
	end
	
	%x	= x - y;
	%b	= double(x)<0;
else
	b	= x<y;
end
