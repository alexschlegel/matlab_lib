function Open(win)
% PTB.Window.Open
% 
% Description:	open the windows
% 
% Syntax:	win.Open
% 
% Updated: 2011-12-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%open the main window
	OpenVisible('main');
%open a hidden window for temporary drawing
	OpenHidden('hidden');
%open a hidden window for copying the main window
	OpenHidden('copy');

%------------------------------------------------------------------------------%
function OpenVisible(strName)
%open a visible window
	
	%get the window position info
		kMonitor	= win.parent.Info.Get('window','monitor');
		pWindow		= win.parent.Info.Get('window','position');
		sWindow		= win.parent.Info.Get('window','size');
		
		[rect,kScreen]	= p_GetRect(kMonitor,pWindow,sWindow);
	%set the visual debug level
		vLevel	= conditional(win.parent.Info.Get('window','visualdebug'),4,0);
		Screen('Preference','VisualDebugLevel', vLevel);
	%skip sync tests
		vSkipSync	= double(win.parent.Info.Get('window','skipsynctests'));
		Screen('Preference','SkipSyncTests',vSkipSync);
	%set the screentohead parameter?
		if isequal(strName,'main')
			sth	= win.parent.Info.Get('window','screentohead');
		
			if ~isempty(sth)
				Screen('Preference','ScreenToHead',kScreen,0,sth);
			end
		end
	%set some properties
		win.parent.Info.Set('window','refreshrate',Screen('FrameRate',kScreen));
	%open the window
		col	= win.parent.Color.Get('background');
		h	= Screen('OpenWindow',kScreen,col,rect);
		
% 		PsychImaging('PrepareConfiguration');%***
% 		PsychImaging('AddTask','General','UseVirtualFramebuffer');
% 		h=PsychImaging('OpenWindow',kScreen,col,rect);
		
		win.Set(strName,h);
		
		win.AddLog(['opened ' strName]);
	%set the alpha blending mode
		Screen('BlendFunction',h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
end
%------------------------------------------------------------------------------%
function OpenHidden(strName)
% open a hidden window based on the main window
	col		= win.parent.Color.Get('background',0);
	
	hMain	= win.parent.Info.Get('window',{'h','main'});
	hHidden	= Screen('OpenOffscreenWindow',hMain,col);
	
	Screen('BlendFunction',hHidden,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	win.Set(strName,hHidden);
end
%------------------------------------------------------------------------------%

end
