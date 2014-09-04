function p_OpenTextures(drw)
% p_OpenTextures
% 
% Description:	open the textures that PTB.Draw uses
% 
% Syntax:	p_OpenTextures(drw)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
hBase	= drw.parent.Window.OpenTexture('draw_base');
hMemory	= drw.parent.Window.OpenTexture('draw_memory');

Screen('BlendFunction',hBase,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
Screen('BlendFunction',hMemory,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

%set font info
	Screen('TextStyle',hBase,1);
