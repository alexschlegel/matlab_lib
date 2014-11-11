function Color(shw,col,varargin)
% PTB.Show.Color
% 
% Description:	show a color
% 
% Syntax:	shw.Color(col,<options>)
% 
% In:
%	col	- the color to show
% 	<options>:
%		window:		('main') the name of the window, or the handle to a window
% 
% Updated: 2012-07-22
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if numel(varargin)>1
	opt	= ParseArgs(varargin,...
			'window'	, 'main'	  ...
			);
else
	opt.window		= 'main';
end

h	= shw.parent.Window.Get(opt.window);

%show the color
	col	= shw.parent.Color.Get(col);
	
	[sfOld,dfOld]	= Screen('BlendFunction',h,GL_ONE,GL_ZERO);
	Screen('FillRect',h,col);
	Screen('BlendFunction',h,sfOld,dfOld);
