function y = distpick(x,p)
% distpick
% 
% Description:	randomly pick an element from x, given the probability
%				distribution defined by p 
% 
% Syntax:	y = distpick(x,p)
% 
% In:
% 	x	- an array, sorted by decreasing probability of occurrence
%	p	- a numerical array the same size as x, defining the probability of
%		  occurrence of each element of x
% 
% Out:
% 	y	- a random element of x
% 
% Updated: 2012-10-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nX	= numel(x);

%pick a random position in the probability distribution
	sP	= sum(p(:));
	r	= sP*rand;
%which element is associated with this position?
	s	= 0;
	
	for kX=1:nX
		s	= s + p(kX);
		
		if s>=r
			break;
		end
	end
%pick it
	if iscell(x)
		y	= x{kX};
	else
		y	= x(kX);
	end
