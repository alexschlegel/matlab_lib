function b = MaskDiamond(w,varargin)
% MaskDiamond
% 
% Description:	create a binary diamond mask
% 
% Syntax:	b = MaskDiamond(w,[h]=w)
% 
% In:
% 	w			- the width of the diamond (vertex to vertex)
%	[h]			- the height of the diamond
% 
% Out:
% 	b	- a binary mask set to true inside the diamond mask
% 
% Updated:	2009-03-15
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[h]	= ParseArgs(varargin,w);

%get the vertex points of the polygon
	w2	= w/2-0.5;
	h2	= h/2-0.5;
	
	y	= [0; h2; 0; -h2];
	x	= [w2; 0; -w2; 0];

%get the polygon
	b	= ~DrawPolygonFromPoints([y x]);
%fill it in
	k	= bwlabeln(b);
	p	= regionprops(k,'FilledImage');
	b	= p.FilledImage;
	