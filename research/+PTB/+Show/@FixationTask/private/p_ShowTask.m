function tShow = p_ShowTask(ft)
% p_ShowTask
% 
% Description:	show the current fixation dot on top of whatever was stored
% 
% Syntax:	tShow = p_ShowTask(ft)
% 
% Updated: 2012-01-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if isfield(PTBIFO.window,'h')
	%copy the current buffer to the hidden window
		hMain	= PTBIFO.window.h.main;
		hHidden	= PTBIFO.window.h.hidden;
		Screen('CopyWindow',hMain,hHidden);
	%recall the stored buffer
		ft.parent.Window.Recall;
	%add the fixation dot and flip without storing
		ft.parent.Show.Fixation;
		
		ft.parent.Window.OverrideStore(false);
		tShow	= ft.parent.Window.Flip;
		tShow	= PTB.Now;%weird RTs otherwise
	%copy back the current buffer
		Screen('CopyWindow',hHidden,hMain);
end
