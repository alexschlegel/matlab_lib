function hLUT = FigLUT(LUT,varargin)
% FigLUT
% 
% Description:	draw an LUT key (or keys) on an axes.  the gradient is created
%				with many discrete-stepped faces rather than using the
%				CData/FaceVertexAlphaData properties to be compatible with
%				plot2svg.
% 
% Syntax:	hLUT = FigLUT(LUT,[x]=<center>,[y]=<center>,[w]=<60% of axis width>,[h]=<60% of axis height>,[vMin]=<none>,[vMax]=<none>,<options>)
% 
% In:
%	LUT		- the nColor x 3 LUT, or cell of such
% 	[x]		- the x value of the LUT key center
%	[y]		- the y value of the LUT key center
%	[w]		- the width of the LUT keys (one value for all)
%	[h]		- the height of the LUT key (one value for all)
%	[vMin]	- an nLUTx1 array of values corresponding to the first LUT colors
%	[vMax]	- an nLUTx1 array of values corresponding to the last LUT colors
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		lut_t:			(<uniform>) the parametric positions of the LUT values,
%						or a cell of such
%		alpha:			(1) an array of alpha value control points (0->1), or a
%						cell of such
%		alpha_t:		(<uniform>) the parametric positions of the alpha values,
%						or a cell of such
%		fontname:		('Arial') the font name
%		fontsize:		(12) the font size
%		fontweight:		('normal') the font weight
%		sigfig:			(4) number of significant figures to show for the min/max
%						values
%		dpi:			(300) the resolution of the gradient, in dots per inch
%		borderwidth:	(1.5) the width of the border
%		bordercolor:	(<auto>) the color of the border
%		keybackground:	(<same as axes>) the background color of the key(s)
%		prefixmin:		('') the prefix for the minimum key label
% 
% Out:
% 	hLUT		- a struct of relevant handles
% 
% Updated: 2014-02-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[x,y,w,h,vMin,vMax,opt]	= ParseArgs(varargin,[],[],[],[],[],[],...
								'ha'			, []		, ...
								'lut_t'			, []		, ...
								'alpha'			, 1			, ...
								'alpha_t'		, []		, ...
								'fontname'		, 'Arial'	, ...
								'fontsize'		, 12		, ...
								'fontweight'	, 'normal'	, ...
								'sigfig'		, 4			, ...
								'dpi'			, 300		, ...
								'borderwidth'	, 1.5		, ...
								'bordercolor'	, []		, ...
								'keybackground'	, []		, ...
								'prefixmin'		, ''		  ...
								);

[LUT,opt.lut_t,opt.alpha,opt.alpha_t]			= ForceCell(LUT,opt.lut_t,opt.alpha,opt.alpha_t);
[LUT,vMin,vMax,opt.lut_t,opt.alpha,opt.alpha_t]	= FillSingletonArrays(LUT,vMin,vMax,opt.lut_t,opt.alpha,opt.alpha_t);
nLUT											= numel(LUT);

if nLUT>2
	error('Only up to 2 LUTs are implemented.');
end

[opt.lut_t,opt.alpha,opt.alpha_t]	= varfun(@(c) cellfun(@(x) reshape(x,[],1),c,'UniformOutput',false),opt.lut_t,opt.alpha,opt.alpha_t);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

colAxes				= get(opt.ha,'Color');
colText				= GetGoodTextColor(colAxes);
opt.bordercolor		= unless(opt.bordercolor,colText);
opt.keybackground	= unless(opt.keybackground,colAxes);

%get the LUT positions
	xLim	= get(opt.ha,'XLim');
	yLim	= get(opt.ha,'YLim');
	
	x	= unless(x,mean(xLim));
	w	= unless(w,0.6*range(xLim));
	y	= unless(y,mean(yLim));
	
	switch nLUT
		case 1
			h	= unless(h,0.6*range(yLim));
			
			yKeyMin			= y - h/2;
			yKeyMax			= y + h/2;
			strKeyMinVAlign	= 'top';
			strKeyMaxVAlign	= {'bottom'};
		case 2
			[puW,puH]	= PointsPerUnit(opt.ha);
			yPad		= 2*opt.fontsize/puH;
			
			yKeyMin			= y;
			strKeyMinVAlign	= 'middle';
			strKeyMaxVAlign	= {'bottom','top'};
			
			h		= unless(h,(0.8*range(yLim)-yPad)/2);
			y		= [y+(h+yPad)/2; y-(h+yPad)/2];
			
			yKeyMax	= [y(1)+h/2; y(2)-h/2];
			
			LUT{2}	= LUT{2}(end:-1:1,:);
	end
	
	y	= reshape(y,size(LUT));
