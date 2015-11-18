function h = alexplot_line(x,h,vargin)
% alexplot_line
% 
% Description:	plot a line chart
% 
% Syntax:	h = alexplot([x],y,<options>)
% 
% In:
% 	[x]	- an array or cell of arrays of x values corresponding to each y value
%	y	- an array or cell of arrays of y values
% 	<line-specific options>:
%		substyle:	('color') a string to specify the following default options:
%						'color':
%							errortype:	('area')
%							color:		(see GetPlotColors)
%							marker:		('none')
%						'bw':
%							errortype:	('bar')
%							color:		(see GetPlotColors)
%							marker:		(see GetMarkers)
%		error:		(<none>) a vector or cell of vectors of y-error values
%		errortype:	(<see subtype>) see the ErrorBars 'type' option:
%		errorcap:	(false) true to cap error bars
%		errorcolor:	(<auto>) the colors for error bars
%		sig:		(<don't show>) a boolean vector or cell of vectors
%					signifying which data points are significant in each plot
%		color:		(<see subtype>) an Nx3 array of colors to use for plots
%		linestyle:	('-') the line style(s) (see plot)
%		marker:		(<see subtype>) the marker style(s) (see plot)
%		markersize:	(10) the size of point markers, if they are specified
% 
% Updated:	2015-11-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the extra options
	strStyle	= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	optD		= GetStyleDefaults(strStyle);
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'		, 'color'			, ...
					'error'			, []				, ...
					'errortype'		, optD.errortype	, ...
					'errorcap'		, false				, ...
					'errorcolor'	, []				, ...
					'sig'			, []				, ...
					'color'			, optD.color		, ...
					'linestyle'		, '-'				, ...
					'marker'		, optD.marker		, ...
					'markersize'	, 10				  ...
					));
%parse the x and y values
	switch numel(x)
		case 1
			h.data.y	= x{1};
			h.data.x	= [];
		case 2
			[h.data.x,h.data.y]	= deal(x{:});
		otherwise
			error('Line charts take either one or two numeric arguments.');
	end
	clear x;
	
	[h.data.x,h.data.y,h.data.yerr,h.opt.linestyle]	= ForceCell(h.data.x,h.data.y,h.opt.error,h.opt.linestyle);
	[h.data.x,h.data.y,h.data.yerr,h.opt.linestyle]	= FillSingletonArrays(h.data.x,h.data.y,h.data.yerr,h.opt.linestyle);
	
	h.data.xerr	= [];
	
	%fill in default x values
		h.data.x	= cellfun(@(x,y) unless(x,reshape(1:numel(y),size(y))),h.data.x,h.data.y,'uni',false);
	%reshape the data
		[h.data.x,h.data.y,h.data.yerr]	= cellfun(@ReshapeData,h.data.x,h.data.y,h.data.yerr,'uni',false);
	
	nPlot	= numel(h.data.x);
%fill in the xmin and xmax
	h.opt.xmin	= unless(h.opt.xmin,nanmin(cellfun(@(x) unless(min(x),NaN),h.data.x)));
	h.opt.xmax	= unless(h.opt.xmax,nanmax(cellfun(@(x) unless(max(x),NaN),h.data.x)));
%get the plot colors and markers
	h.opt.color		= GetPlotColors(nPlot,'color',h.opt.color,'fill',strColorFill);
	
	if isequal(h.opt.marker,'none')
		strMarkerFill	= 'last';
	end
	
	h.opt.marker	= GetPlotMarkers(nPlot,'marker',h.opt.marker,'fill',strMarkerFill);
	
	if isequal(h.opt.substyle,'bw') && isequal(h.opt.errortype,'area') && isempty(h.opt.errorcolor)
		h.opt.errorcolor	= [0.9 0.9 0.9];
	end
	
	bAutoColor	= isempty(h.opt.errorcolor);
	colErr		= unless(h.opt.errorcolor,h.opt.color);
%remove missing data
% 	kP=1;
% 	while kP<nPlot
% 		bNaN				= isnan(h.data.x{kP}) | isnan(h.data.y{kP});
% 		h.data.x{kP}(bNaN)	= [];
% 		h.data.y{kP}(bNaN)	= [];
		
% 		if ~isempty(h.data.yerr{kP})
% 			h.data.yerr{kP}(bNaN)	= [];
% 		end
		
% 		if isempty(h.data.x{kP})
% 			h.data.x(kP)	= [];
% 			h.data.y(kP)	= [];
% 			h.data.yerr(kP)	= [];
			
% 			nPlot	= nPlot-1;
% 		else
% 			kP	= kP+1;
% 		end
% 	end
%plot the data
	%I'm getting a segmentation violation here when I make two plots on the
	%same figure.  a short pause helps.  WTF?
		drawnow
	xy				= [reshape(h.data.x,1,[]); reshape(h.data.y,1,[])];
	xy				= cellfun(@(x) unless(x,NaN),xy,'uni',false);
	h.hP			= plot(h.hA,xy{:},'MarkerSize',h.opt.markersize);
	h.hForLegend	= h.hP;
	nPlot			= numel(h.hP);
	clear xy;
	%set series linestyles, colors, and markers
		for kP=1:nPlot
			set(h.hP(kP),'LineStyle',h.opt.linestyle{kP},'Color',h.opt.color(kP,:),'Marker',h.opt.marker{kP});
		end
%line width
	arrayfun(@(x,w) set(x,'LineWidth',w),h.hP,repto(reshape(h.opt.linewidth,[],1),size(h.hP)));
%show significant data points
	AddSignificance;
%plot error bars
	axes(h.hA);
	h.hE	= ErrorBars(h.data.x,h.data.y,h.data.yerr,...
				'type'		, h.opt.errortype	, ...
				'color'		, colErr			, ...
				'autocolor'	, bAutoColor		, ...
				'barwidth'	, h.opt.linewidth	, ...
				'cap'		, h.opt.errorcap	  ...
				);
	if all(cellfun(@isempty,h.data.yerr))
		h.data.yerr	= [];
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
function optD = GetStyleDefaults(strStyle)
	switch lower(strStyle)
		case 'color'
			optD	= struct(...
						'errortype'	, 'area'	, ...
						'color'		, 'color'	, ...
						'marker'	, 'none'	  ...
						);
			
			strColorFill	= 'random';
			strMarkerFill	= 'last';
		case 'bw'
			optD	= struct(...
						'errortype'	, 'bar'	, ...
						'color'		, 'bw'	, ...
						'marker'	, []	  ...
						);
			
			strColorFill	= 'random';
			strMarkerFill	= 'random';
		otherwise
			error(['"' tostring(strStyle) '" is not a valid line plot style.']);
	end
end
%------------------------------------------------------------------------------%
function AddSignificance()
	h.hS	= [];
	
	if ~isempty(h.opt.sig)
		h.opt.sig	= ForceCell(h.opt.sig);
		
		axes(h.hA);
		hold(h.hA,'on');
		
		param	= {'*','LineWidth',h.opt.linewidth,'MarkerSize',h.opt.markersize};
		
		kS	= [];
		for kP=1:nPlot
			if any(h.opt.sig{kP})
				xSig	= h.data.x{kP}(h.opt.sig{kP});
				ySig	= h.data.y{kP}(h.opt.sig{kP});
				
				h.hS	= [h.hS; plot(h.hA,xSig,ySig,param{:})];
				kS		= [kS; kP];
			end
		end
		
		for kP=1:numel(h.hS)
			set(h.hS(kP),'Color',h.opt.color(kS(kP),:));
		end
		
		hold(h.hA,'off');
	end
end
%------------------------------------------------------------------------------%

end
