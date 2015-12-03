function hE = ErrorBars(x,y,err,varargin)
% ErrorBars
% 
% Description:	add error bars to the current figure
% 
% Syntax:	hE = ErrorBars(x,y,err,<options>)
% 
% In:
% 	x	- an N-length cell of x data (one cell entry for each plot)
%	y	- the y data
%	err	- the error data. specify one error value for each y-value for equal
%		  negative and positive errors, or two error values for separate
%		  negative (first) and positive (second) values.
%	<options>:
%		type:		('area') one of the following type of error bars:
%						'area':	show an area around the line indicating the error
%						'bar':	show an error bar at each point
%		color:		(<auto>) a 1x3 color or Nx3 array of colors for error bars
%		autocolor:	(true) true to calculate colors automatically based on the
%					color option
%		barwidth:	(2) the width of error bars
%		cap:		(true) true to place end caps on error bars
% 
% Out:
% 	hE	- an array of handles to the error patches
% 
% Updated:	2015-11-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'type'		, 'area'	, ...
			'color'		, []		, ...
			'autocolor'	, true		, ...
			'barwidth'	, 2			, ...
			'cap'		, true		  ...
			);
	
	opt.type	= CheckInput(opt.type,'error type',{'area','bar'});

%massage the input
	[x,y,err]	= ForceCell(x,y,err);
	[x,y,err]	= FillSingletonArrays(x,y,err);
	
	nPlot	= numel(x);
	kPlot	= reshape(1:nPlot,size(x));
	
	[x,y,err]	= cellfun(@ReshapeData,x,y,err,'uni',false);

%draw the errors
	colErr	= GetErrorColors;
	
	switch opt.type
		case 'area'
			hE	= cellfun(@DrawErrorArea,x,y,err,num2cell(kPlot));
		case 'bar'
			%the cap width
				strUnits	= get(gca,'Units');
				set(gca,'Units','Pixels');
				pAxis		= get(gca,'Position');
				set(gca,'Units',strUnits);
				xRng	= range(get(gca,'XLim'));
				lCap	= ((opt.barwidth+2)/4)*10/pAxis(3)*xRng;
			
			hE	= cellfun(@DrawErrorBar,x,y,err,num2cell(kPlot),'uni',false);
	end

%-------------------------------------------------------------------------------
function [x,y,err] = ReshapeData(x,y,err)
%reshape data to Nx1 and make sure we have + and - values for error bars
	se	= size(err);
	sx	= size(x);
	sx	= [sx ones(1,numel(se) - numel(sx))];
	
	if ~isempty(err)
		if any(sx~=se)
			kDim	= find(se~=sx);
			assert(numel(kDim)==1,'dimension mismatch');
			assert(se(kDim)==2 && sx(kDim)==1,'no more than two error values can be specified for each y-value');
			
			[x,y,err]	= varfun(@(z) permute(z,[1:kDim-1 kDim+1:numel(sx) kDim]),x,y,err);
			err			= reshape(err,[],2);
		else
			err	= repmat(reshape(err,[],1),[1 2]);
		end
	end
	
	x	= reshape(x,[],1);
	y	= reshape(y,[],1);
end
%------------------------------------------------------------------------------%
function colErr = GetErrorColors
	switch opt.type
		case 'area'
			if ~isempty(opt.color)
				if opt.autocolor
					fColErr	= 8;
					nY		= size(opt.color,1);
					
					hsvCol	= rgb2hsv(opt.color);
					errH	= hsvCol(:,1);
					errS	= hsvCol(:,2)./fColErr;
					%errV	= hsvCol(:,3);
					%errV	= .9*(1-errV) + errV.*fColErr.*(errV);
					errV	= ones(nY,1) - abs(1-errS).^fColErr./fColErr;
					hsvErr	= min(1,[errH errS errV]);
					colErr	= hsv2rgb(hsvErr);
				else
					colErr	= opt.color;
				end
			else
				colErr	= [0 0 0];
			end
			
			opt.color	= repto(opt.color,[nPlot 3]);
			colErr		= repto(colErr,[nPlot 3]);
		case 'bar'
			colErr	= repto(unless(opt.color,[0 0 0]),[nPlot 3]);
	end
end%-------------------------------------------------------------------------------
function h = DrawErrorArea(x,y,err,kP)
	if isempty(err)
		h	= NaN;
		return;
	end
	
	fErrEdgeCol	= 0.25;
	
	%interpolate missing data
		for kD=1:2
			bNaN	= isnan(err(:,kD));
			if any(bNaN)
				if all(bNaN)
					err(:,kD)	= 0;
				else
					err(bNaN,kD)	= interp1(x(~bNaN),err(~bNaN,kD),x(bNaN));
				end
			end
		end
	
	%draw the patch
		xE	= [x; reverse(x)];
		yE	= [y+err(:,2); reverse(y-err(:,1))];
		
		h	= patch(xE,yE,colErr(kP,:));
		
		colEdge	= (1-fErrEdgeCol)*colErr(kP,:) + fErrEdgeCol*opt.color(kP,:);
		set(h,'EdgeAlpha',1,'EdgeColor',colEdge);
	
	%move the errors to the back
		MoveToBack(gca,h);
end
%-------------------------------------------------------------------------------
function h = DrawErrorBar(x,y,err,kP)
	if isempty(err)
		h	= NaN;
		return;
	end
	
	bKeep		= ~isnan(x) & ~isnan(y) & ~any(isnan(err),2);
	[x,y,err]	= varfun(@(v) v(bKeep,:),x,y,err);
	nBar		= numel(x);
	
	xMin	= x - lCap/2;
	xMax	= x + lCap/2;
	yMin	= y - err(:,1);
	yMax	= y + err(:,2);
	
	h	= [];
	
	for kB=1:nBar
		if opt.cap
			xLine	= [xMin(kB)	x(kB)		xMin(kB); xMax(kB)	x(kB)		xMax(kB)];
			yLine	= [yMin(kB)	yMin(kB)	yMax(kB); yMin(kB)	yMax(kB)	yMax(kB)];
		else
			xLine	= [x(kB);		x(kB)];
			yLine	= [yMin(kB);	yMax(kB)];
		end
		
		h	= [h; line(xLine,yLine,'LineWidth',opt.barwidth,'Color',colErr(kP,:),'Clipping','off')];
	end
	hold off;
end
%-------------------------------------------------------------------------------

end
