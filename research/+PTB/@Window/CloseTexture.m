function CloseTexture(win,strName)
% PTB.Window.CloseTexture
% 
% Description:	close a named texture
% 
% Syntax:	win.CloseTexture(strName)
% 
% Updated: 2012-07-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

h	= win.Get(strName);

if ~isempty(h)
	if PTBIFO.window.closetextures
		Screen('Close',h);
	else
		kTexture	= find(PTBIFO.window.texture.h==h);
		PTBIFO.window.texture.active(kTexture)	= false;
	end
	
	if ischar(strName)
		win.parent.Info.Unset('window',{'h',strName});
	end
end
