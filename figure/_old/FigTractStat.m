function [h,bShow,colShow] = FigTractStat(cLabelName,stat,varargin)
% FigTractStat
% 
% Description:	construct a figure showing a statistical result on tracts within
%				and between hemispheric ROIs
% 
% Syntax:	[h,bShow,colShow] = FigTractStat(cLabelName,stat,[statAlpha]=stat,<options>)
% 
% In:
% 	cLabelName	- a cell of label names, with 'lh.' (left hemisphere), 'rh.'
%				  (right hemisphere), 'pm.' (posterior medial), and 'am.'
%				  (anterior medial) prefixes, in the bottom-to-top (for lh and
%				  rh) or left-to-right (for pm and am) order in which they
%				  should be shown
%	stat		- an nLabel x nLabel x nStat matrix of statistical values to
%				  show. values on the diagonal will be shown in each label's box.
%				  off-diagonal values will be shown as connections between
%				  corresponding tracts (only one of the redundant matrix elements
%				  should have a non-NaN value (e.g. not both stat(2,3) and
%				  stat(3,2).  elements with NaN values will be ignored.
%	statAlpha	- the stat matrix to use for the alpha values
%	<options>:
%		min:				(<stat min>) the minimum stat cutoff value(s). tracts
%							below this value are ignored.
%		max:				(<stat max>) the maximum stat cutoff value(s). tracts
%							above this value are squeezed
%		lutmin:				(<min>) the stat value(s) corresponding to the
%							minimum LUT color
%		lutmax:				(<max>) the stat value(s) corresponding to the
%							maximum LUT color
%		alphamin:			(<min>) the stat value(s) corresponding to the
%							minimum alpha
%		alphamax:			(<max>) the stat value(s) corresponding to the
%							maximum alpha
%		minmaxmethod:		('abs') the method for calculating min/max cutoffs.
%							one of the following:
%								'abs': min/max values are used as is
%								'prctile': min/max values range from 0->100 to
%									specify percentiles of the actual stat data
%		arcwidth:			(0.01) the width of tract arcs
%		width:				(8) width of the figure, in inches
%		wlabel:				(0.1) the width of labels, in normalized units
%		lut:				([0 0 1; 1 0.5 0]) control points for the color LUT,
%							or a cell of LUTs, one for each stat
%		background:			([1 1 1]) the background color
%		innerbackground:	(<background>) the background color of the inner
%							tract area
%		keyinvert:			(false) true to display key values as 1-<val>
%		keyprefix:			('') the prefix for the minimum LUT key label
%		colorbar:			(true) true to show the color bar
%		showhemi:			(true) true to show hemisphere labels
%		showbox:			(true) true to show boxes around labels
%		labelcenter:		(true) true to center labels in their boxes
%		labelsize:			(12) the label font size
%		labelweight:		('normal') the label font weight
%		font:				('Arial') the font to use
% 
% Out:
% 	h		- a struct of handles
%	bShow	- a matrix specifying which stat values were shown
%	colShow	- an nLabel x nLabel x nStat x 3 array of the colors assigned to
%			  each displayed tract
% 
% Updated: 2013-03-23
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[statAlpha,opt]	= ParseArgsOpt(varargin,[],...
					'min'				, []				, ...
					'max'				, []				, ...
					'lutmin'			, []				, ...
					'lutmax'			, []				, ...
					'alphamin'			, []				, ...
					'alphamax'			, []				, ...
					'minmaxmethod'		, 'abs'				, ...
					'arcwidth'			, 0.01				, ...
					'width'				, 8					, ...
					'wlabel'			, 0.1				, ...
					'lut'				, [0 0 1; 1 0.5 0]	, ...
					'background'		, [1 1 1]			, ...
					'innerbackground'	, []				, ...
					'keyinvert'			, false				, ...
					'keyprefix'			, ''				, ...
					'colorbar'			, true				, ...
					'showhemi'			, true				, ...
					'showbox'			, true				, ...
					'labelcenter'		, true				, ...
					'labelsize'			, 12				, ...
					'labelweight'		, 'normal'			, ...
					'font'				, 'Arial'			  ...
					);
opt.innerbackground	= unless(opt.innerbackground,opt.background);

bStatAlpha			= ~isempty(statAlpha);
if ~bStatAlpha
	statAlpha	= stat;
end

nLabel	= numel(cLabelName);

nStat			= size(stat,3);
[statCol,statA]	= varfun(@(x) reshape(x,[],nStat),stat,statAlpha);

mnStat	= nanmin(statCol);
mxStat	= nanmax(statCol);

opt.lut	= ForceCell(opt.lut);
opt.lut	= repto(reshape(opt.lut,[],1),[nStat 1]);

colText	= GetGoodTextColor(opt.background);

%get the cutoffs
	[bMn,bMx,baMn,baMx,blMn,blMx]	= varfun(@(x) ~isempty(x),opt.min,opt.max,opt.alphamin,opt.alphamax,opt.lutmin,opt.lutmax);
	
	[opt.alphamin,opt.lutmin]	= varfun(@(mn) unless(mn,opt.min),opt.alphamin,opt.lutmin);
	[opt.alphamax,opt.lutmax]	= varfun(@(mx) unless(mx,opt.max),opt.alphamax,opt.lutmax);
	
	switch lower(opt.minmaxmethod)
		case 'abs'
			[statMin,alphaMin,lutMin]	= varfun(@(mn) unless(mn,mnStat),opt.min,opt.alphamin,opt.lutmin);
			[statMax,alphaMax,lutMax]	= varfun(@(mx) unless(mx,mxStat),opt.max,opt.alphamax,opt.lutmax);
		case 'prctile'
			[statMin,lutMin]	= varfun(@(mn) prctile(statCol,unless(mn,0)),opt.min,opt.lutmin);
			[statMax,lutMax]	= varfun(@(mx) prctile(statCol,unless(mx,100)),opt.max,opt.lutmax);
			
			alphaMin	= prctile(statA,unless(opt.alphamin,0));
			alphaMax	= prctile(statA,unless(opt.alphamax,100));
		otherwise
			error(['"' tostring(opt.minmaxmethod) '" is not a valid cutoff method.']);
	end
	
	[statMin,statMax,alphaMin,alphaMax,lutMin,lutMax]	= varfun(@(x) repto(reshape(x,[],1),[nStat 1]),statMin,statMax,alphaMin,alphaMax,lutMin,lutMax);
	
	if ~bMn
		statMin	= min(statMin,statMax);
	end
	if ~bMx
		statMax	= max(statMax,statMin);
	end
	if ~baMn
		alphaMin	= min(alphaMin,alphaMax);
	end
	if ~baMx
		alphaMax	= max(alphaMax,alphaMin);
	end
	if ~blMn
		lutMin	= min(lutMin,lutMax);
	end
	if ~blMx
		lutMax	= max(lutMax,lutMin);
	end

%get label abbreviations
	cLabelAbb	= cellfun(@Label2Abb,cLabelName,'UniformOutput',false);
%initialize the figure
	[wFig,hFig]	= deal(opt.width - 1);
	
	h.hF	= figure('Units','inches');
	MoveElement(h.hF,'w',wFig,'h',hFig,'t',0,'l',0);
	%MoveElement(h.hF,'center',true);
	
	h.hA	= axes;
	ClearAxes(h.hA);
	set(h.hA,'Units','normalized');
	set(h.hA,'Position',[0 0 1 1]);
	set(h.hA,'Color',opt.background);
	
	fFigure	= 0.99;	%percentage of axes width to use for the graphical part of the figure
	fSpace	= 0;	%fractional space in between labels
%get the label box coordinates
	%separate into lh, rh, pm, and am labels
		kHemi	= cellfun(@(x) switch2(lower(x(1:2)),'lh',1,'rh',2,'pm',3,'am',4),cLabelName);
		nLH		= sum(kHemi==1);
		nRH		= sum(kHemi==2);
		nPM		= sum(kHemi==3);
		nAM		= sum(kHemi==4);
	%center and radius of the rings
		xRing	= 0.5;
		yRing	= 0.5;
		
		rRing	= fFigure/2-opt.wlabel;
	%get the width/height and position of each label box
		arcA	= 5*pi/6;	%arc angle to take up with maximum hemisphere side
		arcW	= arcA*rRing;
		
		nHMax		= max(nLH,nRH);
		arcNTotal	= nHMax + fSpace*(nHMax-1);
		hRect		= arcW/arcNTotal;
		
		aPer	= arcA/arcNTotal;
		
		aOffsetLHP	= (nLH/nHMax)*(pi-arcA)/2 + nPM*aPer/2;
		aOffsetRHP	= (nRH/nHMax)*(pi-arcA)/2 + nPM*aPer/2;
		aOffsetLHA	= (nLH/nHMax)*(pi-arcA)/2 + nAM*aPer/2;
		aOffsetRHA	= (nRH/nHMax)*(pi-arcA)/2 + nAM*aPer/2;
		aLH			= reshape(GetInterval(3*pi/2-aOffsetLHP,pi/2+aOffsetLHA,nLH),[],1);
		aRH			= reshape(GetInterval(3*pi/2+aOffsetRHP,5*pi/2-aOffsetRHA,nRH),[],1);
		
		if nPM>0
			aPM	= reshape(GetInterval(3*pi/2-(nPM-1)*aPer/2,3*pi/2+(nPM-1)*aPer/2,nPM),[],1);
		else
			aPM	= [];
		end
		
		if nAM>0
			aAM	= reshape(GetInterval(pi/2+(nAM-1)*aPer/2,pi/2-(nAM-1)*aPer/2,nAM),[],1);
		else
			aAM	= [];
		end
		
		pLH	= PointConvert([repmat(rRing,[nLH 1]) aLH],'polar','cartesian');
		xLH	= pLH(:,1) + xRing;
		yLH	= pLH(:,2) + yRing;
		
		pRH	= PointConvert([repmat(rRing,[nRH 1]) aRH],'polar','cartesian');
		xRH	= pRH(:,1) + xRing;
		yRH	= pRH(:,2) + yRing;
		
		if nPM>0
			pPM	= PointConvert([repmat(rRing,[nPM 1]) aPM],'polar','cartesian');
			xPM	= pPM(:,1) + xRing;
			yPM	= pPM(:,2) + yRing;
		else
			[pPM,xPM,yPM]	= deal([]);
		end
		
		if nAM>0
			pAM	= PointConvert([repmat(rRing,[nAM 1]) aAM],'polar','cartesian');
			xAM	= pAM(:,1) + xRing;
			yAM	= pAM(:,2) + yRing;
		else
			[pAM,xAM,yAM]	= deal([]);
		end
%associate each label with a box
	[xLabel,yLabel,aLabel]	= deal(NaN(nLabel,1));
	
	xLabel(kHemi==1)	= xLH;
	yLabel(kHemi==1)	= yLH;
	aLabel(kHemi==1)	= aLH;
	xLabel(kHemi==2)	= xRH;
	yLabel(kHemi==2)	= yRH;
	aLabel(kHemi==2)	= aRH;
	xLabel(kHemi==3)	= xPM;
	yLabel(kHemi==3)	= yPM;
	aLabel(kHemi==3)	= aPM;
	xLabel(kHemi==4)	= xAM;
	yLabel(kHemi==4)	= yAM;
	aLabel(kHemi==4)	= aAM;
%draw the inner background
	if ~isequal(opt.innerbackground,opt.background)
		h.hInner	= PatchCircle(xRing,yRing,rRing,'ha',h.hA,'color',opt.innerbackground,'borderwidth',0);
	end
%draw each set of stat tracts
	h.hT	= cell(nStat,1);
	
	colBox	= repmat(opt.background,[nLabel 1]);
	
	sStat	= [size(stat) conditional(ndims(stat)==2,1,[])];
	bShow	= false(sStat);
	colShow	= nan([sStat 3]);
	
	for kS=1:nStat
		statCur		= stat(:,:,kS);
		statCurA	= statAlpha(:,:,kS);
		statMinCur	= statMin(kS);
		statMaxCur	= statMax(kS);
		alphaMinCur	= alphaMin(kS);
		alphaMaxCur	= alphaMax(kS);
		lutMinCur	= lutMin(kS);
		lutMaxCur	= lutMax(kS);
		
		colShowCur	= nan(nLabel,nLabel,3);
		
		%ignore subthreshold stats
			[kShow1,kShow2]					= find(statCur>=statMinCur);
			statCur(statCur<statMinCur)	= NaN;
		%squeeze supra-max stats
			statCur(statCur>statMaxCur)	= statMaxCur;
		%get the tracts associated with each stat value
			bShowCur			= ~isnan(statCur);
			[kLabel1,kLabel2]	= find(bShowCur);
			statCurShow			= statCur(bShowCur);
			statCurShowA		= statCurA(bShowCur);
			
			%within ROI stats
				bIntra		= kLabel1==kLabel2;
				kLabelIntra	= kLabel1(bIntra);
				statIntra	= statCurShow(bIntra);
				statIntraA	= statCurShowA(bIntra);
				nIntra		= numel(statIntra);
			%connection stats
				bInter		= ~bIntra;
				statInter	= statCurShow(bInter);
				statInterA	= statCurShowA(bInter);
				kLabel1		= kLabel1(bInter);
				kLabel2		= kLabel2(bInter);
				nInter		= numel(statInter);
		%get the box background colors
			tCol					= MapValue(statIntra,lutMinCur,lutMaxCur,0,1);
			colBox(kLabelIntra,:)	= MakeLUT(opt.lut{kS},tCol);
			
			kLI						= repmat(kLabelIntra,[1 3]);
			kRGB					= repmat(1:3,[nIntra 1]);
			kColShow				= sub2ind([nLabel nLabel 3],kLI,kLI,kRGB);
			colShowCur(kColShow)	= colBox(kLabelIntra,:);
		%draw the connections between labels
			h.hT{kS}	= zeros(nInter,1);
			
			%tract alpha values
				a	= MapValue(statInterA,alphaMinCur,alphaMaxCur,0,1);
			%get the color of each tract
				tCol		= MapValue(statInter,lutMinCur,lutMaxCur,0,1);
				colInter	= MakeLUT(opt.lut{kS},tCol);
				
				kL1						= repmat(kLabel1,[1 3]);
				kL2						= repmat(kLabel2,[1 3]);
				kRGB					= repmat(1:3,[nInter 1]);
				kColShow				= sub2ind([nLabel nLabel 3],kL1,kL2,kRGB);
				colShowCur(kColShow)	= colInter;
			%order tract from min to max stat value
				[s,kOrder]	= sort(statInter);
			for kT=1:nInter
				kTCur	= kOrder(kT);
				
				%tract end points
					x1	= xLabel(kLabel1(kTCur));
					y1	= yLabel(kLabel1(kTCur));
					x2	= xLabel(kLabel2(kTCur));
					y2	= yLabel(kLabel2(kTCur));
				%polar angle of each endpoint
					a1	= atan2(y1-yRing,x1-xRing);
					a2	= atan2(y2-yRing,x2-xRing);
				
				h.hT{kS}(kTCur)	= PatchArcInterior(xRing,yRing,rRing,a1,a2,opt.arcwidth,'color',colInter(kTCur,:),'alpha',a(kTCur));
			end
			
			
		stat(:,:,kS)		= statCur;
		bShow(:,:,kS)		= bShowCur;
		colShow(:,:,kS,:)	= colShowCur;
	end
	
	set(h.hA,'XLim',[0 1]);
	set(h.hA,'YLim',[0 1]);
%draw each label box
	if opt.showbox
		h.hB	= zeros(nLabel,1);
		for kB=1:nLabel
			%shift the radius to the center of the box
				pShift		= PointConvert([xLabel(kB)-xRing,yLabel(kB)-yRing],'cartesian','polar');
				pShift(:,1)	= pShift(:,1) + opt.wlabel/2;
				pShift		= PointConvert(pShift,'polar','cartesian');
				xShift		= xRing + pShift(:,1);
				yShift		= yRing + pShift(:,2);
			
			h.hB(kB)	= PatchBox(xShift,yShift,opt.wlabel,hRect,aLabel(kB),...
							'color'			, colBox(kB,:)	, ...
							'bordercolor'	, colText		, ...
							'borderwidth'	, 1.5			  ...
							);
		end
	end
%label the boxes
	aLabelOffset	= arrayfun(@(h) switch2(h,1,pi,2,0,3,pi,4,0),kHemi);
	aLabelText		= (aLabel + aLabelOffset)*180/pi;
	
	h.hL	= zeros(nLabel,1);
	for kL=1:nLabel
		if opt.labelcenter
			strAlign	= 'center';
			
			rOffset	= opt.wlabel/2;
		else
			strAlign	= switch2(kHemi(kL),...
							1	, 'right'	, ...
							2	, 'left'	, ...
							3	, 'right'	, ...
							4	, 'left'	  ...
							);
			
			rOffset	= 0.01;
		end
		%shift the radius to the center of the box
			pShift		= PointConvert([xLabel(kL)-xRing,yLabel(kL)-yRing],'cartesian','polar');
			pShift(:,1)	= pShift(:,1) + rOffset;
			pShift		= PointConvert(pShift,'polar','cartesian');
			xShift		= xRing + pShift(:,1);
			yShift		= yRing + pShift(:,2);
		
		h.hL(kL)	= text(xShift,yShift,cLabelAbb{kL},...
						'Color'					, colText			, ...
						'Rotation'				, aLabelText(kL)	, ...
						'FontName'				, opt.font			, ...
						'FontSize'				, opt.labelsize		, ...
						'FontWeight'			, opt.labelweight	, ...
						'HorizontalAlignment'	, strAlign			  ...
						);
	end
%label the hemispheres
	if opt.showhemi
		h.hLH	= text(0.1,0.9,'LH','FontName',opt.font,'FontSize',20,'FontWeight','bold','HorizontalAlignment','center');
		h.hRH	= text(0.9,0.9,'RH','FontName',opt.font,'FontSize',20,'FontWeight','bold','HorizontalAlignment','center');
	end
%construct the LUT keys
	if opt.colorbar
		wAxLUT	= 1;
		
		%expand the figure
			set(h.hA,'Units','pixels');
			MoveElement(h.hF,'w',wFig+wAxLUT);
		%create the key axes
			h.hALUT	= axes('Units','inches','Color',opt.background);
			ClearAxes(h.hALUT);
			MoveElement(h.hALUT,'t',0,'r',0,'h',hFig,'w',wAxLUT);
			%what is that line?
				delete(get(h.hALUT,'Children'));
		%create the key patch
			nInterp	= 100;
			%get the LUT values corresponding to the range of stat values
				tLUT	= arrayfun(@(k) MapValue(GetInterval(statMin(k),statMax(k),nInterp),lutMin(k),lutMax(k),0,1)',(1:nStat)','UniformOutput',false);
				keyLUT	= cellfun(@MakeLUT,opt.lut,tLUT,'UniformOutput',false);
			%get the alpha values corresponding to the range of stat values
				if bStatAlpha
					keyAlpha	= 1;
				else
					keyAlpha	= arrayfun(@(k) MapValue(GetInterval(statMin(k),statMax(k),nInterp),alphaMin(k),alphaMax(k),0,1)',(1:nStat)','UniformOutput',false);
				end
			
			keyMin	= conditional(opt.keyinvert,1-statMin,statMin);
			keyMax	= conditional(opt.keyinvert,1-statMax,statMax);
			
			set(h.hALUT,'XLim',[0 1]);
			set(h.hALUT,'YLim',[0 1]);
			
			h.hLUT	= FigLUT(keyLUT,[],[],[],[],keyMin,keyMax,...
						'ha'			, h.hALUT				, ...
						'alpha'			, keyAlpha				, ...
						'fontname'		, opt.font				, ...
						'fontweight'	, 'bold'				, ...
						'prefixmin'		, opt.keyprefix			, ...
						'keybackground'	, opt.innerbackground	  ...
						);
			
			set(h.hALUT,'XLim',[0 1]);
			set(h.hALUT,'YLim',[0 1]);
	end

%------------------------------------------------------------------------------%
function strAbb = Label2Abb(strLabel)
	%get rid of the lh/rh.
		strLabel	= strLabel(4:end);
	%collapse numbers
		re			= join(arrayfun(@(n) ['(' num2str(n) ')(\d)_' num2str(n) '(\d)'],0:9,'UniformOutput',false),'|');
		strLabel	= regexprep(strLabel,re,'$1$2/$3');
		strLabel	= regexprep(strLabel,'(\d+)_(\d+)','$1/$2');
	%split words
		cWord		= split(strLabel,'_');
	%get the abbreviations
		if numel(cWord)>1 && ~any(cellfun(@isnumstr,cWord))
			cWord		= cellfun(@(w) upper(w(1)),cWord,'UniformOutput',false);
		end
	%join again
		strAbb	= join(cWord,'');
%------------------------------------------------------------------------------%
