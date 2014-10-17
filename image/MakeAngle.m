function im = MakeAngle(a,varargin)
% MakeAngle
% 
% Description:	make an image showing the specified angle
% 
% Syntax:	im = MakeAngle(a,<options>)
% 
% In:
% 	a	- the angle, in degrees
%	<options>:
%		'dpi':			(300) print resolution of the image
%		'w':			(2) width of the triangle showing the angle, in in.
%		'paper_size':	('min') paper size, either 'min' for minimum size,
%						'letter' for letter paper size, or an [h w] array
%						specifying the size in in.
%		't':			(1/16) width of drawn lines, in in.
% 
% Out:
% 	im	- the image showing the specified angle
% 
% Updated: 2010-04-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'dpi'			, 300		, ...
		'w'				, 2			, ...
		'paper_size'	, 'min'	, ...
		't'				, 1/16		  ...
		);
		
%get the paper size
bInsert	= true;
if ischar(opt.paper_size)
	switch lower(opt.paper_size)
		case 'min'
			bInsert	= false;
		case 'letter'
			opt.paper_size	= [11 8.5];
		otherwise
			error(['"' opt.paper_size '" is an unrecognized paper size.']);
	end
end

%initialize the images
	tLine	= round(opt.t*opt.dpi);
	m		= tan(d2r(a));
	
	if bInsert
		h	= round(opt.paper_size(1)*opt.dpi);
		w	= round(opt.paper_size(2)*opt.dpi);
		im	= ones(h,w);
	end
	
	opt.h	= opt.w*m;
	hT		= round(opt.h*opt.dpi);
	wT		= round(opt.w*opt.dpi);
	imT		= ones(hT,wT);
	
	
%make the triangle
	for k=0:tLine-1
		y					= hT-k;
		x					= round((hT-y)./m+1);
		imT(round(y),x:end)	= 0;
		
		x					= wT-k;
		y					= round(hT-(x-1)*m+1);
		imT(y:end,round(x))	= 0;
	end
	
	x			= GetInterval(1,wT,wT*3);
	for k=GetInterval(0,round(tLine/cos(d2r(a))),tLine*10)
		y			= max(1,min(hT,hT-(x-1)*m+k));
		kIm			= sub2ind([hT wT],round(y),round(x));
		imT(kIm)	= 0;
	end
	
%draw an arc at the angle
	rArc	= round(opt.w*opt.dpi/4);
	aArc	= GetInterval(0,d2r(a),round(2*pi*rArc/4*10))';
	for k=GetInterval(rArc-tLine/2,rArc+tLine/2,tLine*10)
		p		= PointConvert([repmat(k,[numel(aArc) 1]) aArc],'polar','cartesian');
		x		= ceil(p(:,1));
		y		= ceil(hT-p(:,2));
		bKeep	= x>=1 & x<=wT & y>=1 & y<hT;
		
		kIm			= sub2ind([hT wT],y(bKeep),x(bKeep));
		imT(kIm)	= 0;
	end
	
%insert the triangle
	if bInsert
		im	= InsertImage(im,imT,[0 0],'center','center');
	else
		im	= imT;
	end
	
%make RGB
	im	= repmat(im,[1 1 3]);