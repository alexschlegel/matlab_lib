function im = Capture(win,varargin)
% PTB.Window.Capture
% 
% Description:	capture the current main window contents to an image file
% 
% Syntax:	win.Capture([strPathOut]=<no save>)
%
% In:
%	[strPathOut]	- the path either to an image file or the directory in which
%					  to save the image file
% 
% Updated: 2014-06-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%capture the window contents
	h	= PTBIFO.window.h;
	im	= Screen('GetImage',h.main);

%save to file
	if numel(varargin)>0
		strPathOut	= varargin{1};
		
		%get the output file path
		[strDirOut,strFileOut,strExtOut]	= PathSplit(strPathOut);
		
		if isempty(strFileOut)
			strPathOut	= PathUnsplit(strDirOut,num2str(round(PTB.Now)),'png');
		end
		
		imwrite(im,strPathOut);
	end

%add a log entry
	win.parent.AddLog('capture');
