function p_InitializeDrawing(drw,bFlip)
% p_InitializeDrawing
% 
% Description:	reset the drawing stimulus to its base state
% 
% Syntax:	p_InitializeDrawing(drw,bFlip)
% 
% In:
% 	drw		- the PTB.Draw object
%	bFlip	- true to flip after preparing
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%fill the drawing with the background color
	colBack	= drw.parent.Color.Get('draw_back');
	
	hBase	= drw.parent.Window.Get('draw_base');
	
	Screen('FillRect',hBase,colBack);
%draw the paper
	colPaper	= drw.parent.Color.Get('draw_paper');
	
	sWin	= p_GetWindowSize(drw);
	sPaper	= p_GetPaperSize(drw);
	
	rPaper	= [0 0 sPaper];
	rWin	= drw.parent.Info.Get('window',{'rect','main'});
	sWin	= rWin(3:4) - rWin(1:2);
	
	pCenterWindow	= sWin/2;
	rDest			= CenterRectOnPoint(rPaper,pCenterWindow(1),pCenterWindow(2));
	
	Screen('FillRect',hBase,colPaper,rDest);
%draw the underlay
	if ~isempty(drw.underlay) && ~isa(drw.underlay,'function_handle')
		drw.parent.Show.Image(drw.underlay,'window',hBase);
	end
%blank the drawing
	hMemory	= drw.parent.Window.Get('draw_memory');
	
	Screen('BlendFunction',hMemory,GL_ONE,GL_ZERO);
	Screen('FillRect',hMemory,[0 0 0 0]);
	Screen('BlendFunction',hMemory,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

if bFlip
	hMain	= drw.parent.Window.Get('main');
	
	Screen('CopyWindow',hBase,hMain);
	
	drw.parent.Window.Flip('draw_prepare');
end
