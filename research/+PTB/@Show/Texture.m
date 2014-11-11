function Texture(shw,hTexture,varargin)
% PTB.Show.Texture
% 
% Description:	transfer a texture
% 
% Syntax:	shw.Texture(hTexture,[rect]=<all>,[p]=<center/top-left>,[s]=<no resize>,[a]=0,<options>)
% 
% In:
%	hTexture	- a texture handle, or the name of a texture
%	[rect]		- the rect of the portion of the texture to transfer
%	[p]			- the (x,y) coordinates of the texture on the destination window,
%				  in degrees of visual angle
%	[s]			- the (w,h) size of the texture on the destination window, in
%				  degrees of visual angle.  a single value may be specified to
%				  fit the texture within a square box of that size.
%	[a]			- the rotation of the texture about its center, in clockwise
%				  degrees from vertical
%	<options>:
%		window:			('main') the name of the window on which to show the
%						texture
%		center:			(true) true if given coordinates are relative to the
%						screen center
% 
% Updated: 2011-12-22
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;
persistent optDefault cOptDefault;

	
if nargin==2 && isnumeric(hTexture)
%we need to be speedy
	Screen('DrawTexture',PTBIFO.window.h.main,hTexture);
else
	%parse the arguments
		if isempty(optDefault)
			optDefault	= struct(...
							'window'	, 'main'	, ...
							'center'	, true		  ...
							);
			cOptDefault	= opt2cell(optDefault);
		end
		
		if nargin<3 || (isnumeric(varargin{1}) && (nargin<4 || (isnumeric(varargin{2}) && (nargin<5 || (isnumeric(varargin{3}) && (nargin<6 || (isnumeric(varargin{4}) && nargin<7)))))))
		%if nargin<7 && (nargin<3 || isnumeric(varargin{1})) && (nargin<4 || isnumeric(varargin{2})) && (nargin<5 || isnumeric(varargin{3})) && (nargin<6 || isnumeric(varargin{4}))
			opt	= optDefault;
			
			[rect,p,s,a]	= ParseArgs(varargin,[],[0 0],[],0);
		else
			[rect,p,s,a,opt]	= ParseArgs(varargin,[],[0 0],[],0,cOptDefault{:});
		end
		
		if ischar(hTexture)
			hTexture	= shw.parent.Window.Get(hTexture);
		end
		
		if isempty(hTexture)
			return;
		end
	
	[h,sz]	= shw.parent.Window.Get(opt.window);
	
	if isempty(rect)
		rect	= Screen('Rect',hTexture);
	end
	
	if isempty(s)
		sPx	= rect(3:4) - rect(1:2);
	else
		sPx	= round(shw.parent.Window.va2px(s));
		
		if isscalar(sPx)
		%fit the texture within a box
			sPxT	= rect(3:4) - rect(1:2);
			sPx		= sPx.*(sPxT/max(sPxT));
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
	%draw the texture to the screen
		Screen('DrawTexture',h,hTexture,rect,rDest,a,0);
end
