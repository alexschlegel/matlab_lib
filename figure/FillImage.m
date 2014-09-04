function sAxes = FillImage(hA,varargin)
% FillImage
% 
% Description:	fill the axes to fit the figure, get rid of the ticks
% 
% Syntax:	FillImage(hA,[sFigure]=<keep>,[bSquare]=false)
% 
% In:
% 	hA			- handle to the axes
%	[sFigure]	- resize the figure, s is either a scalar (square) or a two-element
%				  (w,h) array
%	[bSquare]	- true to scale the axes to be square
%
% Out:
%	sAxes	- the new image size
% 
% Side-effects:	centers the figure on the screen
% 
% Updated:	2008-10-17
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
hF	= get(hA,'Parent');
pF	= get(hF,'Position');

%parse the arguments
	[sFigure,bSquare]	= ParseArgs(varargin,pF(3:4),false);
	if numel(sFigure)==1
		sFigure	= [sFigure sFigure];
	end

%center the figure
	[wS,hS]	= GetScreenResolution();
	set(hF,'Position',[(wS-sFigure(1))/2 (hS-sFigure(2))/2 sFigure(1) sFigure(2)]);

%set the axes limits
	xLim	= get(hA,'XLim');
	yLim	= get(hA,'YLim');
	if bSquare
		newLim	= [min([xLim(1) yLim(1)]) max([xLim(2) yLim(2)])];
		set(hA,'XLim',newLim);
		set(hA,'YLim',newLim);
		
		sAxes	= newLim(2) - newLim(1);
	else
		sAxes	= [yLim(2)-yLim(1) xLim(2)-xLim(1)];
	end

%get rid of ticks
	set(hA,'XTick',[]);
	set(hA,'YTick',[]);
	set(hA,'XColor',[1 1 1]);
	set(hA,'YColor',[1 1 1]);

%fill the figure
	set(hA,'Position',[0 0 1 1]);
