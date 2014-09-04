function im = bvSRFFlatMap2im(srf,varargin)
% bvSRFFlatMap2im
% 
% Description:	convert an SRF flatmap to an image
% 
% Syntax:	im = bvSRFFlatMap2im(srf,<options>)
% 
% In:
% 	srf	- a BVQXtools SRF object representing a flatmap (i.e. a surface mesh
%		  with all x-coordinates at the mesh center
%	<options>:
%		'color':	(128) the color of the mesh.  either a 1D intensity value, a
%					3D RGB value, or a BVQXtools SMP object from which to draw
%					the colors
%		'size':		(based on coordinates) fit mesh into a box with side length
%					specified by this option
% 
% Out:
% 	im	- an RGB image of the mesh
% 
% Updated:	2009-08-05
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'color'	, 128	, ...
		'size'	, [] 	  ...
		);
		
%get the conversion from SRF (y,z) to image (y,x)
	bVisible	= ~any(srf.VertexColor<0 | srf.VertexColor>=2^32-2^10,2);
	kVisible	= find(bVisible);
	nVisible	= sum(bVisible);
	
	yMin	= min(srf.VertexCoordinate(bVisible,2));
	yMax	= max(srf.VertexCoordinate(bVisible,2));
	zMin	= min(srf.VertexCoordinate(bVisible,3));
	zMax	= max(srf.VertexCoordinate(bVisible,3));
	
	yWidth	= (yMax - yMin);
	zWidth	= (zMax - zMin);
	
	if isempty(opt.size)
		h	= yWidth;
		w	= zWidth;
	else
		if yWidth>zWidth
			h	= opt.size;
			w	= opt.size*(zWidth/yWidth);
		else
			h	= opt.size*(yWidth/zWidth);
			w	= opt.size;
		end
	end
	h	= round(h);
	w	= round(w);
	
	srf2imRow	= @(x) round((x-yMin)/yWidth*(h-1)+1);
	srf2imCol	= @(x) round((x-zMin)/zWidth*(w-1)+1);
%get a vertex index image
	kImVertex	= zeros(h,w);
	
	kRow	= srf2imRow(srf.VertexCoordinate(bVisible,2));
	kCol	= srf2imCol(srf.VertexCoordinate(bVisible,3));
	k		= sub2ind([h,w],kRow,kCol);
	
	kImVertex(k)	= 1:nVisible;

im	= kImVertex;
