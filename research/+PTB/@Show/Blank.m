function Blank(shw,varargin)
% PTB.Show.Blank
% 
% Description:	blank the screen
% 
% Syntax:	shw.Blank(<options>)
% 
% In:
% 	<options>:
%		window:		('main') the name of the window to blank, or the handle to
%					a window
%		fixation:	(<true if window is 'main'>) true to show the fixation
% 
% Updated: 2011-12-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if numel(varargin)>1
	opt	= ParseArgs(varargin,...
			'window'	, 'main'	, ...
			'fixation'	, []		  ...
			);

	bMain	= isequal(opt.window,'main');
	bHidden	= ~bMain && isequal(opt.window,'hidden');

	opt.fixation	= unless(opt.fixation,bMain);
else
	opt.window		= 'main';
	opt.fixation	= true;
	
	bMain	= true;
	bHidden	= false;
end

h	= shw.parent.Window.Get(opt.window);

%blank the screen
	col	= shw.parent.Color.Get(conditional(bHidden,'none','background'));
	
	[sfOld,dfOld]	= Screen('BlendFunction',h,GL_ONE,GL_ZERO);
	Screen('FillRect',h,col);
	Screen('BlendFunction',h,sfOld,dfOld);
%optionally add a fixation point
	if opt.fixation
		if bMain
			shw.Fixation;
		else
			shw.Fixation('window',opt.window);
		end
	end