%corner coordinates
	xMin	= x - w/2;
	xMax	= x + w/2;
	yMin	= y - h/2;
	yMax	= y + h/2;
%get the number of faces to use
	%height of the axes
		uOld	= get(opt.ha,'Units');
		set(opt.ha,'Units','inches');
		pA		= get(opt.ha,'Position');
		htA		= pA(4);
		set(opt.ha,'Units',uOld);
	%height of the LUT
		htLUT	= htA*h/range(yLim);
	%number of faces
		nFace	= round(htLUT*opt.dpi);
%faces.  make two sets with overlap to avoid small black lines in between faces
%if the SVG renderer isn't exact
	%face coordinates
		hFace	= h/nFace;
		yFace	= arrayfun(@(mn,mx) GetInterval(mn+hFace/2,mx-hFace/2,nFace),yMin,yMax,'UniformOutput',false);
		yFace2	= arrayfun(@(mn,mx) GetInterval(mn+hFace,mx-hFace,nFace-1),yMin,yMax,'UniformOutput',false);
	%face colors
		col		= cellfun(@(lt,t) MakeLUT(lt,nFace,t),LUT,opt.lut_t,'UniformOutput',false);
		col2	= cellfun(@(c) c(1:end-1,:),col,'UniformOutput',false);
%and the alpha values (account for the overlap in faces)
	aEffective	= cellfun(@(a,t) MakeLUT(a,nFace,t),opt.alpha,opt.alpha_t,'UniformOutput',false);
	a			= cellfun(@(ae) 1 - sqrt(1 - ae),aEffective,'UniformOutput',false);
	a2			= cellfun(@(al) al(1:end-1),a,'UniformOutput',false);
%create the border(s)
	if opt.borderwidth~=0
		hLUT.hBorder	= arrayfun(@(k) patch([xMin; xMin; xMax; xMax],[yMin(k); yMax(k); yMax(k); yMin(k)],0,'FaceColor',opt.keybackground,'EdgeColor',opt.bordercolor,'LineWidth',opt.borderwidth),(1:nLUT)');
	end
%create the gradient(s)
	hLUT.hFace2	= cellfun(@(yf,c,al) arrayfun(@(k) PatchBox(x,yf(k),w,hFace,'ha',opt.ha,'color',c(k,:),'alpha',al(k),'borderwidth',0),(1:nFace-1)'),yFace2,col2,a2,'UniformOutput',false);
	hLUT.hFace	= cellfun(@(yf,c,al) arrayfun(@(k) PatchBox(x,yf(k),w,hFace,'ha',opt.ha,'color',c(k,:),'alpha',al(k),'borderwidth',0),(1:nFace)'),yFace,col,a,'UniformOutput',false);
%add min/max values
	if ~isempty(vMin)
		if all(vMin==vMin(1))
			vMin	= vMin(1);
		end
		
		vMin		= sigfig(vMin,opt.sigfig);
		strMin		= [opt.prefixmin join(vMin,'/')];
		hLUT.hTMin	= text(x,yKeyMin,strMin,...
						'Color'					, colText			, ...
						'FontName'				, opt.fontname		, ...
						'FontSize'				, opt.fontsize		, ...
						'FontWeight'			, opt.fontweight	, ...
						'HorizontalAlignment'	, 'center'			, ...
						'VerticalAlignment'		, strKeyMinVAlign	  ...
						);
	end
	
	if ~isempty(vMax)
		hLUT.hTMax	= zeros(nLUT,1);
		
		for kL=1:nLUT
			strMax			= num2str(sigfig(vMax(kL),opt.sigfig));
			hLUT.hTMax(kL)	= text(x,yKeyMax(kL),strMax,...
								'Color'					, colText				, ...
								'FontName'				, opt.fontname			, ...
								'FontSize'				, opt.fontsize			, ...
								'FontWeight'			, opt.fontweight		, ...
								'HorizontalAlignment'	, 'center'				, ...
								'VerticalAlignment'		, strKeyMaxVAlign{kL}	  ...
								);
		end
	end
