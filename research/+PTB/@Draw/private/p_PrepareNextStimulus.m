function p_PrepareNextStimulus(drw,tNow,tFlip,tStart)
% p_PrepareNextStimulus
% 
% Description:	prepare the next drawing state
% 
% Syntax:	p_PrepareNextStimulus(drw,tNow,tFlip,tStart)
% 
% In:
% 	drw		- the PTB.Draw object
%	tNow	- the current time
%	tFlip	- the next flip time
%	tStart	- the start time
% 
% Updated: 2015-11-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO

bKeep	= drw.current.pen.mode>0;

hBase	= PTBIFO.window.h.draw_base;
hMemory	= PTBIFO.window.h.draw_memory;
hMain	= PTBIFO.window.h.main;

%pen position
	sWin		= p_GetWindowSize(drw);
	sPaper		= p_GetPaperSize(drw);
	pwOffset	= (sWin - sPaper)/2;
	
	pPen	= round(drw.current.pen.position);
	
	%constrain to the paper
		pPen	= MapValue(pPen,1,sWin,pwOffset,pwOffset+sPaper);

if bitand(drw.current.pen.mode,PTB.Device.Pointer.MODE_ERASE)
%erase mode
	bPositionHelper	= true;
	
	[im,rCon]	= GetImageErase();
	
	Screen('BlendFunction',hMemory,GL_ZERO,GL_SRC_ALPHA);
elseif bitand(drw.current.pen.mode,PTB.Device.Pointer.MODE_DRAW)
%draw mode
	bPositionHelper	= false;
	
	[im,rCon]	= GetImageDraw();
	
	Screen('BlendFunction',hMemory,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
else
%move mode
	bPositionHelper	= false;
	
	[im,rCon]	= GetImageOff();
	
	Screen('BlendFunction',hMemory,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
end

bIm	= ~isempty(im);

%mode helper
	if PTBIFO.draw.show.mode && (drw.current.pen.mode~=drw.lastmode)
		drw.lastmode	= drw.current.pen.mode;
		
		if bitand(drw.current.pen.mode,PTB.Device.Pointer.MODE_ERASE)
		%erase mode
			strMode	= 'ERASE';
			col		= [255 0 0];
		elseif bitand(drw.current.pen.mode,PTB.Device.Pointer.MODE_DRAW)
		%draw mode
			strMode	= 'DRAW';
			col		= [0 244 0];
		else
		%move mode
			strMode	= 'MOVE';
			col		= [0 0 255];
		end
		
		rect		= PTBIFO.window.rect.draw_base;
		wBox		= 100;
		hBox		= 30;
		x			= rect(3)-wBox;
		y			= 0;
		rectRect	= [x y rect(3) hBox];
		
		Screen('FillRect',hBase,[0 0 0],rectRect);
		Screen('DrawText',hBase,strMode,x+10,y+7,col);
	end
%timer
	if drw.showtimer
		rTimer	= PTBIFO.draw.rate.timer;
		tRemain	= max(0,round(drw.timerleft/(1000/rTimer))*(1000/rTimer));
		
		if tRemain~=drw.lastremain
			drw.lastremain	= tRemain;
			
			p_DrawTimer(drw,hBase,drw.timertotal,tRemain);
		end
	end
%draw stuff
	if bKeep
		%first draw the new image to the memory
			if bIm
				Screen('PutImage',hMemory,im,rCon);
			end
		%now draw the base and memory to the main window
			DrawBase;
			Screen('DrawTexture',hMain,hMemory);
	else
		%draw the base and memory to the main window
			DrawBase;
			Screen('DrawTexture',hMain,hMemory);
		%now draw the new image to the main window
			if bIm
				Screen('PutImage',hMain,im,rCon);
			end
	end
	
	if bPositionHelper
	%help the subject see where the pen is
		Screen('PutImage',hMain,cat(3,im(:,:,1:3),255-im(:,:,4)),rCon);
	end
%debug
% 	if PTBIFO.experiment.debug>1
% 		Screen('DrawText',hMain,['mode: ' num2str(drw.current.pen.mode)],0,0,[128 128 128]);
		
% 		if ~isempty(drw.penhistory)
% 			hst			= cellfun(@(t,x) [num2str(roundn(t-floorn(t,4),0)) ': ' join(x,',')],num2cell(drw.penhistory(:,1)),mat2cell(roundn(drw.penhistory(:,2:end),-3),ones(size(drw.penhistory,1),1),2),'UniformOutput',false);
			
% 			for kH=1:numel(hst)
% 				Screen('DrawText',hMain,hst{kH},0,50*kH,[128 128 128]);
% 			end
% 		end
% 	end

%------------------------------------------------------------------------------%
function [im,rCon] = GetImageOff()
	col	= [0 0 0 255];
	
	if bitand(drw.actualmode,PTB.Device.Pointer.MODE_ERASE)
		pen	= drw.current.erase.shape;
	else
		pen	= drw.current.pen.shape;
	end
	
	szPen	= size(pen);
	
	im	= arrayfun(@(c) c.*pen,double(col),'UniformOutput',false);
	im	= cat(3,im{:});
	
	drw.penhistory	= [];
	
	%the contour image rect
		rCon	= [pPen-szPen/2 pPen+szPen/2];
end
%------------------------------------------------------------------------------%
function [im,rCon] = GetImageDraw()
	im		= [];
	rCon	= [];
	
	col	= drw.current.pen.color;
	pen	= drw.current.pen.shape;
	
	%current pen info
		szPen	= size(pen);
	%add to the history
		nHist	= size(drw.penhistory,1);
		if nHist<3
			drw.penhistory	= [drw.penhistory; drw.current.t pPen];
			nHist			= nHist+1;
			
			%return;
		else
			drw.penhistory	= [drw.penhistory(2:end,:); drw.current.t pPen];
		end
		
		pPen	= round(drw.penhistory(:,2:3));
		pMin	= min(pPen,[],1);
		
		if nHist>2
			kStart	= 2;
		else
			kStart	= 1;
		end
		
		pCon	= pPen - repmat(pMin - szPen([2 1]),[nHist 1]);
		sCon	= 2*szPen + range(pCon(:,[2 1]));
		
		bCon	= contour2im(pCon(:,2),pCon(:,1),...
					'size'	, sCon		, ...
					'start'	, kStart	, ...
					'end'	, nHist		  ...
					);
		bCon	= applypen(bCon,pen);
		
		im	= arrayfun(@(c) c.*bCon,double(col),'UniformOutput',false);
		im	= cat(3,im{:});
	%the contour image rect
		ltCon	= pMin - szPen;
		rCon	= [ltCon ltCon+sCon([2 1])];
end
%------------------------------------------------------------------------------%
function [im,rCon] = GetImageErase()
	col	= [0 0 0 255]; 
	pen	= ~drw.current.erase.shape;
	
	szPen	= size(pen);
	
	im	= arrayfun(@(c) c.*pen,double(col),'UniformOutput',false);
	im	= cat(3,im{:});
	
	drw.penhistory	= [];
	
	%the contour image rect
		rCon	= [pPen-szPen/2 pPen+szPen/2];
end
%------------------------------------------------------------------------------%
function DrawBase()
	%draw the base
		Screen('DrawTexture',hMain,hBase);
	%draw the underlay
		if isa(drw.underlay,'function_handle')
			drw.underlay(PTB.Now,tFlip,hMain);
		end
end
%------------------------------------------------------------------------------%


end
