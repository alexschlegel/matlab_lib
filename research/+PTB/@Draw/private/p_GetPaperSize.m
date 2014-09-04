function sz = p_GetPaperSize(drw)
% p_GetPaperSize
% 
% Description:	get the size of the drawing paper, in pixels
% 
% Syntax:	sz = p_GetPaperSize(drw)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO

sz	= PTBIFO.draw.paper.size;

if ischar(sz)
%use preset
	sz	= CheckInput(sz,'size',{'letter','letter_wide','letter_land','fill'});
	
	rect	= PTBIFO.window.rect.main;
	szWin	= rect(3:4) - rect(1:2);
	
	switch sz
		case 'letter'
			r	= [8.5 11];
		case 'letter_wide'
			r	= [9.5 11];
		case 'letter_land'
			r	= [11 8.5];
		case 'fill'
			r	= szWin;
	end
	
	if szWin(1)/szWin(2) > r(1)/r(2)
		sz	= szWin(2)*[r(1)/r(2) 1];
	else
		sz	= szWin(1)*[1 r(2)/r(1)];
	end
	
	sz	= round(sz);
elseif isnumeric(sz) && numel(sz)==2 && all(sz>=0)
	sz	= reshape(round(sz),1,2);
	
	%convert to pixels
		sz	= drw.parent.Window.va2px(sz);
else
	error('Invalid paper size.');
end
