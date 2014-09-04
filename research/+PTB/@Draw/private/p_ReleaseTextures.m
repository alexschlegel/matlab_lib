function p_ReleaseTextures(drw)
% p_ReleaseTextures
% 
% Description:	release the textures that PTB.Draw uses
% 
% Syntax:	p_ReleaseTextures(drw)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
drw.parent.Window.CloseTexture('draw_base');
drw.parent.Window.CloseTexture('draw_memory');
