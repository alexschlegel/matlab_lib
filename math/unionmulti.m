function x = unionmulti(c)
% unionmulti
% 
% Description:	calculate the union of a set of arrays
% 
% Syntax:	x = unionmulti(c)
% 
% In:
% 	c	- a cell of arrays
% 
% Out:
% 	x	- the union of the arrays in c
% 
% Updated: 2015-06-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
c	= cellfun(@(x) reshape(x,[],1),c,'uni',false);
x	= unique(cat(1,c{:}));
