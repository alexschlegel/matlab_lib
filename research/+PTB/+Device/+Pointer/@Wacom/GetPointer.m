function x = GetPointer(wac)
% PTB.Device.Pointer.Wacom.GetPointer
% 
% Description:	get some info about the wacom device
% 
% Syntax:	x = wac.GetPointer
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= GetPointer@PTB.Device.Pointer(wac);

%determine which pointing mode is being used
	s	= p_GetStylus(wac);
	
	if s.x~=wac.last.stylus.x || s.y~=wac.last.stylus.y || s.p~=wac.last.stylus.p || s.tx~=wac.last.stylus.tx || s.ty~=wac.last.stylus.ty
	%stylus mode
		wac.last.mode			= 1;
		wac.last.eraser.button	= 0;
		
		wac.last.stylus	= s;
	else
		s	= p_GetEraser(wac);
		
		if s.x~=wac.last.eraser.x || s.y~=wac.last.eraser.y || s.p~=wac.last.eraser.p || s.tx~=wac.last.eraser.tx || s.ty~=wac.last.eraser.ty
		%eraser mode
			wac.last.mode			= 2;
			wac.last.stylus.button	= 0;
			
			wac.last.eraser	= s;
		else
			s	= p_GetTouch(wac);
			
			if s.x~=wac.last.touch.x || s.y~=wac.last.touch.y
			%touch mode
				wac.last.mode			= 3;
				wac.last.stylus.button	= 0;
				wac.last.eraser.button	= 0;
				
				wac.last.touch	= s;
			else
			%use the last mode
				switch wac.last.mode
					case 1
						s	= wac.last.stylus;
					case 2
						s	= wac.last.eraser;
					case 3
						s	= wac.last.touch;
				end
			end
		end
	end

x(	[wac.IDX_XPOS	wac.IDX_YPOS	wac.IDX_PRESSURE	wac.IDX_XTILT	wac.IDX_YTILT	wac.IDX_DRAW			wac.IDX_ERASE])	= ...
	[s.x			s.y				s.p					s.tx			s.ty			wac.last.stylus.button	wac.last.eraser.button];
