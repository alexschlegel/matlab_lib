function h = alexplot_bar(x,h,vargin)
% alexplot_bar
% 
% Description:	plot a bar graph
% 
% Syntax:	h = alexplot(y,'type','bar',<options>)
% 
% In:
%	y	- an nGroup x nBar array of bar graph values
% 	<bar-specific options>:
%		substyle:			('color') a string to specify the following default options:
%								'color':
%									color:		(see GetPlotColors)
%								'white':
%									color:		([1 1 1])
%		grouplabel:			(<none>) a cell of labels for each bar group
%		grouplabellocation:	('legend' if bar label location is a number, 0
%							otherwise) the location of the bar group labels.  one
%							of the following:
%								'legend':	place the labels in a legend box
%								n:			place the labels under the grouping,
%											rotated at n degrees
%		barlabel:			(<none>) a cell of labels for each bar.  can either
%							be one set of labels to use for each bar group, or a
%							cell of cells of labels, one for each bar group
%		barlabellocation:	('legend' if one set of bar labels and group label
%							location is not 'legend', otherwise 'in') the
%							location of the bar labels.  one of the following:
%								'legend':	place the labels in a legend box
%								'in':		place the labels in the bars, rotated
%											vertically
%								n:			place the labels under the bars,
%											rotated at n degrees
%		legendorientation:	('horizontal') the legend orientation, either
%							'horizontal' or 'vertical'
%		barlinewidth:		(0) the bar edge width
%		error:				(<none>) an nGroup x nBar[ x 2] array of error
%							values
%		errorcap:			(false) true to cap error bars
%		sig:				(<don't show>) an nGroup x 1 boolean array signifying
%							which groups show significant differences, or an
%							array of p-values, or an nGroup x nBar array to
%							show significance for each bar individually
%		shownsig:			(false) true to indicate non-significant groups
%		sigfont:			('Courier') the font for significance indicators
%		sigweight:			('Bold') the font weight for the significance
%							indicator
%		sigsize:			(18) the font size of the significance indicator
%		dimnsig:			(true) true to dim non-significant bars (only
%							implemented for individual bar significance)
%		sigindicator:		('*') the character to use for indicating
%							significance
%		sigsupercutoff		(4) the star count cutoff for starting to show
%							significance with superscripts
%		color:				(<see subtype>) an nBar x 3 array of bar colors, or
%							an nGroup x nBar x 3 array of colors if a different
%							color is desired for each bar
%		barspace:			(<best>) spacing between each bar, as a fraction of
%							the overall axes width
%		groupspace:			(<best>) spacing between each bar group, as a
%							fraction of the overall axes width
% 
% Updated:	2015-11-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	colEdge	= h.opt.textcolor;
	
	[y,nGroup,nBar,strColorFill,sFont] = ProcessInput;
%get the bar colors
	ProcessBarColors;
%plot the bars
	[xBar,yBar,wBar,hBar]	= PlotBars;
%plot the errors
	AddErrorBars;
%show significant data points
	AddSignificance;
%fix the bar order
	FixChildOrder;
%get the plot limits
	h.opt.setplotlimits	= false;
	[yLim,yTick]		= GetPlotLimits;
%set bounds
	SetBounds;
%add the bar labels
	SetBarLabels;

%set h.data
	[h.data.x,h.data.y]			= varfun(@(v) {reshape(v,[],1)},xBar,yBar);
	[h.data.xerr,h.data.yerr]	= deal([]);

%functions to execute after alexplot does its thing
	h.opt.fpost	= @PostFunc;

%------------------------------------------------------------------------------%
function PostFunc(h)
	MoveToFront(h.hA,h.hB);
	
	if isfield(h,'hLabelBar')
		MoveToFront(h.hA,h.hLabelBar);
	end
	if isfield(h,'hE')
		cellfun(@(hE) MoveToFront(h.hA,hE),h.hE,'UniformOutput',false);
	end
	
	if ~isempty(h.opt.xlabel) && (isnumeric(h.opt.barlabellocation) || isnumeric(h.opt.grouplabellocation))
	%move the x label down a bit
		e		= get(h.hXlabel,'Extent');
		p		= get(h.hXlabel,'Position');
		
		if h.opt.yreverse
			p(2)	= p(2) + e(4)/2;
		else
			p(2)	= p(2) - e(4)/2;
		end
		
		set(h.hXlabel,'Position',p);
	end
	
	%make sure the box is on top
	if ~isempty(h.hBox)
		MoveToFront(h.hA,h.hBox);
	end
end
%------------------------------------------------------------------------------%
function [y,nGroup,nBar,strColorFill,sFont] = ProcessInput()
	y	= x{1};
	
	strStyle			= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	[optD,strColorFill]	= GetStyleDefaults(strStyle);
	
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'				, 'color'			, ...
					'grouplabel'			, {}				, ...
					'grouplabellocation'	, []				, ...
					'barlabel'				, {}				, ...
					'barlabellocation'		, []				, ...
					'legendorientation'		, 'horizontal'		, ...
					'barlinewidth'			, 0					, ...
					'error'					, []				, ...
					'errorcap'				, false				, ...
					'sig'					, []				, ...
					'shownsig'				, false				, ...
					'sigfont'				, 'Courier'			, ...
					'sigweight'				, 'Bold'			, ...
					'sigsize'				, 18				, ...
					'dimnsig'				, true				, ...
					'sigindicator'			, '*'				, ...
					'sigsupercutoff'		, 4					, ...
					'color'					, optD.color		, ...
					'barspace'				, []				, ...
					'groupspace'			, []				  ...
					));
	%reshape the error data
		if ~isempty(h.opt.error)
			sy	= size(y);
			se	= size(h.opt.error);
			
			if sy(2)==1 && se(2)==2
				h.opt.error	= permute(h.opt.error,[1 3 2]);
				se			= [se(1) 1 se(2)];
			end
			
			if se(end)~=2
				h.opt.error	= repmat(h.opt.error,[1 1 2]);
			end
		end
	%process the labels and data
		[h.opt.grouplabel,h.opt.barlabel]	= ForceCell(h.opt.grouplabel,h.opt.barlabel);
		if numel(h.opt.barlabel)>0 && ~iscell(h.opt.barlabel{1})
			h.opt.barlabel	= {h.opt.barlabel};
		end
		nGroupLabelBar	= numel(h.opt.barlabel);
	%get the bar label location
		if isempty(h.opt.grouplabellocation)
			if ~isempty(h.opt.barlabellocation) && isnumeric(h.opt.barlabellocation)
				h.opt.grouplabellocation	= 'legend';
			else
				h.opt.grouplabellocation	= 0;
			end
		end
		if isempty(h.opt.barlabellocation)
			if nGroupLabelBar==1 && ~isequal(h.opt.grouplabellocation,'legend')
				h.opt.barlabellocation	= 'legend';
			else
				h.opt.barlabellocation	= 'in';
			end
		end
	%bar line width
		if h.opt.barlinewidth==0
			h.opt.barlinewidth	= eps;
			colEdge				= 'none';
		end
	%process spacing
		[nGroup,nBar]	= size(y);
		nBarTotal		= nGroup*nBar;
		nSpaceGroup		= nGroup+1;
		nSpaceBar		= nGroup*(nBar-1);
		
		%get the amount of room we have to work with
			wTotal	= 1;
			
			if ~isempty(h.opt.barspace)
				wTotal	= wTotal - h.opt.barspace*nSpaceBar;
			end
			if ~isempty(h.opt.groupspace)
				wTotal	= wTotal - h.opt.groupspace*nSpaceGroup;
			end
		%get the optimal spacing, given the constrains
			wBarMin		= 0.3;
			wBarTotal	= min(wTotal,wBarMin + (1-wBarMin)*nBarTotal.^(2.5)./(nBarTotal.^(2.5)+200));
			wLeft		= wTotal - wBarTotal;
			
			if isempty(h.opt.groupspace)
				if isempty(h.opt.barspace)
					fSpaceBar	= 1/5;
					
					h.opt.groupspace	= wLeft./(nSpaceGroup+nSpaceBar*fSpaceBar);
					h.opt.barspace		= max(0,(wLeft-nSpaceGroup*h.opt.groupspace)./nSpaceBar);
				else
					h.opt.groupspace	= wLeft/nSpaceGroup;
				end
			elseif isempty(h.opt.barspace)
				h.opt.barspace	= conditional(nSpaceBar==0,0,wLeft/nSpaceBar);
			end
	%text parameters
		%sFont	= struct('small',0.05,'medium',0.06,'large',0.075,'huge',0.075);
		sFont	= struct('small',10,'medium',12,'large',18,'huge',18);
	
	%--------------------------------------------------------------------------%
	function [optD,strColorFill] = GetStyleDefaults(strStyle)
		switch lower(strStyle)
			case {'color','bw'}
				optD	= struct(...
							'color'		, lower(strStyle)	  ...
							);
				
				strColorFill	= 'random';
			case 'white'
				optD	= struct(...
							'color'		, [1 1 1]	  ...
							);
				
				strColorFill	= 'last';
			otherwise
				error(['"' tostring(strStyle) '" is not a valid bar plot style.']);
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function ProcessBarColors()
% get the colors to use for bars
	if ~isempty(h.opt.color) && ndims(h.opt.color)==3
	%different for each bar
		h.opt.color	= reshape(h.opt.color,[],3);
		h.opt.color	= GetPlotColors(nGroup*nBar,'color',h.opt.color,'fill',strColorFill);
	elseif nBar==1
	%different for each group
		h.opt.color	= GetPlotColors(nGroup,'color',h.opt.color,'fill',strColorFill);
	else
	%different for each bar within a group
		h.opt.color	= reshape(GetPlotColors(nBar,'color',h.opt.color,'fill',strColorFill),[],1,3);
		h.opt.color	= permute(repmat(h.opt.color,[1 nGroup 1]),[2 1 3]);
		h.opt.color	= reshape(h.opt.color,[],3);
	end
