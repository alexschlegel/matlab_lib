function varargout = alexplot(varargin)
% alexplot
% 
% Description:	construct one of the following types of plots:
%					line chart
%					bar graph
%					scatter plot
%					histogram
%					spectrogram
%					confusion
%					connection
% 
% Syntax:	h = alexplot(<x>,<options>)
% 
% In:
% 	<x>	- the values to plot. see the help for the specific type of plot being
%		  constructed.
%	<options>:
%		type:				('line') the type of plot to construct. one of the
%							following strings:  'line', 'bar', 'scatter',
%							'histogram', 'spectrogram', 'confusion'.
%							type help alexplot_<type> for documentation on each
%							type. for type-specific options.
%		style:				('default') a string signifying a default set of
%							options:
%								'default':	use the default options listed here
%								'minimal':	show only essential components (good
%									for subplots)
%								'bare':	display nothing but the plot contents
%		location:			('new') one of the following to specify the location
%							of the plot:
%								'new':	use a new figure
%								{'new',h}:	add a new axes to the current figure
%									in h
%								{'above',h,[f]}:	place the current plot above
%									an existing plot
%									h:	a struct returned by a previous call to
%										alexplot
%									f:	(0.5) the fraction of the old plot to
%										replace with the new plot
%								{'replace',h}:	replace whatever plot is
%									currently in h
%									h:	either a handle to a figure or a struct
%										returned by alexplot
%								h:	same as {'replace',h}
%		title:				(<none>) the plot's title
%		fixtitle:			(true) true to fix the title formatting (TeX
%							formatting can't be used if this is true)
%		xlabel:				(<none>) the x-axis label
%		ylabel:				(<none>) the y-axis label
%		xlabelbottom:		(<auto>) the location of the xlabel bottom
%		ylabelleft:			(<auto>) the location of the ylabel left
%		legend:				(<none>) a cell of legend strings for the plots
%		legendlocation:		('Best') location argument to the legend function
%		legendbox:			('off') 'on' or 'off'
%		legendorientation:	('vertical') the legend orientation
%		showtitle:			(true) true to show the title
%		showlabels:			(true) true to show the text labels
%		showlegend:			(true) true to show the legend
%		showxvalues:		(true) true to show x axis values
%		showyvalues:		(true) true to show y axis values
%		showgrid:			(false) true to show the grid
%		xmin:				(<auto>) the x lower bound (if applicable)
%		xmax:				(<auto>) the x upper bound (if applicable)
%		ymin:				(<auto>) the y lower bound
%		ymax:				(<auto>) the y upper bound
%		axistype:			('L') either 'box', 'L', 'zero', or 'off' to specify
%							how the axes are shown
%		minortick:			(false) true to show minor ticks
%		axiswidth:			(2) the axis width
%		linewidth:			(2) the default line width
%		vlinewidth:			(<linewidth>) vline width(s)
%		hlinewidth:			(<linewidth>) hline width(s)
%		vline:				(<none>) a vector of x values at which vertical
%							lines should be placed
%		vlinestyle:			('-') the vertical line style (see LineStyle
%							property)
%		vlinecolor:			([0.5 0.5 0.5]) vertical line color.  either one
%							color or an nLine x 3 array of colors
%		hline:				(<none>) a vector of y values at which horizontal
%							lines should be placed
%		hlinestyle:			('-') the horizontal line style (see LineStyle
%							property)
%		hlinecolor:			([0.5 0.5 0.5]) horizontal line color.  either one
%							color or an nLine x 3 array of colors
%		xreverse:			(false) true to reverse the x-axis values
%		yreverse:			(false) true to reverse the y-axis values
%		xfactor:			(1) a multiplicative factor for x labels
%		yfactor:			(1) a multiplicative factor for y labels
%		background:			([1 1 1]) the figure background color
%		textcolor:			(<auto>) the color of text
%		font:				('Helvetica') the font to use
%		fontsize:			(1) the font size multiplier
%		fontweight:			('normal') the font weight
%		pgrid:				(4:8) an array of acceptable grid sizes
%		pstep:				([1 2 3 5 10]) an array of acceptable plot tick
%							steps
%		pgridx:				(<pgrid>) the pgrid option for the x-axis
%		pgridy:				(<pgrid>) the pgrid option for the y-axis
%		pstepx:				(<pstep>) the pstep option for the x-axis
%		pstepy:				(<pstep>) the pstep option for the y-axis
%		w:					(<MATLAB default>) the width of the figure
%		h:					(<MATLAB default>) the height of the figure
%		l:					(<MATLAB default>) the left position of the figure
%		t:					(<MATLAB default>) the top position of the figure
%		wax:				(0.85) the axes width, normalized to the figure
%							width. only applies if the location option is 'new'
%							or 'replace' (same for hax, lax, and tax).
%		hax:				(0.75) the axes height, normalized to the figure
%							height
%		lax:				(0.11) the axes left position
%		tax:				(0.11) the axes top position
%		show:				(true) true to show the plot, false to hide it
% 
% Out:
% 	h	- a struct of relevant handles and parameters
% 
% Updated:	2015-11-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.


%parse the input
	[x,h.opt,vargin]	= ParseInput(varargin);
%initialize the figure
	InitializeFigure;
%construct the plot
	%each function should:
	%	set x,y,xerr,yerr fields of h.data (at least to {})
	%	set h.hForLegend, array of handles to elements for legend construction
	
	switch h.opt.type
		case 'line'
			h	= alexplot_line(x,h,vargin);
		case 'bar'
			h	= alexplot_bar(x,h,vargin);
		case 'scatter'
			h	= alexplot_scatter(x,h,vargin);
		case 'histogram'
			h	= alexplot_histogram(x,h,vargin);
		case 'spectrogram'
			h	= alexplot_spectrogram(x,h,vargin);
		case 'confusion'
			h	= alexplot_confusion(x,h,vargin);
		case 'connection'
			h	= alexplot_connection(x,h,vargin);
		otherwise
			error(['"' tostring(h.opt.type) '" is not a valid plot type.']);
	end
	
%set some figure properties
	[xLim,yLim,xTick,yTick]	= SetPlotLimits;
	
	VerticalLines;
	HorizontalLines;
	PlotGridLines;
	
	SetTitle;
	SetAxisLabels;
	
	SetAxis;
	
	SetLegend;
%move the gridlines to the back
	if isfield(h,'hGridHB')
		MoveToBack(h.hA,[h.hGridHB;h.hGridHS]);
	end
%post functions
	if ~isempty(GetFieldPath(h.opt,'fpost'))
		h.opt.fpost(h);
	end
%add another background for plot2svg
	if ~isequal(h.opt.background,[1 1 1]) && h.opt.extraback
		h.hABack	= axes;
		MoveToBack(h.hF,h.hABack);
		set(h.hABack,'Position',[0 0 1 1],'XTick',[],'YTick',[],'Color',h.opt.background,'XColor',h.opt.background,'YColor',h.opt.background);
	end
%return
	if nargout>0
		varargout{1}	= h;
	end


%------------------------------------------------------------------------------%
function [x,opt,vargin] = ParseInput(v)
	kChar	= unless(find(cellfun(@ischar,v),1,'first'),numel(v)+1);
	
	x		= v(1:kChar-1);
	
	%get the plot style
		strStyle	= getfield(ParseArgs(v,'style','default'),'style');
		optD		= GetStyleDefaults(strStyle);
		
	opt	= ParseArgs(v(kChar:end),...
			'type'				, 'line'			, ...
			'style'				, 'default'			, ...
			'location'			, 'new'				, ...
			'title'				, ''				, ...
			'fixtitle'			, true				, ...
			'xlabel'			, ''				, ...
			'ylabel'			, ''				, ...
			'xlabelbottom'		, []				, ...
			'ylabelleft'		, []				, ...
			'legend'			, {}				, ...
			'legendlocation'	, 'Best'			, ...
			'legendbox'			, 'off'				, ...
			'legendorientation'	, 'vertical'		, ...
			'showtitle'			, optD.showtitle	, ...
			'showlabels'		, optD.showlabels	, ...
			'showlegend'		, optD.showlegend	, ...
			'showxvalues'		, optD.showxvalues	, ...
			'showyvalues'		, optD.showyvalues	, ...
			'showgrid'			, []				, ...
			'xmin'				, []				, ...
			'xmax'				, []				, ...
			'ymin'				, []				, ...
			'ymax'				, []				, ...
			'axistype'			, optD.axistype		, ...
			'minortick'			, false				, ...
			'axiswidth'			, optD.axiswidth	, ...
			'linewidth'			, 2					, ...
			'vlinewidth'		, []				, ...
			'hlinewidth'		, []				, ...
			'vline'				, []				, ...
			'vlinestyle'		, '-'				, ...
			'vlinecolor'		, [0.5 0.5 0.5]		, ...
			'hline'				, []				, ...
			'hlinestyle'		, '-'				, ...
			'hlinecolor'		, [0.5 0.5 0.5]		, ...
			'xreverse'			, false				, ...
			'yreverse'			, false				, ...
			'xfactor'			, 1					, ...
			'yfactor'			, 1					, ...
			'background'		, [1 1 1]			, ...
			'extraback'			, true				, ...
			'textcolor'			, []				, ...
			'font'				, 'Helvetica'		, ...
			'fontsize'			, 1					, ...
			'fontweight'		, 'normal'			, ...
			'pgrid'				, 4:8				, ...
			'pstep'				, [1 2 3 5 10]		, ...
			'pgridx'			, []				, ...
			'pgridy'			, []				, ...
			'pstepx'			, []				, ...
			'pstepy'			, []				, ...
			'w'					, []				, ...
			'h'					, []				, ...
			'l'					, []				, ...
			't'					, []				, ...
			'wax'				, 0.85				, ...
			'hax'				, 0.75				, ...
			'lax'				, 0.11				, ...
			'tax'				, 0.11				, ...
			'show'				, true				  ...
			);
	opt.minortick	= unless(opt.minortick,~opt.showgrid);
	
	%show grid?
		opt.showgrid	= unless(opt.showgrid,conditional(isequal(opt.type,'confusion'),false,optD.showgrid));
	
	%extra options
		vargin	= v;
	
	%colors
		opt.background	= str2rgb(opt.background);
		opt.textcolor	= str2rgb(unless(opt.textcolor,GetGoodTextColor(opt.background)));
		opt.vlinecolor	= str2rgb(opt.vlinecolor);
		opt.hlinecolor	= str2rgb(opt.hlinecolor);
	
	%fix the title
		if opt.fixtitle
			opt.title	= FixTitle(opt.title);
		end
	%format line options
		nVLine	= FormatOptLine('v');
		nHLine	= FormatOptLine('h');
	%format the legend array
		opt.legend	= ForceCell(opt.legend);
	%options the subfunctions might change
		opt.setplotlimits		= true;
	%pgrid/pstep
		opt.pgridx	= unless(opt.pgridx,opt.pgrid);
		opt.pgridy	= unless(opt.pgridy,opt.pgrid);
		opt.pstepx	= unless(opt.pstepx,opt.pstep);
		opt.pstepy	= unless(opt.pstepy,opt.pstep);
	%--------------------------------------------------------------------------%
	function optD = GetStyleDefaults(strStyle)
		switch lower(strStyle)
			case 'default'
				optD	= struct(...
							'showtitle'		, true	, ...
							'showlabels'	, true	, ...
							'showlegend'	, true	, ...
							'showxvalues'	, true	, ...
							'showyvalues'	, true	, ...
							'showgrid'		, false	, ...
							'axistype'		, 'L'	, ...
							'axiswidth'		, 2		  ...
							);
			case 'minimal'
				optD	= struct(...
							'showtitle'		, false	, ...
							'showlabels'	, false	, ...
							'showlegend'	, false	, ...
							'showxvalues'	, false	, ...
							'showyvalues'	, false	, ...
							'showgrid'		, false	, ...
							'axistype'		, 'L'	, ...
							'axiswidth'		, 2		  ...
							);
			case 'bare'
				optD	= struct(...
							'showtitle'		, false	, ...
							'showlabels'	, false	, ...
							'showlegend'	, false	, ...
							'showxvalues'	, false	, ...
							'showyvalues'	, false	, ...
							'showgrid'		, false	, ...
							'axistype'		, 'off'	, ...
							'axiswidth'		, 0.1	  ...
							);		otherwise
				error(['"' tostring(strStyle) '" is not a valid plot style.']);
		end
	end
	%--------------------------------------------------------------------------%
	function nLine = FormatOptLine(strLinePrefix)
		strLineBase		= [strLinePrefix 'line'];
		strLineWidth	= [strLineBase 'width'];
		strLineStyle	= [strLineBase 'style'];
		strLineColor	= [strLineBase 'color'];
		
		nLine				= numel(opt.(strLineBase));
		opt.(strLineWidth)	= unless(opt.(strLineWidth),opt.linewidth);
		opt.(strLineWidth)	= repto(reshape(opt.(strLineWidth),[],1),[nLine 1]);
		opt.(strLineStyle)	= ForceCell(opt.(strLineStyle));
		opt.(strLineStyle)	= repto(reshape(opt.(strLineStyle),[],1),[nLine 1]);
		opt.(strLineColor)	= GetPlotColors(nLine,'color',opt.(strLineColor),'fill','last');
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function InitializeFigure
	[strLocation,optL]	= ParseLocation(h.opt.location);
	
	%set the figure and axes
		switch strLocation
			case 'new'
				strShow	= conditional(h.opt.show,'on','off');
				
				if isempty(optL.f)
					h.hF	= figure('Visible',strShow);
				else
					h.hF	= figure(optL.f);
					
					set(h.hF,'Visible',strShow);
				end
				h.hA	= axes;
				
				MoveElement(h.hA,'w',h.opt.wax,'h',h.opt.hax,'l',h.opt.lax,'t',h.opt.tax);
			case 'above'
				h.hF	= optL.h.hF;
				
				pOld	= GetElementPosition(optL.h.hA);
				pNew	= MoveElement(optL.h.hA,'h',pOld.h*(1-optL.f),'b',pOld.b,'stretch',true);
				
				h.hA	= axes;
				p		= MoveElement(h.hA,'b',pNew.b+pNew.h,'h',pOld.h-pNew.h,'l',pNew.l,'w',pNew.w);
				
				if isfield(optL.h,'hTitle')
					h.opt.title		= optL.h.hTitle;
					h.opt.showtitle	= isequal(get(h.opt.title,'visible'),'on');
				end
			case 'replace'
				switch get(optL.h,'Type')
					case 'figure'
						h.hF	= optL.h;
						delete(get(h.hF,'Children'));
						h.hA	= axes;
					case 'axes'
						h.hF	= get(optL.h,'Parent');
						h.hA	= optL.h;
						%delete(setdiff(get(h.hF,'Children'),h.hA));
				end
				
				MoveElement(h.hA,'w',h.opt.wax,'h',h.opt.hax,'l',h.opt.lax,'t',h.opt.tax);
		end
	%set figure/axes properties
		%figure position
			MoveElement(h.hF,'w',h.opt.w,'h',h.opt.h,'l',h.opt.l,'t',h.opt.t);
			
			p		= get(h.hF,'Position');
			p(3)	= unless(h.opt.w,p(3));
			p(4)	= unless(h.opt.h,p(4));
			set(h.hF,'Position',p);
		%background color
			set(h.hF,'Color',h.opt.background);
			set(h.hA,'Color',h.opt.background);
		%text colors
			set(h.hA,'XColor',h.opt.textcolor);
			set(h.hA,'YColor',h.opt.textcolor);
		%font stuff
			set(h.hA,'FontName',h.opt.font);
			set(h.hA,'FontWeight','normal');
			set(h.hA,'FontSize',10*h.opt.fontsize);
		
	
	%--------------------------------------------------------------------------%
	function [strLocation,optL] = ParseLocation(cLocation)
		cLocation	= ForceCell(cLocation);
		cLocation	= conditional(ischar(cLocation{1}),cLocation,['replace' cLocation(1)]);
		
		strLocation	= lower(cLocation{1});
		switch strLocation
			case 'new'
				optL.f	= ParseArgs(cLocation(2:end),[]);
				if isstruct(optL.f)
					optL.f	= optL.f.hF;
				end
			case 'above'
				optL.f	= ParseArgs(cLocation(3:end),0.5);
				optL.h	= cLocation{2};
			case 'replace'
				if isstruct(cLocation{2})
					optL.h	= h.hF;
				else
					optL.h	= cLocation{2};
				end
			otherwise
				error(['"' cLocation{1} '" is not a valid plot location.']);
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function [xLim,yLim,xTick,yTick] = SetPlotLimits()
%we want limits
%	1) whose endpoints divide the step value
%	2) whose range divides one of the values in pGrid
%	3) that contain all data points
	if ~h.opt.setplotlimits
		xLim	= get(h.hA,'XLim');
		yLim	= get(h.hA,'YLim');
		xTick	= get(h.hA,'XTick');
		yTick	= get(h.hA,'YTick');
		
		if h.opt.showxvalues
			strTick	= arrayfun(@num2str,h.opt.xfactor.*xTick,'UniformOutput',false);
			set(h.hA,'XTickLabel',strTick);
		end
		if h.opt.showyvalues
			strTick	= arrayfun(@num2str,h.opt.yfactor.*yTick,'UniformOutput',false);
			set(h.hA,'YTickLabel',strTick);
		end
	else
		[xLim,yLim,xTick,yTick] = GetPlotLimits;
		
		[xLim,xTick] = SetBounds('x',xLim,xTick);
		[yLim,yTick] = SetBounds('y',yLim,yTick);
	end
	
	%--------------------------------------------------------------------------%
	function [xLim,yLim,xTick,yTick] = GetPlotLimits()
	%an array of acceptable numbers of grid cells
		nGrid	= numel(h.opt.pgrid);
	%possible step values (at the order of the maximum-magnitude value)
		nStep	= numel(h.opt.pstep);
	%get the data limits
		[xMin,xMax]	= GetDataRange('x');
		[yMin,yMax]	= GetDataRange('y');
	%get the tightest-fit limits based on opt.pgrid and opt.pstep
		[xMin,xMax,xStep]	= GetTightestLimit(xMin,xMax,'x');
		[yMin,yMax,yStep]	= GetTightestLimit(yMin,yMax,'y');
	%construct the output
		[xLim,xTick]	= ConstructLimits(xMin,xMax,xStep,h.opt.xmin,h.opt.xmax);
		[yLim,yTick]	= ConstructLimits(yMin,yMax,yStep,h.opt.ymin,h.opt.ymax);
	end
	%--------------------------------------------------------------------------%
	function [mn,mx] = GetDataRange(strAxis)
	v	= h.data.(strAxis);
	err	= h.data.([strAxis 'err']);
	
	%get the extrema
		if ~isempty(err)
			vMin	= nanmin(cellfun(@(x,e) unless(min(x-e(:,1)),NaN),v,err));
			vMax	= nanmax(cellfun(@(x,e) unless(max(x+e(:,2)),NaN),v,err));
		else
			vMin	= nanmin(cellfun(@(x) unless(min(x),NaN),v));
			vMax	= nanmax(cellfun(@(x) unless(max(x),NaN),v));
		end
	%get the range
		mn	= unless(h.opt.([strAxis 'min']),vMin);
		mx	= unless(h.opt.([strAxis 'max']),vMax);
	end
	%--------------------------------------------------------------------------%
	function [mn,mx,step] = GetTightestLimit(mn,mx,strAxis)
	%for each grid/step pair, make sure we can span the data range
		if isempty(mn) || isempty(mx)
			step	= [];
			return;
		end
		
		pGrid	= h.opt.(['pgrid' strAxis]);
		pStep	= h.opt.(['pstep' strAxis]);
		
		nGrid	= numel(pGrid);
		nStep	= numel(pStep);
		
		pGrid	= repmat(reshape(pGrid,1,[]),[nStep 1]);
		pStep	= repmat(reshape(pStep,[],1),[1 nGrid]);
		
		pStepNeeded	= (mx-mn)./pGrid;
		pStepMult	= 10.^(ceil(log10(pStepNeeded./pStep)));
		
		pStep	= pStep.*pStepMult;
	%get the possible step values
		%mStep	= 10.^(round(log10(mx - mn))-1);
		%pStep	= reshape(h.opt.pstep.*mStep,1,[]);
	%try each grid/step pair and see which one gives us the tightest fit
