function h = alexplot_connection(x,h,vargin)
% alexplot_connection
% 
% Description:	plot a connection figure
% 
% Syntax:	h = alexplot(C,'type','connection',<options>)
% 
% In:
% 	C	- an N x N array, or a cell of N x N arrays, each of which specifies the
%		  connection values between N elements. uses the lower diagonal values.
%		  if diagonal elements are non-NaN, then they are treated as inherent
%		  values to display for each element.
% 	<line-specific options>:
%		substyle:			('color') a string to specify the following default
%							options:
%								'color':
%									lut:	'random'
%								'bw':
%									lut:	'grayscale'
%		label:				(<auto>) an Nx1 cell specifying the label of each
%							element
%		position:			(<auto>) an Nx1 character array specifying the
%							location of each element on the figure, as one of
%							the following:
%								'l':	left side
%								'r':	right side
%								't':	top side
%								'b':	bottom side
%		sig:				(<nothing>) a logical array / cell of logical arrays
%							specifying which connections are significant, or an
%							array cell of arrays of p-values for each
%							connection. non-significant connections are not
%							shown.
%		sigcorr:			(<nothing>) the same as sig, but specifying
%							corrected significance/p-values, in which case
%							connections that pass sig but not sigCorr are shown
%							translucent
%		pcutoff:			(0.05) the cutoff for significance
%		cmin:				(<auto>) the value to map to the bottom of the
%							color palette (or an array of values, one for each
%							input matrix)
%		cmax:				(<auto>) the value to map to the top of the color
%							palette (or an array of values, one for each input
%							matrix)
%		lut:				(<see substyle>) the look up table of colors to use
%							for the connection plot (see MakeLUT), or a cell of
%							the above for multiple connection plots
%		arcwidth:			(2*<linewidth>) the width of the arcs. either a
%							scalar or 'scale' to scale the widths based on
%							connection strength
%		arcwidthmin:		(1) the minimum arc width
%		arcwidthmax:		(8) the maximum arc width
%		colorbar:			(true) true to show a colorbar
%		wcolorbar:			(0.5) the width of the colorbar axes, in inches
%		scalelabel:			(<none>) the value label for the colorbar scale
%		alpha:				(1) the alpha of displayed connections
%		alphadim:			(<alpha>/5) the alpha of dimmed connections
%		ring_radius:		(0.85) the normalized radius of the ring
%		ring_phase:			(0) the phase offset of the ring positions, in
%							radians
%		group_padding:		(pi/6) the padding between position groups, in
%							radians
%		label_padding:		(0.02) the padding between the connections and the
%							labels
%		box_padding_h:		(0.03) the padding between labels and horizontal box
%							edges
%		box_padding_v:		(0) the padding between labels and vertical box
%							edges
%		innerbackground:	(<background>) the background color inside the
%							connection plot
%		arcmethod:			('patch') the method to use for drawing arcs:
%								'patch':	use patches
%								'line':	use lines. does not support
%										transparency.
%		nstep:				(1000) the number of steps for drawing each shape
%
% Examples:
%		N=10; pos=repmat('lr',[N/2 1]); h = alexplot(rand(N),'type','connection','position',pos);
%		N=10; nPlot=2; c=arrayfun(@(n) rand(N),1:nPlot,'uni',false); sig=cellfun(@(c) c>0.5,c,'uni',false); sigcorr=cellfun(@(c) c>0.7,c,'uni',false); h = alexplot(c,'sig',sig,'sigcorr',sigcorr,'type','connection','lut',{'statistic','statistic2'},'cmin',0,'cmax',1);
%		N=20; p=rand(N); pos=repmat('lrtb',[N/4 1]); lbl=arrayfun(@(n) genname,(1:N)','uni',false); h = alexplot(rand(N),'type','connection','label',lbl,'position',pos,'lut','red','sig',p>0.9,'sigcorr',p>0.95,'colorbar',false,'ring_radius',0.2);
% 
% Updated: 2014-05-13
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the extra options
	strStyle	= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	optD		= GetStyleDefaults(strStyle);
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'			, 'color'		, ...
					'label'				, []			, ...
					'position'			, []			, ...
					'sig'				, []			, ...
					'sigcorr'			, []			, ...
					'pcutoff'			, 0.05			, ...
					'axiswidth'			, 0				, ...
					'lax'				, 0.03			, ...
					'tax'				, 0.06			, ...
					'wax'				, 0.94			, ...
					'hax'				, 0.94			, ...
					'cmin'				, []			, ...
					'cmax'				, []			, ...
					'lut'				, []			, ...
					'arcwidth'			, []			, ...
					'arcwidthmin'		, 1				, ...
					'arcwidthmax'		, 8				, ...
					'colorbar'			, true			, ...
					'wcolorbar'			, 0.5			, ...
					'scalelabel'		, []			, ...
					'alpha'				, 1				, ...
					'alphadim'			, []			, ...
					'ring_radius'		, 0.85			, ...
					'ring_phase'		, 0				, ...
					'group_padding'		, pi/6			, ...
					'label_padding'		, 0.02			, ...
					'box_padding_h'		, 0.03			, ...
					'box_padding_v'		, 0				, ...
					'innerbackground'	, []			, ...
					'arcmethod'			, 'patch'		, ...
					'nstep'				, 1000			  ...
					));
	
	h.opt.alphadim			= unless(h.opt.alphadim,h.opt.alpha/5);
	h.opt.innerbackground	= str2rgb(unless(h.opt.innerbackground, h.opt.background));
	h.opt.arcmethod			= CheckInput(h.opt.arcmethod,'arc method',{'patch','line'});
	
	h.opt.arcwidth	= unless(h.opt.arcwidth,2*h.opt.linewidth);
	
	bArcWidthScale	= isequal(h.opt.arcwidth,'scale');
	
	switch h.opt.arcmethod
		case 'patch'
			fArc			= @PatchArcInterior;
			
			if ~bArcWidthScale
				h.opt.arcwidth	= h.opt.arcwidth/200;
			else
				h.opt.arcwidthmin	= h.opt.arcwidthmin/200;
				h.opt.arcwidthmax	= h.opt.arcwidthmax/200;
			end
		case 'line'
			fArc	= @LineArcInterior;
	end
	
	h.opt.axistype	= 'off';
	
	sFont	= struct('small',10,'medium',12,'large',18,'huge',18);
	sFont	= structfun2(@(s) s*h.opt.fontsize,sFont);
	
	[xMin,yMin]	= deal(-1);
	[xMax,yMax]	= deal(1);
