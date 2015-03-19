function [b,k] = ismembercellstr(x,y)
% ismembercellstr
% 
% Description:	a version of ismember that is much faster for comparing cells
%				of strings
% 
% Syntax:	[b,k] = ismembercellstr(x,y)
% 
% In:
% 	x	- a cell of strings
%	y	- another cell of strings
% 
% Out:
% 	b	- a logical array indicating which strings in x are also in y
%	k	- an array indicating the index in y of each matching element of x.
%		  non-matching elements of x get 0 in this array.
% 
% Updated: 2014-01-24
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nX	= numel(x);
nY	= numel(y);

b	= false(nX,1);
k	= zeros(nX,1);

for kX=1:nX
	for kY=1:nY
		if strcmp(x{kX},y{kY})
			b(kX)	= true;
			k(kX)	= kY;
			break;
		end
	end
end
