function im = p_ConstructImage(drw)
% p_ConstructImage
% 
% Description:	get the finished drawing
% 
% Syntax:	im = p_ConstructImage(drw)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
hMain	= drw.parent.Window.Get('main');

sWin	= p_GetWindowSize(drw);
sPaper	= p_GetPaperSize(drw);

pwOffset	= (sWin - sPaper)/2;
r			= [0 0 sPaper] + [pwOffset pwOffset];

im	= Screen('GetImage',hMain,r);