%parse the connection values
	[h.data.x, h.data.y, h.data.xerr, h.data.yerr]	= deal({});
	
	h.data.C	= x{1};
	
	[h.data.C, h.data.sig, h.data.sigcorr, h.opt.lut, h.opt.cmin, h.opt.cmax, h.opt.label]	= ForceCell(h.data.C, h.opt.sig, h.opt.sigcorr, h.opt.lut, h.opt.cmin, h.opt.cmax, h.opt.label);
	[h.data.C, h.data.sig, h.data.sigcorr, h.opt.cmin, h.opt.cmax, h.opt.alpha, h.opt.alphadim]	= FillSingletonArrays(h.data.C, h.data.sig, h.data.sigcorr, h.opt.cmin, h.opt.cmax, h.opt.alpha, h.opt.alphadim);
	
	nPlot	= numel(h.data.C);
	
	sz	= cellfun(@size,h.data.C,'uni',false);
	N	= sz{1}(1);
	
	if ~all(cellfun(@(x) isequal(x,[N N]) || isequal(x,[0 0]),sz))
		error(sprintf('All connection arrays must be %d x %d',N,N));
	end
	
	%parse the significance
		szSig	= cellfun(@size,h.data.sig,'uni',false); 
		if ~all(cellfun(@(x) isequal(x,[N N]) || isequal(x,[0 0]),szSig))
			error(sprintf('All specified significance arrays must be %d x %d',N,N));
		end
		
		h.data.sig	= cellfun(@ProcessSignificance,h.data.sig,'uni',false);
	
	%parse the corrected significance
		szSigCorr	= cellfun(@size,h.data.sigcorr,'uni',false);
		if ~all(cellfun(@(x) isequal(x,[N N]) || isequal(x,[0 0]),szSigCorr))
			error(sprintf('All specified corrected significance arrays must be %d x %d',N,N));
		end
		
		h.data.sigcorr	= cellfun(@ProcessSignificance,h.data.sigcorr,h.data.sig,'uni',false);
	
	kPairSub	= handshakes(1:N);
	kPair		= sub2ind([N N],kPairSub(:,2),kPairSub(:,1));
	nPair		= numel(kPair);
	kDiag		= find(logical(eye(N)));
	
	h.opt.cmin	= cellfun(@(mn,C) unless(mn,nanmin(C(:))),h.opt.cmin,h.data.C);
	h.opt.cmax	= cellfun(@(mx,C) unless(mx,nanmax(C(:))),h.opt.cmax,h.data.C);
	
	h.opt.label	= repto(reshape(h.opt.label,[],1),[N 1]);
	h.opt.label	= cellfun(@(lbl,n) unless(lbl,char(n+64)),h.opt.label,num2cell((1:N)'),'uni',false);
	
	h.opt.lut(end+1:nPlot)	= {optD.lut};
	h.opt.lut				= cellfun(@(lut) unless(lut,optD.lut),h.opt.lut,'uni',false);
	
	nLUT	= 255;
	lut		= cellfun(@(lut) MakeLUT(lut,nLUT),h.opt.lut,'uni',false);
%position of each element on the ring
	[aElement,xElement,yElement]	= CalculateElementPositions;

%prepare the figure
	h.hBase	= PrepareFigure;
%draw each set of connections
	[h.hConnect,colLabel]	= DrawConnections;
%draw the labels
	[h.hLabel,h.hBoxLabel]	= DrawLabels(colLabel);
%show the colorbar
	if h.opt.colorbar
		ShowColorBar;
	end

%set some stuff for alexplot
	h.opt.xmin		= xMin;
	h.opt.xmax		= xMax;
	h.opt.ymin		= yMin;
	h.opt.ymax		= yMax;

%------------------------------------------------------------------------------%
function optD = GetStyleDefaults(strStyle)
	switch lower(strStyle)
		case 'color'
			optD.lut	=	'random';
		case 'bw'
			optD.lut	=	'grayscale';
		otherwise
			error(['"' tostring(strStyle) '" is not a valid connection plot style.']);
	end
end
%------------------------------------------------------------------------------%
function sig = ProcessSignificance(sig,varargin)
	sigDefault	= ParseArgs(varargin,[]);
	
	if ~isempty(sig)
		if ~isa(sig,'logical')
			sig	= sig <= h.opt.pcutoff;
		end
	elseif ~isempty(sigDefault)
		sig	= sigDefault;
	else
		sig	= true(N);
	end
end
%------------------------------------------------------------------------------%
function [aElement,xElement,yElement] = CalculateElementPositions()
	aElement	= NaN(N,1);
	
	%get the angular location of each element
		if isempty(h.opt.position)
		%position elements uniformly around the ring
			aElement	= mod(h.opt.ring_phase + pi/2 + linspace(0,2*pi,N+1)',2*pi);
			aElement	= aElement(1:end-1);
		else
		%quadrant positioning
			%center of each group
				aCenter		= struct(...
								'l'	, pi		, ...
								'r'	, 0			, ...
								't'	, pi/2		, ...
								'b'	, 3*pi/2	  ...
								);
				aDirection	= struct(...
								'l'	, 1		, ...
								'r'	, -1	, ...
								't'	, -1	, ...
								'b'	, 1		  ...
								);
			
			%which groups are present?
				group	= unique(h.opt.position);
				nGroup	= numel(group);
			
			%total angle spread of the elements
				aTotal	= 2*pi - nGroup*h.opt.group_padding;
			%angle spread per element. the nGroup/N bit is so each group's
			%element goes right up to the edge of the group spread
				aPer	= (1 + nGroup/N)*aTotal/N;
			
			%position of each element
				for kG=1:nGroup
					kInGroup	= find(h.opt.position==group(kG));
					nInGroup	= numel(kInGroup);
					
					if nInGroup>0
						aGroup		= aPer*nInGroup;
						aStart		= aCenter.(group(kG)) - aGroup/2 + aPer/2;
						aInGroup	= h.opt.ring_phase + aStart + (0:aPer:(nInGroup-1)*aPer);
						
						
						if aDirection.(group(kG))==-1
							aInGroup	= aInGroup(end:-1:1);
						end
						
						aElement(kInGroup)	= aInGroup;
					end
				end
		end
	
	%convert to cartesian
		xElement	= h.opt.ring_radius*cos(aElement);
		yElement	= h.opt.ring_radius*sin(aElement);
end
%------------------------------------------------------------------------------%
function hBase = PrepareFigure()
	%squareify the figure
		if isempty(h.opt.w) && isempty(h.opt.h)
			p	= GetElementPosition(h.hF);
			s	= max(p.w,p.h);
			MoveElement(h.hF,'w',s,'h',s);
			
			set(h.hF,'PaperSize',[3 3],'PaperUnits','inches','PaperPosition',[0 0 3 3]);
		end
	%squarify the axes
		MoveElement(h.hA,'w',h.opt.wax,'h',h.opt.hax,'l',h.opt.lax,'t',h.opt.tax);
	
	%draw the base circle
		hBase	= PatchCircle(0,0,h.opt.ring_radius,...
					'ha'			, h.hA					, ...
					'color'			, h.opt.innerbackground	, ...
					'borderwidth'	, h.opt.axiswidth		, ...
					'nstep'			, h.opt.nstep			  ...
					);
end
%------------------------------------------------------------------------------%
function [hConnect,colLabel] = DrawConnections()
	hConnect	= zeros(nPair,nPlot);
	
	for kP=1:nPlot
		C		= h.data.C{kP};
		sig		= h.data.sig{kP};
		sigCorr	= h.data.sigcorr{kP};
		
		%color-mapped values
			CCol	= round(MapValue(C,h.opt.cmin(kP),h.opt.cmax(kP),0.5,nLUT+0.4999));
			
			if kP==1
			%get the label colors based off the first connection matrix
				cLabelCol	= CCol(kDiag);
				
				bLabelShow	= ~isnan(cLabelCol) & sig(kDiag);
				bLabelDim	= bLabelShow & ~sigCorr(kDiag);
				bLabelFull	= bLabelShow & ~bLabelDim;
				
				colLabel					= NaN(N,4);
				colLabel(bLabelShow,1:3)	= lut{kP}(cLabelCol(bLabelShow),:);
				colLabel(bLabelFull,4)		= h.opt.alpha(kP);
				colLabel(bLabelDim,4)		= h.opt.alphadim(kP);
			end
		%arc widths
			if bArcWidthScale
				CWidth	= MapValue(C,h.opt.cmin(kP),h.opt.cmax(kP),h.opt.arcwidthmin,h.opt.arcwidthmax);
			else
				CWidth	= h.opt.arcwidth*ones(size(C));
			end
		
		%sort the connections so higher values appear on top
			[x,kSortValue]	= sort(C(kPair));
			kPairSort		= kPair(kSortValue);
		%sort by significance
			bSigCorr	= sigCorr(kPairSort);
			bSig		= ~bSigCorr & sig(kPairSort);
			bNonSig		= ~bSigCorr & ~bSig;
			
			kSortSig	= [find(bNonSig); find(bSig); find(bSigCorr)];
			kPairSort	= kPairSort(kSortSig);
		
		for kR=1:nPair
			kC			= kPairSort(kR);
			[kC1,kC2]	= ind2sub([N N],kC);
			
			col	= CCol(kC);
			w	= CWidth(kC);
			
			%how should we show this thing?
				if sigCorr(kC)
					alpha	= h.opt.alpha(kP);
				elseif sig(kC) && ~isnan(col)
					alpha	= h.opt.alphadim(kP);
				else
					continue;
				end
			
			%arc end points
				x1	= xElement(kC1);
				y1	= yElement(kC1);
				
				x2	= xElement(kC2);
				y2	= yElement(kC2);
			%polar angle of each arc endpoint
				a1	= atan2(y1,x1);
				a2	= atan2(y2,x2);
			
			hConnect(kC,kP)	= fArc(0,0,h.opt.ring_radius,a1,a2,w,...
								'color'	, lut{kP}(col,:)	, ...
								'alpha'	, alpha			, ...
								'nstep'	, h.opt.nstep	  ...
								);
			
			set(h.hA,'xlim',[xMin xMax],'ylim',[yMin yMax]);
		end
	end
end
%------------------------------------------------------------------------------%
function [hLabel,hBox]	= DrawLabels(colLabel)
	[hLabel,hBox]	= deal(zeros(N,1));
	
	[aLabel,cAlign]	= LabelAngle(aElement);
	[xLabel,yLabel]	= LabelPosition(xElement,yElement);
	
	for kL=1:N
		colBack		= colLabel(kL,1:3);
		bShowBack	= ~any(isnan(colBack));
		
		if ~bShowBack
			colBack	= h.opt.background;
		end
		
		colText	= GetGoodTextColor(colBack);
		
		%draw the label
			hLabel(kL)	= text(xLabel(kL),yLabel(kL),h.opt.label{kL},...
							'Color'					, colText			, ...
							'FontName'				, h.opt.font		, ...
							'FontSize'				, sFont.medium		, ...
							'FontWeight'			, h.opt.fontweight	, ...
							'HorizontalAlignment'	, cAlign{kL}		  ...
							);
			tExtent		= get(hLabel(kL),'Extent');
			set(hLabel(kL),'Rotation',aLabel(kL));
		%draw the background
			if bShowBack
				%get the box position
					boxW	= tExtent(3) + 2*h.opt.box_padding_h;
					boxH	= tExtent(4) + 2*h.opt.box_padding_v;
					
					[xBox,yBox,outer]	= LabelPosition(xElement(kL),yElement(kL),boxW);
				
				hBox(kL)	= PatchBox(xBox,yBox,boxW,boxH,aElement(kL),...
								'color'			, colBack	, ...
								'bordercolor'	, colText	, ...
								'borderwidth'	, 0			  ...
								);
				
				%move the background behind its text
					hChild	= get(h.hA,'Children');
					hChild	= [hLabel(kL); hBox(kL); hChild(hChild~=hLabel(kL) & hChild~=hBox(kL))];
					set(h.hA,'Children',hChild);
			end
	end
end
%------------------------------------------------------------------------------%
function [a,cAlign] = LabelAngle(a)
	bLeft	= a>pi/2 & a<3*pi/2;
	
	a(bLeft)	= a(bLeft) - pi;
	a			= r2d(a);
	
	cAlign			= repmat({'left'},size(a));
	cAlign(bLeft)	= {'right'};
end
%------------------------------------------------------------------------------%
function [x,y,outer] = LabelPosition(x,y,varargin)
	wElement	= ParseArgs(varargin,0);
	bLabel		= wElement==0;
	
	%shift the labels outward
		rShift			= repmat(h.opt.label_padding + bLabel*h.opt.box_padding_h + wElement/2,size(x));
		
		pLabel		= PointConvert([x y],'cartesian','polar');
		pLabel(:,1)	= pLabel(:,1) + rShift;
		
		outer		= pLabel;
		outer(:,1)	= outer(:,1) + wElement/2;
		
		pLabel	= PointConvert(pLabel,'polar','cartesian');
		outer	= PointConvert(outer,'polar','cartesian');
	
	x	= pLabel(:,1);
	y	= pLabel(:,2);
end
%------------------------------------------------------------------------------%
function ShowColorBar()
	aUnit	= get(h.hA,'Units');
	fUnit	= get(h.hF,'Units');
	
	set(h.hA,'Units','inches');
	set(h.hF,'Units','inches');
	
	%expand the figure
		pFig	= GetElementPosition(h.hF);
		
		MoveElement(h.hF,'w',pFig.w+h.opt.wcolorbar);
	%create the key axes
		h.hALUT	= axes('Units','inches','Color',h.opt.background);
		ClearAxes(h.hALUT);
		MoveElement(h.hALUT,'t',0,'r',0.1,'h',pFig.h,'w',h.opt.wcolorbar);
		set(h.hALUT,'XLim',[0 1],'YLim',[0 1]);
		
		%what is that line?
			delete(get(h.hALUT,'Children'));
	%create the key patch
		strPrefix	= conditional(isempty(h.opt.scalelabel),[],[h.opt.scalelabel '=']);
		
		h.hLUT	= FigLUT(lut,[],[],[],[],h.opt.cmin,h.opt.cmax,...
					'ha'			, h.hALUT				, ...
					'fontname'		, h.opt.font			, ...
					'prefixmin'		, strPrefix				, ...
					'keybackground'	, h.opt.innerbackground	, ...
					'borderwidth'	, 0						  ...
					);
	
	set(h.hALUT,'XLim',[0 1],'YLim',[0 1]);
	
	set(h.hA,'Units',aUnit);
	set(h.hF,'Units',fUnit);
end
%------------------------------------------------------------------------------%

end