end
%------------------------------------------------------------------------------%
function [xBar,yBar,wBar,hBar] = PlotBars()
	%number of spaces between bars and bar groups
		nSpaceBarPerGroup	= nBar - 1;
		nSpaceBarTotal		= nSpaceBarPerGroup*nGroup;
		nSpaceGroup			= nGroup + 1;
	%width of each bar
		wBar	= (1 - h.opt.groupspace*nSpaceGroup - h.opt.barspace*nSpaceBarTotal)./(nGroup*nBar);
		wGroup	= wBar*nBar + h.opt.barspace*nSpaceBarPerGroup;
	
	%plot each group/bar
		xGroupStart		= repmat(reshape(h.opt.groupspace + (0:nGroup-1)*(h.opt.groupspace + wGroup),[],1),[1 nBar]);
		xInGroupLeft	= repmat(reshape((0:nBar-1)*(wBar+h.opt.barspace),1,[]),[nGroup 1]);
		
		xBarLeft	= reshape(xGroupStart + xInGroupLeft,1,[]);
		xBarRight	= xBarLeft + wBar;
		
		yBarLower	= zeros(1,nBar*nGroup);
		yBarUpper	= reshape(y,1,[]);
		
		xBarPatch	= [xBarLeft;	xBarLeft;	xBarRight;	xBarRight];
		yBarPatch	= [yBarLower;	yBarUpper;	yBarUpper;	yBarLower];
		
		colBarPatch	= reshape(h.opt.color,1,[],3);
		
		%do the bars one at a time.  the x/y-axis lines disappear for some
		%reason if we do them all at once
			nBarTotal	= size(xBarPatch,2);
			h.hB		= zeros(nGroup,nBar);
			for kB=1:nBarTotal
				h.hB(kB)	= patch(xBarPatch(:,kB),yBarPatch(:,kB),colBarPatch(1,kB,:),'LineWidth',h.opt.barlinewidth,'EdgeColor',colEdge);
			end
	%return values
		xBar	= reshape(mean([xBarLeft; xBarRight],1),[nGroup nBar]);
		wBar	= reshape(xBarRight - xBarLeft,[nGroup nBar]);
		yBar	= reshape(yBarUpper,[nGroup nBar]);
		hBar	= reshape(yBarUpper - yBarLower,[nGroup nBar]);
