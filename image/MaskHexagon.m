function [b,w,h,s] = MaskHexagon(w,varargin)
% MaskHexagon
% 
% Description:	create a binary hexagonal mask
% 
% Syntax:	[b,w,h,s] = MaskHexagon(w,[h]=<regular>,[orient]='horizontal')
% 
% In:
% 	w			- the width of the hexagon (defined as the diameter of the 
%				  circumscribed circle, in pixels
%	[h]			- the height of the hexagon, defined as the distance between
%				  parallel sides.  defaults to creating a regular polygon.
%	[orient]	- specify 'horizontal' to orient the hexagon such that
%				  two sides are horizontal, 'vertical', or specify an angle (in
%				  radians) to rotate the hexagon counter-clockwise from the
%				  'horizontal' position
% 
% Out:
% 	b	- a binary mask set to true inside the hexagon mask.  the mask is
%		  returned in a box the width/height of the smallest circle that
%		  circumscribes the hexagon
%	w	- width of the hexagon
%	h	- height of the hexagon
%	s	- length of one side of the hexagon
% 
% Updated:	2009-03-15
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[h,vOrient]	= ParseArgs(varargin,[],'horizontal');

%set the rotation, in radians
	if isa(vOrient,'char')
		switch lower(vOrient)
			case 'horizontal'
				aRotate	= 0;
			case 'vertical'
				aRotate	= pi/2;
			otherwise
				error(['"' vOrient '" is an invalid orientation.']);
		end
	else
		aRotate	= vOrient;
	end

%get the vertex points of the polygon
	%side of the regular hexagon is half the width
		s	= (w-1)/2;
	%get the regular, horizontal points first
		r	= repmat(s,[6 1]);
		a	= pi/3*(0:5)';
	%get the regular height
		hReg	= 2*s*sin(pi/3);
	%now resize to get the desired height
		if ~isempty(h)
			%scale the y-values of the horizontal sides by h/hReg;
				%convert to cartesian
					y	= r.*sin(a);
					x	= r.*cos(a);
				%scale y
					y([2 3 5 6])	= y([2 3 5 6]).*(h-1)/hReg;
				%convert back
					r	= sqrt(x.^2 + y.^2);
					a	= atan2(y,x);
		else
			h	= hReg;
		end
	%rotate
		a = a + aRotate;
	%convert to cartesian
		y	= r.*sin(a);
		x	= r.*cos(a);

%get the diameter of the circumscribed circle
	d1	= ceil(dist([y(2) x(2)],[y(5) x(5)]));
	d	= max(w,d1);

%get the polygon
	b	= ~DrawPolygonFromPoints([y x]);
%fill it in
	k	= bwlabeln(b);
	p	= regionprops(k,'FilledImage');
	bH	= p.FilledImage;
%enlarge to fill the circumscribed circle
	%make the mask at most size d
		sM	= size(bH);
		df	= sM - d;
		
		pUL	= max(1,floor(df/2)+1);
		pBR	= min(sM,floor(sM-df/2));
		
		bH	= bH(pUL(1):pBR(1),pUL(2):pBR(2));
	%initialize the output mask
		b	= false(d);
	%insert the mask
		sM	= size(bH);
		pUL	= floor((d-sM)/2)+1;
		pBR	= pUL + sM - 1;
		
		b(pUL(1):pBR(1),pUL(2):pBR(2))	= bH;
	