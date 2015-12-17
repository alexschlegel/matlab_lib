function h = alexplot_scatter(x,h,vargin)
% alexplot_scatter
% 
% Description:	plot a scatter plot
% 
% Syntax:	h = alexplot(x,y,'type','scatter',<options>)
% 
% In:
% 	[x]	- an array or cell of arrays of x values corresponding to each y value
%	y	- an array or cell of arrays of y values
% 	<line-specific options>:
%		substyle:			('color') a string to specify the following default
%							options:
%								'color':
%									color:		(see GetPlotColors)
%									marker:		('.')
%									markersize:	(20)
%								'bw':
%									color:		(see GetPlotColors)
%									marker:		('.')
%									markersize	(15)
%		error:				(<none>) a vector or cell of vectors of y-error
%							values
%		errorcap:			(true) true to cap error bars
%		errorcolor:			(<auto>) the colors for error bars
%		color:				(<see subtype>) an Nx3 array of colors to use for
%							plots
%		marker:				(<see substyle>) the marker style(s) (see plot)
%		markersize:			(<see substyle>) the size of point markers, if they
%							are specified
%		bestfit:			(true) true to show best-fit lines
%		bestfit_location:	('southeast') the location of the best-fit text. one
%							if the following: 'south', 'southwest', 'southeast',
%							'northwest', 'northeast', 'center', or 'off'
%		bestfit_color:		(<color>) the best fit line/label color
%		bestfit_background:	(<background>) the best-fit label background color
%		bestfit_size:		(<auto>) the best-fit label font size
%		bestfit_round:		(-3) the power of 10 to which to round the best-fit
%							values
%		bestfit_twotail:	(true) true to calculate a two-tailed p-value for
%							the correlation
% 
% Updated:	2015-10-26
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the extra options
	strStyle	= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	optD		= GetStyleDefaults(strStyle);
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'				, 'color'			, ...
					'error'					, []				, ...
					'errortype'				, 'bar'				, ...
					'errorcap'				, []				, ...
					'errorcolor'			, []				, ...
					'color'					, optD.color		, ...
					'marker'				, optD.marker		, ...
					'markersize'			, optD.markersize	, ...
					'linestyle'				, 'none'			, ...
					'bestfit'				, true				, ...
					'bestfit_location'		, 'southeast'		, ...
					'bestfit_color'			, []				, ...
					'bestfit_background'	, h.opt.background	, ...
					'bestfit_size'			, 12*h.opt.fontsize	, ...
					'bestfit_round'			, -3				, ...
					'bestfit_twotail'		, true				  ...
					));
	h.opt.bestfit_location	= CheckInput(h.opt.bestfit_location,'bestfit_location',{'south','southwest','southeast','northwest','northeast','center','off'});
	h.opt.bestfit_color		= unless(h.opt.bestfit_color,h.opt.color);
%parse the x and y values
	[h.data.x,h.data.y]	= deal(x{:});
	
	h.data.x	= reshape(ForceCell(h.data.x),[],1);
	h.data.y	= reshape(ForceCell(h.data.y),[],1);
	h.data.x	= repto(h.data.x,size(h.data.y));
	
	clear x;
%get the plot colors and markers
	nPlot	= numel(h.data.x);
	
	h.opt.color			= GetPlotColors(nPlot,'color',h.opt.color,'fill','random');
	h.opt.bestfit_color	= GetPlotColors(nPlot,'color',h.opt.bestfit_color,'fill','random');
	h.opt.marker		= GetPlotMarkers(nPlot,'marker',h.opt.marker,'fill',strMarkerFill);
	h.opt.linestyle		= repmat({h.opt.linestyle},[nPlot 1]);
	h.opt.type			= 'line';
	h.opt.location		= h.hA;