end
%------------------------------------------------------------------------------%
function AddErrorBars()
% add error bars
	if ~isempty(h.opt.error)
		h.hE	= ErrorBars(xBar,yBar,h.opt.error,...
					'type'		, 'bar'				, ...
					'color'		, h.opt.textcolor	, ...
					'barwidth'	, h.opt.linewidth	, ...
					'cap'		, h.opt.errorcap	  ...
					);
		
		%update the y position
			yBar	= yBar + h.opt.error(:,:,2);
			hBar	= yBar - min(0,yBar-h.opt.error(:,:,1));
	end
end
%------------------------------------------------------------------------------%
function AddSignificance()
	if ~isempty(h.opt.sig)
		%get p-values
			pSig	= conditional(islogical(h.opt.sig),double(~h.opt.sig)+0.05,h.opt.sig);
			bSig	= pSig<=0.05;
			
		if h.opt.shownsig
			kShow	= 1:numel(pSig);
		else
			kShow	= find(bSig);
		end
		 
		nShow	= numel(kShow);
		
		strStar		= h.opt.sigindicator;
		starFont	= h.opt.sigfont;
		starWeight	= h.opt.sigweight;
		starSize	= h.opt.sigsize;
		
		%get the height of an indicator
			hTemp		= text(0,0,strStar,'FontName',starFont,'FontSize',starSize,'FontWeight',starWeight,'Units','data');
			tExtentStar	= get(hTemp,'Extent');
			delete(hTemp);
			
			wStar	= tExtentStar(3);
			hStar	= tExtentStar(4);
		
		if size(pSig,2)==size(y,2)
		%inidividual bar significance
			%get the indicator coordinates
				xSig	= xBar;
				ySig	= yBar + hStar/4;
			%add the indicators
				h.hSig	= zeros(nShow,1);
				tExtent	= zeros(nShow,4);
				for kS=1:nShow
					kBar	= kShow(kS);
					
					%add the stars
						if bSig(kBar)
							nStar	= max(1,floor(-log10(pSig(kBar))));
							
							if nStar<h.opt.sigsupercutoff
								strSig		= StringFill('',nStar,strStar);
							else
								if isinf(nStar)
									strSig	= [h.opt.sigindicator '\infty'];
								else
									strSig	= [h.opt.sigindicator num2str(nStar)];
								end
								
								
							end
						else
							strSig	= 'ns';
						end
						
						xSigCur	= double(xSig(kBar));
						ySigCur	= double(ySig(kBar));
						
						h.hSig(kS)		= text(xSigCur,ySigCur,strSig,...
											'FontName'				, starFont			, ...
											'FontWeight'			, starWeight		, ...
											'FontSize'				, starSize			, ...
											'HorizontalAlignment'	, 'left'			, ...
											'VerticalAlignment'		, 'middle'			, ...
											'Color'					, h.opt.textcolor	, ...
											'Rotation'				, 90				  ...
											);
						tExtent(kS,:)	= get(h.hSig(kS),'Extent');
					%update the y positions
						hBar(kBar)	= hBar(kBar) + tExtent(kS,4);
						yBar(kBar)	= ySig(kBar) + tExtent(kS,4);
				end
			%dim the non-significant bars
				if h.opt.dimnsig
					kNoShow	= find(~bSig);
					nNoShow	= numel(kNoShow);
					
					for kN=1:nNoShow
						kBar	= kNoShow(kN);
						
						colBar			= get(h.hB(kBar),'FaceColor');
						colBarHSV		= rgb2hsl(colBar);
						colBarHSV(2)	= colBarHSV(2)/3;
						colBarHSV(3)	= colBarHSV(3) + 2*(1-colBarHSV(3))/3;
						colBarNew		= hsl2rgb(colBarHSV);
						
						set(h.hB(kBar),'FaceColor',colBarNew);
					end
				end
		elseif size(pSig,2)==1
		%group significance
			%get the indicator coordinates
				xSigLeft	= reshape(xBar(:,1)-wBar(:,1)/2,1,[]);
				xSigRight	= reshape(xBar(:,end)+wBar(:,end)/2,1,[]);
				xSigCenter	= mean([xSigLeft; xSigRight]);
				ySigLL		= reshape(yBar(:,1),1,[]);
				ySigLR		= reshape(yBar(:,end),1,[]);
				
				ySigU	= reshape(max(yBar,[],2) + hStar,1,[]);
			%add the indicators
				h.hSig	= zeros(nShow,1);
				tExtent	= zeros(nShow,4);
				for kS=1:nShow
					kGroup	= kShow(kS);
					
					%update the y positions
						hBar(kGroup,:)	= hBar(kGroup,:) + (ySigU(kGroup) - yBar(kGroup,:));
						yBar(kGroup,:)	= ySigU(kGroup);
					%add the stars
						if bSig(kGroup)
							nStar	= max(1,floor(-log10(pSig(kGroup))));
							
							if nStar<h.opt.sigsupercutoff
								strSig	= StringFill('',nStar,strStar);
							else
								strSig	= [h.opt.sigindicator num2str(nStar)];
							end
						else
							strSig	= 'ns';
						end
						
						xSig	= double(xSigCenter(kGroup));
						ySig	= double(ySigU(kGroup));
						
						h.hSig(kS)		= text(xSig,ySig,strSig,...
											'FontName'				, starFont			, ...
											'FontSize'				, starSize			, ...
											'FontWeight'			, starWeight		, ...
											'HorizontalAlignment'	, 'center'			, ...
											'VerticalAlignment'		, 'middle'			, ...
											'Color'					, h.opt.textcolor	  ...
											);
						
						tExtent(kS,:)	= get(h.hSig(kS),'Extent');
				end
			%add the frames
				xOffset	= wStar;
				%yOffset	= conditional(bSig(kShow),hStar/3,hStar/5);
				yOffset	= hStar/5;
				
				xSigLeft	= xSigLeft(kShow);
				xSigRight	= xSigRight(kShow);
				
				ySigLL	= ySigLL(kShow);
				ySigLR	= ySigLR(kShow);
				ySigU	= reshape(tExtent(:,2) + yOffset,1,[]);
				
				xLine	= [xSigLeft xSigLeft xSigRight; xSigLeft xSigRight xSigRight];
				yLine	= [ySigLL ySigU ySigU; ySigU ySigU ySigLR];
				
				h.hSigFrame	= line(xLine,yLine,'Color',h.opt.textcolor,'LineWidth',h.opt.linewidth/2);
		else
			error('WTF significance?');
		end
	end
