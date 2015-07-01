function [x,b] = intersectmulti(c,varargin)
% intersectmulti
% 
% Description:	calculate the intersection of a set of arrays
% 
% Syntax:	[x,b] = intersectmulti(c,<options>)
% 
% In:
% 	c	- a cell of arrays
%	<options>:
%		allbut:	(0) include values that are in all except for at most the
%				indicated number of arrays (e.g. a value of 1 indicates that
%				values that are in all arrays or all except one array should be
%				included)
% 
% Out:
% 	x	- the intersection of the arrays in c
%	b	- an nIntersection x nC logical array specifying which arrays each
%		  intersection element is a member of
% 
% Updated: 2015-06-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'allbut'	, 0	  ...
			);
	
	n	= numel(c);

%did we get anything?
	if n==0
		x	= [];
		return;
	end

if opt.allbut==0
%regular intersection
	x	= c{1};
	for k=2:n
		x	= intersect(x,c{k});
	end
	
	b	= true(numel(x),n);
else
%partial intersection
	u	= unionmulti(c);
	
	b	= cellfun(@(x) ismember(u,x),c,'uni',false);
	b	= cat(2,b{:});
	
	nIn		= sum(b,2);
	bKeep	= nIn>=n-opt.allbut;
	
	x	= u(bKeep);
	b	= b(bKeep,:);
end
