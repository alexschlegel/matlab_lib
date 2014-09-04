function b = holefill(b,varargin)
% holefill
% 
% Description:	fill holes in a binary image. this takes care of objects on the
%				edge of the image, whereas imfill(b,'holes') does not.
% 
% Syntax:	b = holefill(b,[conn]=8)
%
% In:
%	b		- a logical 2D image
%	conn	- the connectivity to use. either 4 or 8.
% 
% Updated: 2013-05-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
conn	= ParseArgs(varargin,8);

sz	= size(b);

%find the largest black object that touches the edge
	L	= bwlabeln(~b,conn);
	r	= regionprops(L,'Area','BoundingBox');
	
	ext			= cat(1,r.BoundingBox);
	ext(:,1:2)	= ext(:,1:2) + 0.5;
	
	bEdge	= ext(:,1)==1 | ext(:,2)==1 | ext(:,1)+ext(:,3)-1==sz(2) | ext(:,2)+ext(:,4)-1==sz(1);
	kEdge	= find(bEdge);
	
	[A,kSort]	= sort([r(kEdge).Area],'descend');
	
	kBack	= kEdge(kSort(1));

b	= b | ~(L==kBack);