end
%------------------------------------------------------------------------------%
function FixChildOrder()
	MoveToFront(h.hA,h.hB);
	
	if isfield(h,'hE')
		cellfun(@(he) MoveToFront(h.hA,he),h.hE,'UniformOutput',false);
	end
end
%------------------------------------------------------------------------------%
function [yLim,yTick] = GetPlotLimits()
%we want limits
%	1) whose endpoints divide the step value
%	2) whose range divides one of the values in pGrid
%	3) that contain all data points

	%an array of acceptable numbers of grid cells
		nGrid	= numel(h.opt.pgrid);
	%possible step values (at the order of the maximum-magnitude value)
		nStep	= numel(h.opt.pstep);
	%get the data limits
		if isempty(h.opt.ymin)
			yMin	= min(reshape(yBar - hBar,[],1));
			
			%something strange is happening every once in a while with yMins
			%slightly below zero
				if abs(yMin)<0.001*max(yBar(:))
					yMin	= 0;
				end
		else
			yMin	= h.opt.ymin;
		end
		if isempty(h.opt.ymax);
			yMax	= max(yBar(:))*1.05;
			
			%pad for the legend
				if isequal(h.opt.grouplabellocation,'legend') || isequal(h.opt.barlabellocation,'legend') && ~isempty(strfind(lower(h.opt.legendlocation),'north')) && isempty(strfind(lower(h.opt.legendlocation),'outside'))
					yMax	= 1.1*yMax;
				end
		else
			yMax	= h.opt.ymax;
		end
	%get the tightest-fit limits based on opt.pgrid and opt.pstep
		[yMin,yMax,yStep]	= GetTightestLimit(yMin,yMax);
	%construct the output
		[yLim,yTick]	= GetLimits(yMin,yMax,yStep,h.opt);
	
	%--------------------------------------------------------------------------%
	function [mn,mx,step] = GetTightestLimit(mn,mx)
		%for each grid/step pair, make sure we can span the data range
		pGrid	= h.opt.(['pgridy']);
		pStep	= h.opt.(['pstepy']);
		
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
	function [lim,tick] = GetLimits(mn,mx,step,opt)
		lim		= [mn mx];
		tick	= mn:step:mx;
		
		%fill in forced values
			if ~isempty(opt.ymin)
				lim(1)	= opt.ymin;
				
				dTick			= tick - opt.ymin;
				kClose			= find(dTick<=0,1,'last');
				if isempty(kClose)
					kClose==1;
				end
				
				tick			= tick(kClose:end);
				tick(kClose)	= opt.ymin;
			end
			if ~isempty(opt.ymax)
				lim(2)	= opt.ymax;
				
				dTick			= tick - opt.ymax;
				kClose			= find(dTick>=0,1,'first');
				tick			= tick(1:kClose);
				tick(kClose)	= opt.ymax;
			end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function SetBarLabels()