% 		pGrid	= reshape(h.opt.pgrid,[],1);
% 		nGrid	= numel(pGrid);
% 		nStep	= numel(pStep);
		
		%the greatest number less than mn that divides the step value
			pMin	= pStep.*floor(mn./pStep);
			%pMin	= repmat(pStep.*floor(mn./pStep),[nGrid 1]);
		%get the corresponding maximum
			pMax	= pMin + pGrid.*pStep;
		%does the lower limit give us a large enough range?
			pRange	= conditional(pMax>=mx,pMax-pMin,NaN);
	%use the grid and step with the smallest range
		[kS,kG]	= find(pRange==nanmin(pRange(:)),1);
		
		if isempty(kS)
			step	= NaN;
		else
			step	= pStep(kS,kG);
		end
		
		mn	= step*floor(mn/step);
		mx	= mn + pGrid(kS,kG)*step;
	end
	%--------------------------------------------------------------------------%
	function [lim,tick] = ConstructLimits(mn,mx,step,mnForce,mxForce)
	lim		= [mn mx];
	tick	= mn:step:mx;
	%fill in forced values
		if ~isempty(mnForce)
			lim(1)	= mnForce;
			
			dTick			= tick - mnForce;
			kClose			= find(dTick<=0,1,'last');
			if isempty(kClose)
				kClose==1;
			end
			
			tick			= tick(kClose:end);
			tick(kClose)	= mnForce;
		end
		if ~isempty(mxForce)
			lim(2)	= mxForce;
			
			dTick			= tick - mxForce;
			kClose			= find(dTick>=0,1,'first');
			tick			= tick(1:kClose);
			tick(kClose)	= mxForce;
		end
	%make pretty
		if ~isempty(tick)
			tick	= roundPretty(tick);
		end
	end
	%--------------------------------------------------------------------------%
	function [lim,tick] = SetBounds(strAxis,lim,tick)
		lim		= roundn(lim,-6);
		tick	= roundn(tick,-6);
		
		if ~isempty(h.opt.([strAxis 'min']))
			lim(1)	= roundn(h.opt.([strAxis 'min']),-6);
			tick	= [lim(1) tick(tick>lim(1))];
		end
		if ~isempty(h.opt.([strAxis 'max']))
			lim(end)	= roundn(h.opt.([strAxis 'max']),-6);
			tick		= [tick(tick<lim(end)) lim(end)];
		end
		
		if any(isnan(lim))
			lim		= [0 1];
			tick	= [0 1];
		end
		
		lim		= roundn(lim,-6);
		tick	= roundn(tick,-6);
		
		if ~isempty(lim)
			set(h.hA,[strAxis 'Lim'],lim);
		end
		if ~isempty(tick)
			set(h.hA,[strAxis 'Tick'],tick);
		end
		
		f		= h.opt.([strAxis 'factor']);
		strTick	= conditional(h.opt.(['show' strAxis 'values']),num2str(f.*tick'),[]);
		vTick	= conditional(h.opt.(['show' strAxis 'values']),tick,[]);
		set(h.hA,[strAxis 'TickLabel'],strTick,[strAxis 'Tick'],vTick);
		
		
		if h.opt.([strAxis 'reverse'])
			set(h.hA,[strAxis 'Dir'],'reverse');
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function SetAxis()
	set(h.hA,'XColor',h.opt.textcolor);
	set(h.hA,'YColor',h.opt.textcolor);
	set(h.hA,'Color',h.opt.background);
	
	axes(h.hA);
	
	switch lower(h.opt.axistype)
		case 'box'
			yLine	= [[yLim(1);yLim(2)] [yLim(2);yLim(2)] [yLim(1);yLim(1)] [yLim(1);yLim(2)]];
			xLine	= [[xLim(1);xLim(1)] [xLim(1);xLim(2)] [xLim(1);xLim(2)] [xLim(2);xLim(2)]];
			h.hBox	= line(xLine,yLine,'Color',h.opt.textcolor,'LineWidth',h.opt.axiswidth,'Clipping','off');
			
			set(h.hA,'linewidth',h.opt.axiswidth);
		case 'l'
			set(h.hA,'box','off');
			
			if ~isempty(xLim) && ~isempty(yLim)
				if h.opt.yreverse
					xLine	= [[xLim(1);xLim(1)] [xLim(1);xLim(2)]];
					yLine	= [[yLim(1);yLim(2)] [yLim(2);yLim(2)]];
				else
					xLine	= [[xLim(1);xLim(1)] [xLim(1);xLim(2)]];
					yLine	= [[yLim(1);yLim(2)] [yLim(1);yLim(1)]];
				end
				
				h.hBox	= line(xLine,yLine,'Color',h.opt.textcolor,'LineWidth',h.opt.axiswidth,'Clipping','off');
			end
			
			set(h.hA,'linewidth',h.opt.axiswidth);
		case 'zero'
			set(h.hA,'XColor',h.opt.background);
			set(h.hA,'box','off');
			
			if ~isempty(xLim) && ~isempty(yLim)
				xLine	= [[xLim(1);xLim(1)] [xLim(1);xLim(2)]];
				yLine	= [[yLim(1);yLim(2)] [0;0]];
				
				h.hBox	= line(xLine,yLine,'Color',h.opt.textcolor,'LineWidth',h.opt.axiswidth,'Clipping','off');
			end
			
			set(h.hA,'linewidth',h.opt.axiswidth);
		case 'off'
			set(h.hA,'XColor',h.opt.background);
			set(h.hA,'YColor',h.opt.background);
			MoveToBack(h.hF,h.hA);
			
			h.hBox	= [];
		otherwise
			error(['"' tostring(h.opt.axistype) '" is not a valid axis type.']);
	end
	
	if h.opt.minortick
		set(h.hA,'XMinorTick','on');
		set(h.hA,'YMinorTick','on');
	end
end
%------------------------------------------------------------------------------%
function SetAxisLabels()
	SetAxisLabel('x','b',h.opt.xlabelbottom);
	SetAxisLabel('y','l',h.opt.ylabelleft);
	
	%--------------------------------------------------------------------------%
	function SetAxisLabel(strAxis,strPos,p)
		strLabel	= [strAxis 'label'];
		
		if ~isempty(h.opt.(strLabel))
			strH		= ['h' upper(strAxis) 'label'];
			f			= str2func(strLabel);
			h.(strH)	= f(h.hA,h.opt.(strLabel),'Color',h.opt.textcolor);
			
			set(h.(strH),'FontName',h.opt.font);
			set(h.(strH),'FontWeight',h.opt.fontweight);
			set(h.(strH),'FontSize',12*h.opt.fontsize);
			
			if ~isempty(p)
				MoveElement(h.(strH),strPos,p);
			else
				switch strAxis
					case 'y'
						strUnit	= get(h.(strH),'Units');
						set(h.(strH),'Units','normalized');
						p		= get(h.(strH),'Position');
						p(1)	= p(1) - 0.01;
						set(h.(strH),'Position',p);
						set(h.(strH),'Units',strUnit);
				end
			end
			
			if ~h.opt.showlabels
				set(h.(strH),'visible','off');
			end
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function SetTitle
	if ~isempty(h.opt.title)
		if isnumeric(h.opt.title) && ishandle(h.opt.title)
			h.hTitle	= h.opt.title;
			set(h.hTitle,'Parent',h.hA);
		else
			h.hTitle	= title(h.hA,h.opt.title,'Color',h.opt.textcolor);
		end
		
		set(h.hTitle,'FontName',h.opt.font);
		set(h.hTitle,'FontWeight',h.opt.fontweight);
		set(h.hTitle,'FontSize',16*h.opt.fontsize);
		set(h.hTitle,'Units','normalized');
		pTitle		= get(h.hTitle,'Position');
		pTitle(2)	= 1.01;
		set(h.hTitle,'Position',pTitle);
		
		if ~h.opt.showtitle
			set(h.hTitle,'visible','off');
		end
	end
end
%------------------------------------------------------------------------------%
function VerticalLines()
	nVLine		= numel(h.opt.vline);
	h.hVLine	= NaN(nVLine,1);
	
	axes(h.hA);
	
	for k=1:nVLine
		xLine		= repmat(h.opt.vline(k),size(yLim));
		yLine		= yLim;
		h.hVLine(k)	= line(xLine,yLine,'Color',h.opt.vlinecolor(k,:));
		set(h.hVLine(k),'LineWidth',h.opt.vlinewidth(k),'LineStyle',h.opt.vlinestyle{k});
	end
	
	MoveToBack(h.hA,h.hVLine);
end
%------------------------------------------------------------------------------%
function HorizontalLines()
	nHLine		= numel(h.opt.hline);
	h.hHLine	= NaN(nHLine,1);
	
	axes(h.hA);
	
	for k=1:nHLine
		xLine		= xLim;
		yLine		= repmat(h.opt.hline(k),size(xLim));
		h.hHLine(k)	= line(xLine,yLine,'Color',h.opt.hlinecolor(k,:));
		set(h.hHLine(k),'LineWidth',h.opt.hlinewidth(k),'LineStyle',h.opt.hlinestyle{k});
	end
	
	MoveToBack(h.hA,h.hHLine);
end
%------------------------------------------------------------------------------%
function PlotGridLines()
	set(h.hA,'GridLineStyle','none');
	
	axes(h.hA);
	
	if h.opt.showgrid
		%grid colors
			colGrid1	= 0.75*ones(1,3);
			colGrid2	= 0.9*ones(1,3);
		
		if ~isempty(xTick)
			xStep	= xTick(2) - xTick(1);
		
			%vertical grid positions.  it's a little tricky because the end tick
			%positions might be wonky
				xDiff	= diff(xTick);
				xWhole	= mode(xDiff);
				kWhole	= find(abs(xDiff-xWhole)<10*eps);
				xMajor	= xTick([kWhole kWhole(end)+1]);
				xMinor	= xMajor(1:end-1)+xWhole/2;
				nXMajor	= numel(xMajor);
				nXMinor	= numel(xMinor);
				
				ySpanMajor	= [repmat(yLim(1),[1 nXMajor]);repmat(yLim(2),[1 nXMajor])];
				ySpanMinor	= [repmat(yLim(1),[1 nXMinor]);repmat(yLim(2),[1 nXMinor])];
			%vertical major lines
				h.hGridVB	= line([xMajor;xMajor],ySpanMajor,'Color',colGrid1);
			%vertical minor lines
				h.hGridVS	= line([xMinor;xMinor],ySpanMinor,'Color',colGrid2);
			
			MoveToBack(h.hA,[h.hGridVB;h.hGridVS]);
		end
		
		if ~isempty(yTick)
			yStep	= yTick(2) - yTick(1);
			
			%horizontal grid positions
				yDiff	= diff(yTick);
				yWhole	= mode(yDiff);
				kWhole	= find(abs(yDiff-yWhole)<10*eps);
				yMajor	= yTick([kWhole kWhole(end)+1]);
				yMinor	= yMajor(1:end-1)+yWhole/2;
				nYMajor	= numel(yMajor);
				nYMinor	= numel(yMinor);
				
				xSpanMajor	= [repmat(xLim(1),[1 nYMajor]);repmat(xLim(2),[1 nYMajor])];
				xSpanMinor	= [repmat(xLim(1),[1 nYMinor]);repmat(xLim(2),[1 nYMinor])];
			%horizontal major lines
				h.hGridHB	= line(xSpanMajor,[yMajor;yMajor],'Color',colGrid1);
			%horizontal minor lines
				h.hGridHS	= line(xSpanMinor,[yMinor;yMinor],'Color',colGrid2);
		end
	end
end
%------------------------------------------------------------------------------%
function SetLegend()
	if ~isempty(h.opt.legend)
		axes(h.hA);
		
		nLegend	= min(numel(h.opt.legend),numel(h.hForLegend));
		
		if nLegend>0
			h.hLegend	= legend(h.hForLegend(1:nLegend),h.opt.legend(1:nLegend),'Location',h.opt.legendlocation,'Orientation',h.opt.legendorientation);
			
			if isequal(h.opt.legendbox,'off')
				if h.opt.showgrid
					set(h.hLegend,'XColor',h.opt.background,'YColor',h.opt.background);
				else
					set(h.hLegend,'box',h.opt.legendbox);
				end
			end
			
			hChildren	= get(h.hLegend,'Children');
			nChildren	= numel(hChildren);
			for kC=1:nChildren
				if isequal(get(hChildren(kC),'type'),'text')
					set(hChildren(kC),'FontName',h.opt.font,'FontWeight',h.opt.fontweight,'FontSize',10*h.opt.fontsize,'Color',h.opt.textcolor);
				end
			end
			
			
		else
			h.hLegend	= [];
		end
	end
end
%------------------------------------------------------------------------------%

end
