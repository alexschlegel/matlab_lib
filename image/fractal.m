function [im,h] = fractal(s, varargin)
% fractal
% 
% Description:	generate a fractal image
% 
% Syntax:	[im,h] = fractal(s, <options>)
% 
% In:
% 	s	- the size of the output image
%	<options>:
%		f:				(@(z,c) z.^2+c) the iterator function.  should take two
%						matrix inputs and return a matrix the same size.
%		center:			(0) the center point of the image
%		range:			(2) the range of the largest dimension of the image
%		zmax:			(2) the maximum z value before a point is considered
%						unbounded
%		iterations:		(3000) the maximum number of iterations to perform
%		palette:		(<RGB>) the palette to use (Nx3)
%		stop_its:		(100) stop if this number of iterations have passed
%						without a point leaving the bounds
%		silent:			(false) true to suppress status messages
%		show_result:	(~opt.silent) true to show the result 
% 
% Out:
% 	im	- the fractal image
%	h	- the handle to the image shown
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'f'				, @(z,c) z.^2 + c	, ...
		'center'		, 0					, ...
		'range'			, 2					, ...
		'zmax'			, 2					, ...
		'iterations'	, 3000				, ...
		'palette'		, []				, ...
		'stop_its'		, 100				, ...
		'silent'		, false				, ...
		'show_result'	, []				  ...
		);
if isempty(opt.palette)
	col	=	[
				1	0	0
				1	1	0
				0	1	0
				0	1	1
				0	0	1
				1	0	0
			];
	opt.palette	= MakeLUT(col,255);
end
opt.show_result	= unless(opt.show_result,~opt.silent);

%get the image size
	if numel(s)==1
		s	= [s s];
	end

%get the field bounds
	if s(1) > s(2)
		sField	= [1 s(2)/s(1)].*opt.range;
	else
		sField	= [s(1)/s(2) 1].*opt.range;
	end

%construct the field
	yCenter	= imag(opt.center);
	xCenter	= real(opt.center);
	
	yRad	= sField(1)/2;
	xRad	= sField(2)/2;
	
	yCol	= linspace(yCenter+yRad, yCenter-yRad, s(1));
	xCol	= linspace(xCenter-xRad, xCenter+xRad, s(2));
	
	[y,x]	= ndgrid(yCol,xCol);
	field	= x + i*y;

%get the number of iterations for each point to leave the bounds
	n	= zeros(s,'uint16');
	z	= field;
	bIn	= true(s);
	
	kStopIts	= 0;
	
	fLabelProgress = @(n) ['Points remaining (' num2str(n) ')'];
	
	progress('action','init','total',opt.iterations, 'label', fLabelProgress(prod(s)), 'silent', opt.silent);
	for it=1:opt.iterations
		z(bIn)	= opt.f(z(bIn), field(bIn));
		
		bOut	= bIn & abs(z)>opt.zmax;
		n(bOut)	= it;
		bIn		= bIn & ~bOut;
		
		if any(bOut(:))
			kStopIts	= 0;
		else
			kStopIts	= kStopIts + 1;
		end
		if kStopIts>=opt.stop_its || ~any(bIn(:))
			break;
		end
		
		progress('label', fLabelProgress(sum(bIn(:))));
	end
	progress('action','end');

%construct the image
	%map iterations to palette colors
	nPalette	= size(opt.palette, 1);
	n			= mod(n-1,nPalette) + 1; 
	
	im						= ind2rgb(n, opt.palette);
	im(repmat(bIn,[1 1 3]))	= 0;

%show the image
	if opt.show_result
		pOld	= iptgetpref('ImshowAxesVisible');
		iptsetpref('ImshowAxesVisible','on');
		
		ha	= axes;
		h	= imshow(im,'YData', yCol, 'XData', xCol);
		set(ha,'ydir','normal');
		
		iptsetpref('ImshowAxesVisible',pOld);
	else
		h	= [];
	end