% set the bar labels
	%get the vertical padding
		hTemp	= text(0,0,'M','FontName',h.opt.font,'FontSize',sFont.small,'Rotation',90);
		tExtent	= get(hTemp,'Extent');
		delete(hTemp);
		
		vPad	= 0.5*tExtent(4);
	
	h.opt.legend	= {};
	h.hForLegend	= [];
	
	%group labels
		if ~isempty(h.opt.grouplabel)
			if ischar(h.opt.grouplabellocation)
				switch h.opt.grouplabellocation
					case 'legend'	%labels in legend
						h.hForLegend	= [h.hForLegend; h.hB(:,1)];
						h.opt.legend	= [h.opt.legend; reshape(h.opt.grouplabel,[],1)];
					otherwise
						error(['"' h.opt.grouplabellocation '" is not a recognized group label location.']);
				end
			else %put each group label below the group at the specified rotation
				h.hLabelGroup	= zeros(nGroup,1);
				for kG=1:nGroup
					%get the x center of the group
						xCenter	= (xBar(kG,1)+xBar(kG,end))/2;
					%draw the text
						h.hLabelGroup(kG)	= text(0,0,[h.opt.grouplabel{kG} ' '],'Color',h.opt.textcolor,'Rotation',h.opt.grouplabellocation,'VerticalAlignment','top','HorizontalAlignment','right','FontName',h.opt.font,'FontWeight',h.opt.fontweight,'FontSize',10*h.opt.fontsize);
						p					= GetElementPosition(h.hLabelGroup(kG));
					%move it so the upper right is under the center of the group
						pTextB	= yLim(1) - 0.01*diff(yLim);
						pTextL	= xCenter + (p.w/2)*(90-1.75*h.opt.grouplabellocation)/90;
						MoveElement(h.hLabelGroup(kG),'b',pTextB,'l',pTextL);
				end
			end
		end
	%bar labels
		if ~isempty(h.opt.barlabel)
			if ischar(h.opt.barlabellocation)
				switch h.opt.barlabellocation
					case 'legend'
						if nGroup>0 && numel(h.opt.barlabel)==1
							hB			= h.hB(1,:);
							cLabelBar	= h.opt.barlabel{1};
						else
							hB			= h.hB';
							cLabelBar	= cellfun(@(x) reshape(x,1,[]),h.opt.barlabel,'UniformOutput',false);
							cLabelBar	= reshape([cLabelBar{:}],size(hB));
						end
						
						h.hForLegend	= [h.hForLegend; reshape(hB,[],1)];
						h.opt.legend	= [h.opt.legend; reshape(cLabelBar,[],1)];
					case 'in'
						if nGroup>0 && numel(h.opt.barlabel)==1
							%find the group with the largest minimum
								%get the smallest of each group
									ySmallest	= min(y,[],2);
								%get the largest of the smallest
									[yLargest,kGroup]	= max(ySmallest);
							
							h.hLabelBar	= zeros(nBar,1);
							for kB=1:nBar
								h.hLabelBar(kB)	= text(xBar(kGroup,kB),yBar(kGroup,kB)-hBar(kGroup,kB)+vPad,h.opt.barlabel{1}{kB},'Color',h.opt.textcolor,'FontName',h.opt.font,'FontWeight',h.opt.fontweight,'FontSize',10*h.opt.fontsize,'Rotation',90);
							end
						else
							h.hLabelBar	= zeros(nGroup,nBar);
							for kG=1:nGroup
								for kB=1:nBar
									h.hLabelBar(kG,kB)	= text(xBar(kG,kB),yBar(kG,kB)-hBar(kG,kB)+vPad,h.opt.barlabel{kG}{kB},'Color',h.opt.textcolor,'FontName',h.opt.font,'FontWeight',h.opt.fontweight,'FontSize',sFont.small,'Rotation',90);
								end
							end
						end
					otherwise
						error(['"' h.opt.barlabellocation '" is not a recognized bar label location.']);
				end
			else %put each bar label below the bar at the specified rotation
				if nGroup>0 && numel(h.opt.barlabel)==1
					kGroup	= 1;
				else
					kGroup	= 1:nGroup;
				end
				nGroupLabel	= numel(kGroup);
				
				h.hLabelBar	= zeros(nGroupLabel,nBar);
				for kG=kGroup
					for kB=1:nBar
						%get the x center of the bar
							xCenter	= xBar(kG,kB);
						%draw the text
							h.hLabelBar(kG,kB)	= text(0,0,[h.opt.barlabel{kG}{kB} ' '],'Color',h.opt.textcolor,'Rotation',h.opt.barlabellocation,'VerticalAlignment','top','HorizontalAlignment','right','FontName',h.opt.font,'FontSize',sFont.small);
							p					= GetElementPosition(h.hLabelBar(kG,kB));
						%move it so the upper right is under the center of the group
							pTextB	= yLim(1) - 0.01*diff(yLim);
							pTextL	= xCenter + (p.w/2)*(90-1.75*h.opt.barlabellocation)/90;
							MoveElement(h.hLabelBar(kG,kB),'b',pTextB,'l',pTextL);
					end
				end
			end
		end
end
%------------------------------------------------------------------------------%
function SetBounds()
		if ~isempty(h.opt.ymin)
			yLim(1)	= h.opt.ymin;
			yTick	= [h.opt.ymin yTick(yTick>h.opt.ymin)];
		end
		if ~isempty(h.opt.ymax)
			yLim(end)	= h.opt.ymax;
			yTick		= [yTick(yTick<h.opt.ymax) h.opt.ymax];
		end
		
		if any(isnan(yLim))
			yLim	= [0 1];
			yTick	= [0 1];
		end
		
		hBar	= hBar - yLim(1);
		
		set(h.hA,'YLim',yLim);
		set(h.hA,'YTick',yTick);
		
		set(h.hA,'XLim',[0 1]);
		set(h.hA,'XTick',[]);
		h.opt.showxvalues	= false;
		
		strYTick	= conditional(h.opt.showyvalues,num2str(yTick'),[]);
		set(h.hA,'YTickLabel',strYTick);
		if h.opt.yreverse
			set(h.hA,'YDir','reverse');
		end
end
%------------------------------------------------------------------------------%

end
