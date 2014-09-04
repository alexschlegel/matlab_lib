function x = GetPointer(mag)
% PTB.Device.Pointer.MagicTouch.GetPointer
% 
% Description:	get some magictouch info
% 
% Syntax:	x = GetPointer(mag)
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

bAlt	= PTBIFO.magictouch.button.alt;

x	= GetPointer@PTB.Device.Pointer(mag);

rect	= PTBIFO.window.rect.main;
sz		= rect(3:4) - rect(1:2);

%get the magictouch state
	[px,py,but,focus,v,vInfo]	= GetMouse([],mag.deviceid);
	
	x(mag.IDX_XPOS)	= (v(1)-vInfo(1).min)./(vInfo(1).max-vInfo(1).min);
	x(mag.IDX_YPOS)	= (v(2)-vInfo(2).min)./(vInfo(2).max-vInfo(2).min);
	
	mtBut	= but(1);
%get the draw state
	%was a button pressed?
		bNewButton	= false;
		
		switch PTBIFO.magictouch.button.mode
			case 'de'
			%toggle between draw and erase mode
				if mag.parent.Input.DownOnce('left',false) || (bAlt && mag.key.DownOnce('left',false))
				%switch modes
					[mag.modelast,modeCur]	= deal(conditional(mag.modelast==mag.MODE_ERASE,mag.MODE_DRAW,mag.MODE_ERASE));
				else
					modeCur	= mag.modelast;
				end
				
				switch modeCur
					case mag.MODE_DRAW
						x(mag.IDX_DRAW)		= mtBut;
						x(mag.IDX_ERASE)	= 0;
					case mag.MODE_ERASE
						x(mag.IDX_DRAW)		= 0;
						x(mag.IDX_ERASE)	= mtBut;
				end
			case 'mde'
			%toggle between move, draw, and erase modes
				if mag.parent.Input.DownOnce('right',false) || (bAlt && mag.key.DownOnce('right',false))
				%new right button!
					but			= mag.BUT_RIGHT;
					bNewButton	= true;
				elseif mag.parent.Input.DownOnce('left',false) || (bAlt && mag.key.DownOnce('left',false))
				%new left button!
					but			= mag.BUT_LEFT;
					bNewButton	= true;
				else
				%no new buttons
					but	= mag.butlast;
				end
			
				if bNewButton
					if mag.butlast==but
					%was the same button pressed twice?
						but	= mag.BUT_NONE;
					end
					
					mag.butlast	= but;
				end
				
				switch but
					case mag.BUT_LEFT
						x(mag.IDX_DRAW)		= mtBut;
						x(mag.IDX_ERASE)	= 0;
					case mag.BUT_RIGHT
						x(mag.IDX_DRAW)		= 0;
						x(mag.IDX_ERASE)	= mtBut;
					case mag.BUT_NONE
						x([mag.IDX_DRAW mag.IDX_ERASE])	= 0;
				end
		end
