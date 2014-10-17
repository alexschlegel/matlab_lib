function im = imborder(im,varargin)
% imborder
% 
% Description:	generate a border image or add a border to an image
% 
% Syntax:	im = imborder(im,<options>) OR
%			im = imborder(s,<options)
% 
% In:
% 	im	- the image to which to add a border
%	s	- the size of the image to create
%	<options>:
%		c:			([0 0 0]) the border color
%		t:			(1) the border thickness
%		a:			(1) the border alpha
%		b:			(NaN) if s is specified, the color to use for non-border
%					pixels
%		location:	('inside') either 'inside', 'center', or 'outside' to
%					specify the location of the border
% 
% Out:
% 	im	- the border image or image with border added
% 
% Updated: 2010-04-30
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'c'			, [0 0 0]	, ...
		't'			, 1			, ...
		'a'			, 1			, ...
		'b'			, NaN		, ...
		'location'	, 'inside'	  ...
		);

%get the base image
	if numel(im)<=3
		im	= repmat(reshape(opt.b,1,1,[]),[im numel(opt.c)]);
	end
%expand for the border
	s		= size(im);
	switch lower(opt.location)
		case 'inside'
		case 'center'
			s(1:2)	= s(1:2)+opt.t;
			imBlank	= nan(s);
			im		= InsertImage(imBlank,im,[opt.t/2+1 opt.t/2+1]);
		case 'outside'
			s(1:2)	= s(1:2)+2*opt.t;
			imBlank	= nan(s);
			im		= InsertImage(imBlank,im,[opt.t+1 opt.t+1]);
		otherwise
			error(['"' opt.location '" is not a valid border location.']);
	end
%add the border
	s					= [size(im) ones(1,max(0,3-ndims(im)))];
	[yBorderV,xBorderV]	= ndgrid(1:s(1),[1:opt.t s(2)-opt.t+1:s(2)]);
	[yBorderH,xBorderH]	= ndgrid([1:opt.t s(1)-opt.t+1:s(1)],1:s(2));
	yBorder				= [yBorderV(:); yBorderH(:)];
	xBorder				= [xBorderV(:); xBorderH(:)];
	nBorder				= numel(yBorder);
	for kC=1:numel(opt.c)
		kIm	= sub2ind(s,yBorder,xBorder,repmat(kC,[nBorder 1]));
		
		bNaN			= isnan(im(kIm));
		im(kIm(bNaN))	= opt.c(kC);
		im(kIm(~bNaN))	= (1-opt.a)*im(kIm(~bNaN))+opt.a*opt.c(kC);
	end
