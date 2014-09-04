function b = bSkeletonize(b)
% bSkeletonize
% 
% Description:	skeletonizes as binary image
% 
% Syntax:	b = bSkeletonize(b)
%
% In:
%	b	- a binary image
% 
% Out:
%	b	- b skeletonized
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= bwmorph(b,'skel',Inf);
