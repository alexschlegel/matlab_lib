function Image(shw,im,varargin)
% PTB.Show.Image
% 
% Description:	show an image
% 
% Syntax:	shw.Image(im,[p]=<center/top-left>,[s]=<no resize>,[a]=0,<options>)
% 
% In:
%	im	- a 2D/3D array
%	[p]	- the (x,y) coordinates of the image, in degrees of visual angle
%	[s]	- the (w,h) size of the image, in degrees of visual angle. a single
%		  value may be specified to fit the image within a square box of that
%		  size.
%	[a]	- the rotation of the image about its center, in clockwise degrees from
%		  vertical
%	<options>:
%		window:			('main') the name of the window on which to show the
%						image
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		border:			(false) true to show a border around the image
%		border_color:	('black') the border color
%		border_size:	(1/6) the border thickness, in degrees of visual angle
% 
% Updated: 2012-07-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'center'		, true		, ...
						'border'		, false		, ...
						'border_color'	, 'black'	, ...
						'border_size'	, 1/6		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<3 || (isnumeric(varargin{1}) && (nargin<4 || (isnumeric(varargin{2}) && (nargin<5 || (isnumeric(varargin{3}) && nargin<6)))))
	%if nargin<6 && (nargin<3 || isnumeric(varargin{1})) && (nargin<4 || isnumeric(varargin{2})) && (nargin<5 || isnumeric(varargin{3}))
		opt	= optDefault;
		
		[p,s,a]	= ParseArgs(varargin,[0 0],[],0);
	else
		[p,s,a,opt]	= ParseArgs(varargin,[0 0],[],0,cOptDefault{:});
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

if isempty(s)
	sPx	= size(im);
	sPx	= sPx(2:-1:1);
	s	= shw.parent.Window.px2va(sPx);
else
	sPx	= round(shw.parent.Window.va2px(s));
	
	if isscalar(sPx)
	%fit the image within a box
		sPxIm	= size(im);
		sPxIm	= sPxIm(2:-1:1);
		sPx		= sPx.*(sPxIm/max(sPxIm));
	end
end

%get the destination rect
	pPx	= shw.parent.Window.va2px(p);
	
	if opt.center
		pPx		= pPx + sz/2;
		rDest	= [pPx-sPx/2 pPx+sPx/2];
	else
		rDest	= [pPx pPx+sPx];
	end
%make a texture
	hMain	= PTBIFO.window.h.main;
	
	im		= im2uint8(im);
	sIm		= size(im);
	if numel(sIm)<3
		im	= cat(3,repmat(im,[1 1 3]),255*ones(sIm));
	elseif sIm(3)==3
		im	= cat(3,im,255*ones(sIm(1:2)));
	end
	
	im	= shw.parent.Window.OpenTexture('showimage',im);
	%im		= Screen('MakeTexture',hMain,im);
%draw the texture to the screen
	Screen('DrawTexture',h,im,[],rDest,a,0);
%close the texture
	%Screen('Close',im);
	shw.parent.Window.CloseTexture('showimage');
	
%add a frame
	if opt.border
		shw.Frame(opt.border_color,s,opt.border_size,p,a,...
				'window'	, opt.window	, ...
				'center'	, opt.center	  ...
				);
	end
