function Fixation(shw,varargin)
% PTB.Show.Fixation
% 
% Description:	add a fixation dot to the screen
% 
% Syntax:	shw.Fixation(<options>)
% 
% In:
% 	<options>:
%		window:	('main') the name of the window on which to show the fixation
%		size:	(<default>) the diameter of the fixation dot, in degrees of
%				visual angle
%		color:	('fixation') the color of the fixation dot
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'	, 'main'		, ...
						'size'		, []			, ...
						'color'		, 'fixation'	  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<2
 		r	= PTBIFO.show.fixation.size/2;
		
		col	= PTBIFO.color.fixation;
		while ischar(col)
			col	= PTBIFO.color.(col);
		end
		
		h		= PTBIFO.window.h.main;
		rect	= Screen('Rect',h);
		sz		= rect(3:4) - rect(1:2); 
	else
		opt	= ParseArgs(varargin,cOptDefault{:});
		
		if isempty(opt.size)
			opt.size	= PTBIFO.show.fixation.size;
		end
		r	= opt.size/2;
		
		col	= shw.parent.Color.Get(opt.color);
		
		[h,sz]	= shw.parent.Window.Get(opt.window);
	end

%show the fixation
	rPx		= shw.parent.Window.va2px(r);
	pPx		= sz/2;
	rect	= [pPx-rPx pPx+rPx];
	
 	Screen('FillOval',h,col,rect);
