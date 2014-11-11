function h = alexplot_confusion(x,h,vargin)
% alexplot_confusion
% 
% Description:	plot a confusion matrix
% 
% Syntax:	h = alexplot(cm,'type','confusion',<options>)
% 
% In:
%	cm		- a confusion matrix, with predictions as rows and targets as
%			  columns
% 	<confusion-specific options>:
%		substyle:		('color') a string to specify the following default
%						options:
%							'color':
%								lut:	'default'
%							'bw':
%								lut:	'grayscale'
%		lut:			(<see subtype>) an Mx3 LUT for the confusion matrix
%		nancol			(lut(1,:)) the color for NaN values
%		cmmin:			(<auto>) the minimum of the cm display range
%		cmmax:			(<auto>) the maximum of the cm display range
%		label:			(<none>) the category labels
%		rowlabel:		(<label>) the row category labels. overrides <label>.
%		columnlabel:	(<label>) the column category labels. overrides <label>.
%		cornerlabel:	(true) true to show the labels in the upper left and
%						lower right corners
%		scalelabel:		('N') the label for the color bar values
%		tplabel:		(true) true to show the 'targets'/'predictors' labels
%		values:			(false) true to show values in each cell
%		values_unit:	(false) true to show the values unit
%		values_sigfig:	(2) the number of significant figures to show in value
%						labels
%		values_color:	(<auto>) a 1x3 color for value labels, or a cell the
%						same size as cm of 1x3 colors
%		colorbar:		(true) true to show the color bar
%		colorbarticks:	(<auto>) the number of color bar ticks
%		xlabelrot:		(45) the rotation angle of the x labels, in degrees
%		ylabelrot:		(45) the rotation angle of the y labels, in degrees
%		dim:			(<none>) a logical array the same size as cm
%						specifying the grid cells to dim
%		dimmethod:		('alpha') the method for dimming.  one of the following:
%							'alpha': make dimmed grid cells semi-transparent
%							'gray':  make dimmed grid cells gray
%							col:     a 1x3 array specifying the dim color
%		dimalpha:		(0.5) the dimmed alpha value
% 
% Updated: 2013-07-01
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sFont	= struct('small',10,'medium',12,'large',18,'huge',18);

%parse the extra options
	strStyle	= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	optD		= GetStyleDefaults(strStyle);
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'		, 'color'	, ...
					'lut'			, optD.lut	, ...
					'nancol'		, []		, ...
					'cmmin'			, []		, ...
					'cmmax'			, []		, ...
					'label'			, {}		, ...
					'rowlabel'		, []		, ...
					'columnlabel'	, []		, ...
					'endlabels'		, true		, ...
					'cornerlabel'	, true		, ...
					'scalelabel'	, 'N'		, ...
					'tplabel'		, true		, ...
					'values'		, false		, ...
					'values_unit'	, false		, ...
					'values_sigfig'	, 2			, ...
					'values_color'	, []		, ...
					'colorbar'		, true		, ...
					'colorbarticks'	, []		, ...
					'xlabelrot'		, 45		, ...
					'ylabelrot'		, 45		, ...
					'dim'			, []		, ...
					'dimmethod'		, 'alpha'	, ...
					'dimalpha'		, 0.35		 ...
					));
	
	%h.opt.showgrid			= false;
	h.opt.extraback			= ~notfalse(h.opt.tplabel);
	h.opt.setplotlimits	= false;
	
	h.opt.rowlabel		= unless(h.opt.rowlabel,h.opt.label);
	h.opt.columnlabel	= unless(h.opt.columnlabel,h.opt.label);
	
	if ischar(h.opt.dimmethod)
		h.opt.dimmethod	= CheckInput(h.opt.dimmethod,'dim method',{'alpha','gray'});
	end
	if ~isequal(h.opt.dimmethod,'alpha') && ~isequal(h.opt.dimmethod,'gray')
        colGray			= h.opt.dimmethod;
        h.opt.dimmethod	= 'gray';
    else
        colGray	= [0.75 0.75 0.75];
	end
	
