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
%	err	- the error data
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
% Updated:	2012-05-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'type'		, 'area'	, ...
		'color'		, []		, ...
		'autocolor'	, true		, ...
		'barwidth'	, 2			, ...
		'cap'		, true		  ...
		);

[x,y,err,opt.cap]	= FillSingletonArrays(ForceCell(x),ForceCell(y),ForceCell(err),ForceCell(opt.cap));
bError				= ~cellfun(@isempty,err);

if any(bError)
	hE	= NaN(numel(x),1);
	
	[x,y,err]	= varfun(@(v) cellfun(@(z) reshape(z,[],1),v(bError),'UniformOutput',false),x,y,err);
	nPlot		= numel(x);
	kError		= find(bError);
	
	switch lower(opt.type)
		case 'area'
			%parameters
				fErrEdgeCol	= 0.25;
			%error bar colors
				colErr	= GetErrorColors;
				
			for kP=1:nPlot
				%linearly interpolate missing data
					bNaN	= isnan(err{kP});
					if any(bNaN)
						if all(bNaN)
							err{kP}(:)	= 0;
						else
							err{kP}(bNaN)	= interp1(x{kP}(~bNaN),err{kP}(~bNaN),x{kP}(bNaN));
						end
						
						err{kP}(isnan(err{kP}))	= 0;
					end
				%draw the patch
					xE				= [x{kP}; reverse(x{kP})];
					yE				= [y{kP}+err{kP}; reverse(y{kP}-err{kP})];
					hE(kError(kP))	= patch(xE,yE,colErr(kP,:));
					
					set(hE(kError(kP)),'EdgeAlpha',1);
					set(hE(kError(kP)),'EdgeColor',(1-fErrEdgeCol)*colErr(kP,:) + fErrEdgeCol*opt.color(kP,:));
			end
			
			%move the errors to the back
				MoveToBack(gca,hE);
		case 'bar'
			colErr	= repto(unless(opt.color,[0 0 0]),[nPlot 3]);
			hE		= num2cell(hE);
			
			for kP=1:nPlot
				hE{kError(kP)}	= DrawErrorBar(x{kP},y{kP},err{kP},colErr(kP,:),opt.cap{kP});
			end
		otherwise
			error(['"' tostring(opt.type) '" is not a valid error bar type.']);
	end
else
	hE	= [];
end
	
	
	
	

%------------------------------------------------------------------------------%
function colErr = GetErrorColors
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
end
%------------------------------------------------------------------------------%
function hE = DrawErrorBar(x,y,err,col,bCap)
	%the cap width
		strUnits	= get(gca,'Units');
		set(gca,'Units','Pixels');
		pAxis		= get(gca,'Position');
		set(gca,'Units',strUnits);
		xRng	= range(get(gca,'XLim'));
		lCap	= ((opt.barwidth+2)/4)*10/pAxis(3)*xRng;
	
	bKeep		= ~isnan(x) & ~isnan(y) & ~isnan(err);
	[x,y,err]	= varfun(@(v) v(bKeep),x,y,err);
	nBar		= numel(x);
	
	xMin	= x - lCap/2;
	xMax	= x + lCap/2;
	yMin	= y - err;
	yMax	= y + err;
	
	hE	= [];
	
	for kB=1:nBar
		if bCap
			xLine	= [xMin(kB)	x(kB)		xMin(kB); xMax(kB)	x(kB)		xMax(kB)];
			yLine	= [yMin(kB)	yMin(kB)	yMax(kB); yMin(kB)	yMax(kB)	yMax(kB)];
		else
			xLine	= [x(kB);		x(kB)];
			yLine	= [yMin(kB);	yMax(kB)];
		end
		
		hE	= [hE; line(xLine,yLine,'LineWidth',opt.barwidth,'Color',col,'Clipping','off')];
	end
	hold off;
end
%------------------------------------------------------------------------------%

end
