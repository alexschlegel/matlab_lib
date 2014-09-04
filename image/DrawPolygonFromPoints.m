function im = DrawPolygonFromPoints(p,varargin)
% DrawPolygonFromPoints
% 
% Description:	draw a polygon given the vertex points
% 
% Syntax:	im = DrawPolygonFromPoints(p,<options>)
% 
% In:
% 	p	- an Nx2 array of (y,x) coordinates of the polygon's vertices
%	<options>
%		'ppu'		- pixels per unit [1]
%		'w'			- thickness of the drawn line, in units [1]
% 
% Out:
% 	im	- an image of the polygon
% 
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,'ppu',1,'w',1);

n	= size(p,1);

%convert to pixels
	p		= p .* opt.ppu;
	opt.w	= opt.w * opt.ppu;
%convert to valid pixel values
	p(:,1)	= round(p(:,1) - min(p(:,1)) + 1);
	p(:,2)	= round(p(:,2) - min(p(:,2)) + 1);

%initialize the image
	mxY		= max(p(:,1));
	mxX		= max(p(:,2));
	wOffset	= floor(opt.w/2);
	sIm	= [mxY+2*wOffset,mxX+2*wOffset];
	im	= ones(sIm);
%shift points by our offset
	p	= p + wOffset;
	
%draw the polygon
	nT	= max([mxY mxX]);
	
	p	= [p;p(1,:)];
	for k=1:n
		t	= reshape(0:nT-1,[],1)./(nT-1);
		y	= round(p(k,1) + t.*(p(k+1,1) - p(k,1)));
		x	= round(p(k,2) + t.*(p(k+1,2) - p(k,2)));
		
		yx		= unique([y x],'rows');
		k		= sub2ind(sIm,yx(:,1),yx(:,2));
		im(k)	= 0;
	end
%thicken to our desired width
	im	= bThicken(im,opt.w);
	