%parse the cm values
	cm							= deal(x{:});
	[nLabelRow,nLabelColumn]	= size(cm);
	
	h.data.x					= {GetInterval(0,1,nLabelColumn)'};
	h.data.y					= {GetInterval(1,0,nLabelRow)'};
	[h.data.xerr,h.data.yerr]	= deal({0});
%fill in the mins and maxes
	h.opt.xmin	= 0;
	h.opt.xmax	= 1;
	h.opt.ymin	= 0;
	h.opt.ymax	= 1;
%get the value colors
	h.opt.values_color	= repto(ForceCell(h.opt.values_color),[nLabelRow nLabelColumn]);
	
%plot the confusion matrix
	%squareify
		if isempty(h.opt.w) && isempty(h.opt.h)
			p	= GetElementPosition(h.hF);
			s	= max(p.w,p.h);
			MoveElement(h.hF,'w',s,'h',s);
			
			set(h.hF,'PaperSize',[3 3],'PaperUnits','inches','PaperPosition',[0 0 3 3]);
		end
	%get the image dimensions
		pAxes	= GetElementPosition(h.hA);
		sPaper	= get(h.hF,'PaperSize');
		dpi		= 600;
		
		wIm	= round(dpi*sPaper(1)*pAxes.w);
		hIm	= round(dpi*sPaper(2)*pAxes.h);
	%construct the image
		if isempty(h.opt.cmmin)
			mn			= nanmin(cm(:));
			[cmMin,msd]	= sigfig(mn,2);
			
			if mn~=cmMin
				cmMin		= cmMin - 10^(msd-1);
			end
		else
			cmMin	= h.opt.cmmin;
		end
		
		if isempty(h.opt.cmmax)
			mx			= nanmax(cm(:));
			[cmMax,msd]	= sigfig(mx,2);
			
			if mx~=cmMax
				cmMax		= cmMax + 10^(msd-1);
			end
		else
			cmMax	= h.opt.cmmax;
		end
		
		%cmMin		= unless(h.opt.cmmin,min(cm(:)));
		%cmMax		= unless(h.opt.cmmax,max(cm(:)));
		
		nLUT		= 254;
		bNaN		= isnan(cm);
		cmCol		= round(MapValue(cm,cmMin,cmMax,0.5,nLUT+0.4999));
		cmCol(bNaN)	= 0;
		cmColOrig	= cmCol;
		
		lut				= MakeLUT(h.opt.lut,nLUT);
		h.opt.nancol	= unless(h.opt.nancol,lut(1,:));
		
		if ~isempty(h.opt.dim) && isequal(h.opt.dimmethod,'gray')
			cmCol(h.opt.dim)	= -1;
		end
	%show it
		imCM	= imresize(cmCol,[hIm wIm],'nearest');
		
		h.hI	= image(h.data.x{1},h.data.y{1},imCM,'Parent',h.hA);
		caxis(h.hA,[-1 nLUT]);
		
		set(h.hI,'CDataMapping','scaled');
		set(h.hA,'YDir','normal');
		
		colormap([colGray; h.opt.nancol; lut]);
	%show the colorbar
		if h.opt.colorbar
			h.hCB				= colorbar('peer',h.hA);
			set(h.hCB,'YLim',[0 nLUT],'box','off','XColor',h.opt.background,'YColor',h.opt.textcolor,'FontName',h.opt.font,'FontWeight','normal','FontSize',10*h.opt.fontsize);
			ytOld		= get(h.hCB,'YTick');
			nTickOld	= numel(ytOld);
			nTick		= unless(h.opt.colorbarticks,nTickOld+iseven(nTickOld));
			ytNew		= GetInterval(1,nLUT,nTick);
			set(h.hCB,'YTick',ytNew);
			
			cKey			= arrayfun(@num2str,sigfig(MapValue(ytNew,1,nLUT,cmMin,cmMax),2),'UniformOutput',false);
			kMiddle			= round(numel(cKey)/2);
			
			if notfalse(h.opt.scalelabel)
				if isequal(h.opt.scalelabel,'%')
					cKey{kMiddle}	= [cKey{kMiddle} '%'];
				else
					cKey{kMiddle}	= [h.opt.scalelabel '=' cKey{kMiddle}];
				end
			end
			set(h.hCB,'YTickLabel',cKey);
		end
	%dim values
		if ~isempty(h.opt.dim) && isequal(h.opt.dimmethod,'alpha')
			hold on
			
			bDim	= ~bNaN & h.opt.dim;
			
			imDim	= imresize(bDim,[hIm wIm],'nearest');
			
			h.hIDim	= image(h.data.x{1},h.data.y{1},repmat(imDim,[1 1 3]),'Parent',h.hA);
			set(h.hIDim,'AlphaData',(1-h.opt.dimalpha)*imDim);
			
			hold off;
		end

%process labels
	h.opt.showxvalues	= false;
	h.opt.showyvalues	= false;
	
	SetLabels;
%post function
	h.opt.fpost	= @FPost;

%------------------------------------------------------------------------------%
function FPost(h)
	if h.opt.showgrid
		MoveToFront(h.hA,h.hGridVB);
		MoveToFront(h.hA,h.hGridHB);
		
		delete(h.hGridVS);
		delete(h.hGridHS);
	end
	
	set(h.hA,'XTick',[],'YTick',[]);
	
	if isfield(h,'hBox')
		MoveToFront(h.hA,h.hBox);
	end
end
%------------------------------------------------------------------------------%
function optD = GetStyleDefaults(strStyle)
	switch lower(strStyle)
		case 'color'
			optD.lut	=	'default';
		case 'bw'
			optD.lut	=	'grayscale';
		otherwise
			error(['"' tostring(strStyle) '" is not a valid confusion matrix plot style.']);
	end
end
%------------------------------------------------------------------------------%
function SetLabels()
% set the labels
	%get the vertical padding
		hTemp	= text(0,0,'M','FontName',h.opt.font,'FontSize',sFont.small,'Rotation',90);
		tExtent	= get(hTemp,'Extent');
		delete(hTemp);
		
		vPad	= 0.5*tExtent(4);
	
	%category labels
		if ~isempty(h.opt.columnlabel)
		%x labels
			kLVals		= conditional(h.opt.cornerlabel,1:nLabelColumn,1:nLabelColumn-1);
			nL			= numel(kLVals);
			
			h.hCMXLabel	= zeros(nL,1);
			
			for k=1:nL
				kL	= kLVals(k);
				
				%draw the text
				h.hCMXLabel(k)	= text(0,0,[h.opt.columnlabel{kL}],'Color',h.opt.textcolor,'Rotation',h.opt.xlabelrot,'VerticalAlignment','middle','HorizontalAlignment','right','FontName',h.opt.font,'FontWeight','bold','FontSize',10*h.opt.fontsize);
				p				= GetElementPosition(h.hCMXLabel(k));
				
				if h.opt.xlabelrot==90
					pTextL	= (kL-1/2)/nLabelColumn;
				else
				%move it so the upper right is under the center of the grid cell
					pTextL	= (kL-1/2)/nLabelColumn + (p.w/2)*(90-1.75*h.opt.xlabelrot)/90;
				end
				
				pTextB	= -0.02;
				
				MoveElement(h.hCMXLabel(k),'b',pTextB,'l',pTextL);
			end
		end
		if ~isempty(h.opt.rowlabel)
		%y labels
			kLVals		= conditional(h.opt.cornerlabel,1:nLabelRow,2:nLabelRow);
			nL			= numel(kLVals);
			
			h.hYLabel	= zeros(nL,1);
			
			for k=1:nL
				kL	= kLVals(k);
				
				%draw the text
				h.hCMYLabel(k)	= text(0,0,[h.opt.rowlabel{kL}],'Color',h.opt.textcolor,'Rotation',h.opt.ylabelrot,'VerticalAlignment','bottom','HorizontalAlignment','right','FontName',h.opt.font,'FontWeight','bold','FontSize',10*h.opt.fontsize);
				p				= GetElementPosition(h.hCMYLabel(k));
				
				if h.opt.ylabelrot==0
				%line it up with the grid cells
					ext		= get(h.hCMYLabel(k),'Extent');
					pTextB	= (nLabelRow - kL)/nLabelRow + 1/(2*nLabelRow) - ext(4)/2;
				else
				%move it so the lower right is left of the center of the grid cell
					pTextB	= (nLabelRow - (kL-1/2))/nLabelRow + (p.w/2)*(90-1.75*h.opt.ylabelrot)/90;
				end
				
				pTextL	= -0.01;
				
				MoveElement(h.hCMYLabel(k),'b',pTextB,'l',pTextL);
			end
			
			%make sure y labels don't go off the left edge
				arrayfun(@(h) set(h,'Units','pixels'),h.hCMYLabel);
				eYLabel	= arrayfun(@(h) get(h,'Extent'),h.hCMYLabel,'UniformOutput',false);
				arrayfun(@(h) set(h,'Units','data'),h.hCMYLabel);
				
				lYLabel	= cellfun(@(e) e(1),eYLabel);
				
				set(h.hA,'Units','pixels');
				p		= get(h.hA,'Position');
				pLeft	= max(p(1),-min(lYLabel)+5);
				p(3)	= p(3)-(pLeft-p(1));
				p(1)	= pLeft;
				set(h.hA,'Position',p);
				set(h.hA,'Units','normalized');
		end
	
	%set the ticks
		if ~isempty(h.opt.columnlabel)
			set(h.hA,'XTick',GetInterval(0,1,nL+1),'XTickLabel',[]);
			set(h.hA,'YTick',GetInterval(0,1,nL+1),'YTickLabel',[]);
		end
	
	%target/predictor
		if h.opt.tplabel
			h.hATP		= axes;
			set(h.hATP,'box','off','XTick',[],'YTick',[],'XColor',h.opt.background,'YColor',h.opt.background,'Position',[0 0 1 1],'Color',h.opt.background);
			
			h.hTarget		= text(0.03,1,'Targets','VerticalAlignment','top','HorizontalAlignment','left','Color',h.opt.textcolor,'FontName',h.opt.font,'FontWeight','bold','FontAngle','italic','FontSize',12*h.opt.fontsize);
			h.hPredictor	= text(0,0.97,'Predictors','VerticalAlignment','top','HorizontalAlignment','right','Color',h.opt.textcolor,'FontName',h.opt.font,'FontWeight','bold','FontAngle','italic','FontSize',12*h.opt.fontsize,'Rotation',90);
		end
	
	%values
		if h.opt.values
			axes(h.hA);
			
			cmShow			= sigfig(cm,h.opt.values_sigfig);
			[rValue,cValue]	= size(cmShow);
			nValue			= numel(cmShow);
			
			h.hValue	= zeros(rValue,cValue);
			for kR=1:rValue
				for kC=1:cValue
					if cmCol(kR,kC)~=0
						yText	= (rValue-kR+0.5)/rValue;
						xText	= (kC-0.5)/cValue;
						
						colCell	= lut(cmColOrig(kR,kC),:);
						colText	= unless(h.opt.values_color{kR,kC},conditional(cmCol(kR,kC)==-1,[1 1 1],GetGoodTextColor(colCell)));
						
						strValue	= [num2str(cmShow(kR,kC)) conditional(h.opt.values_unit,h.opt.scalelabel,'')];
						
						h.hValue(kR,kC)	= text(xText,yText,strValue,'Color',colText,'HorizontalAlignment','center','VerticalAlignment','middle','FontWeight',h.opt.fontweight,'FontSize',10*h.opt.fontsize);
					end
				end
			end
		end
end
%------------------------------------------------------------------------------%

end