%add data for the best fit line plot
	if h.opt.bestfit
		[r,stat]	= cellfun(@(x,y) corrcoef2(reshape(x,[],1),reshape(y,1,[]),'twotail',h.opt.bestfit_twotail),h.data.x,h.data.y,'UniformOutput',false);
		
		xFit	= cellfun(@(x) [min(x) max(x)],h.data.x,'UniformOutput',false);
		yFit	= cellfun(@(x,s) x*s.m+s.b,xFit,stat,'UniformOutput',false);
		eFit	= cellfun(@(y) zeros(size(y)),yFit,'UniformOutput',false);
		
		h.data.x		= [h.data.x; xFit];
		h.data.y		= [h.data.y; yFit];
		
		if ~isempty(h.opt.error)
			h.opt.error		= [ForceCell(h.opt.error); eFit];
		end
		
		h.opt.color		= [h.opt.color; h.opt.bestfit_color];
		h.opt.marker	= [reshape(h.opt.marker,[],1); repmat({'none'},[nPlot 1])];
		h.opt.linestyle	= [h.opt.linestyle; repmat({'-'},[nPlot 1])];
	end
%plot the scatters!
	opt				= h.opt;
	cOpt			= optreplace(opt,'axistype','off');
	h				= alexplot(h.data.x,h.data.y,cOpt{:});
	h.opt			= opt;
	
	if h.opt.bestfit && ~isequal(h.opt.bestfit_location,'off')
		axes(h.hA);
		
		h.hLineLabel	= NaN(nPlot,1);
		for kP=1:nPlot
			strRound			= num2str(h.opt.bestfit_round);
			strLabel			= sprintf(['r=%.' strRound 'f\np=%.' strRound 'f'],r{kP},stat{kP}.p);
			h.hLineLabel(kP)	= text(mean(xFit{kP}),mean(yFit{kP}),strLabel,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',h.opt.bestfit_size,'FontWeight','bold','Color',h.opt.bestfit_color(kP,:),'BackgroundColor',h.opt.bestfit_background);
		end
		
		h.opt.fpost	= @FPost;
	end

%------------------------------------------------------------------------------%
function FPost(h)
	%move the best fit text
		if ~isequal(h.opt.bestfit_location,'center')
			xLim	= get(h.hA,'XLim');
			yLim	= get(h.hA,'YLim');
				
			switch h.opt.bestfit_location
				case 'south'
					xText	= repmat(mean(xLim),[nPlot 1]);
					yText	= repmat(yLim(1) + 0.02*diff(yLim),[nPlot 1]);
					
					ha	= 'center';
					va	= 'bottom';
				case 'southwest'
					xText	= repmat(xLim(1) + 0.02*diff(xLim),[nPlot 1]);
					yText	= repmat(yLim(1) + 0.02*diff(yLim),[nPlot 1]);
					
					ha	= 'left';
					va	= 'bottom';
				case 'southeast'
					xText	= repmat(xLim(2) - 0.02*diff(xLim),[nPlot 1]);
					yText	= repmat(yLim(1) + 0.02*diff(yLim),[nPlot 1]);
					
					ha	= 'right';
					va	= 'bottom';
				case 'northwest'
					xText	= repmat(xLim(1) + 0.02*diff(xLim),[nPlot 1]);
					yText	= repmat(yLim(2) - 0.02*diff(yLim),[nPlot 1]);
					
					ha	= 'left';
					va	= 'top';
				case 'northeast'
					xText	= repmat(xLim(2) - 0.02*diff(xLim),[nPlot 1]);
					yText	= repmat(yLim(2) - 0.02*diff(yLim),[nPlot 1]);
					
					ha	= 'right';
					va	= 'top';
			end
			
			for kP=1:nPlot
				set(h.hLineLabel(kP),'Position',[xText(kP) yText(kP) 0],'HorizontalAlignment',ha,'VerticalAlignment',va);
			end
		end
			
			
	%move the labels to the front
		hParent	= get(h.hLineLabel(end),'Parent');
		
		MoveToFront(hParent,[h.hP(1:nPlot); h.hLineLabel]);
	%move the scatter dots to the front
		MoveToFront(h.hA,h.hP(1));
end
%------------------------------------------------------------------------------%
function optD = GetStyleDefaults(strStyle)
	switch lower(strStyle)
		case 'color'
			optD	= struct(...
						'color'			, 'color'	, ...
						'marker'		, '.'		, ...
						'markersize'	, 20		  ...
						);
			
			strMarkerFill	= 'last';
		case 'bw'
			optD	= struct(...
						'color'			, 'bw'	, ...
						'marker'		, '.'	, ...
						'markersize'	, 15	  ...
						);
			
			strMarkerFill	= 'random';
		otherwise
			error(['"' tostring(strStyle) '" is not a valid scatter plot style.']);
	end
end
%------------------------------------------------------------------------------%

end
