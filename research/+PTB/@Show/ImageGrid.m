function ImageGrid(shw,cIm,varargin)
% PTB.Show.ImageGrid
% 
% Description:	show a grid of images
% 
% Syntax:	shw.ImageGrid(cIm,[s]=<no resize>,[a]=0,<options>)
% 
% In:
%	cIm	- a cell of images in the arrangement in which they should be shown
%		  (e.g a 2x3 cell leads to a 2x3 grid of images)
%	[s]	- the (w,h) size of the images, in degrees of visual angle (or a single
%		  value to fit images within a square box of that size), or a cell of
%		  image sizes
%	[a]	- the rotation of the images about their center, in clockwise degrees
%		  from vertical, or an array of rotations
%	<options>:
%		window:			('main') the name of the window on which to show the
%						images
%		cross:			(false) for four-element inputs, true to show them in a
%						cross pattern, with the first one top, two and three to
%						the left and right, and four on bottom
%		spacing:		(<auto>) the spacing between images, in degrees of
%						visual angle.  either a scalar or a two-element [w h]
%						array.
%		border:			(false) true to show a border around the images, or a
%						logical array specifying which images to show borders
%						around
%		border_color:	('black') the border color, or a cell of border colors
%		border_size:	(1/6) the border thickness, in degrees of visual angle,
%						or an array of border thicknesses
% 
% Updated: 2011-12-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'spacing'		, []		, ...
						'cross'			, false		, ...
						'border'		, false		, ...
						'border_color'	, 'black'	, ...
						'border_size'	, 1/6		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<3 || (isnumeric(varargin{1}) && (nargin<4 || (isnumeric(varargin{2}) && nargin<5)))
		opt		= optDefault;
		
		[s,a]	= ParseArgs(varargin,[],0);
	else
		[s,a,opt]	= ParseArgs(varargin,[],0,cOptDefault{:});
	end

sIm	= size(cIm);
nIm	= numel(cIm);

[h,sz,rect,szVA]	= shw.parent.Window.Get(opt.window);

%get the image sizes and rotations
	s			= repto(ForceCell(s),sIm);
	bDefault	= cellfun(@isempty,s);
	s(bDefault)	= cellfun(@(im) shw.parent.Window.px2va([size(im,2) size(im,1)]),cIm(bDefault),'UniformOutput',false);
	
	kScalar	= find(cellfun(@isscalar,s));
	nScalar	= numel(kScalar);
	for kS=1:nScalar
		sPxIm			= size(cIm{kScalar(kS)});
		sPxIm			= sPxIm(2:-1:1);
		s{kScalar(kS)}	= s{kScalar(kS)}.*(sPxIm/max(sPxIm));
	end
	
	a	= num2cell(repto(a,sIm));
%get the grid cell size
	sCell	= max(cell2mat(reshape(s,[],1)),1);
	sCell	= sCell([2 1]);
%get the image positions
	if nIm==4 && opt.cross
	%show as a cross
		%get the image spacing
			if isempty(opt.spacing)
				sSpace		= szVA - 3*sCell;
				opt.spacing	= sSpace./4;
			end
			opt.spacing	= repto(opt.spacing,[1 2]);
		%cell locations
			offset	= sCell + opt.spacing;
			xGrid	= reshape({0 -offset(1) offset(1) 0},sIm);
			yGrid	= reshape({-offset(2) 0 0 offset(2)},sIm);
	else
	%show as a grid
		%get the image spacing
			if isempty(opt.spacing)
			%calculate the spacing
				%number of spaces
					nSpace	= sIm([2 1])+1;
				%amount of space to distribute
					sSpace		= szVA - sIm([2 1]).*sCell;
					opt.spacing	= sSpace./nSpace;
			end
			opt.spacing	= repto(opt.spacing,[1 2]);
		%grid size
			sGrid	= sIm([2 1]).*sCell + (sIm([2 1])-1).*opt.spacing;
		%cell coordinates
			pEnd	= (sGrid-sCell)/2;
			xStep	= GetInterval(-pEnd(1),pEnd(1),sIm(2));
			yStep	= GetInterval(-pEnd(2),pEnd(2),sIm(1));
		%cell locations
			xGrid	= num2cell(repmat(xStep,[sIm(1) 1]));
			yGrid	= num2cell(repmat(yStep',[1 sIm(2)]));
	end
%show the images
	if any(opt.border)
		opt.border			= repto(ForceCell(opt.border),sIm);
		opt.border_color	= repto(ForceCell(opt.border_color),sIm);
		opt.border_size		= repto(ForceCell(opt.border_size),sIm);
		
		cellfun(@(im,x,y,s,a,bb,bc,bs) shw.Image(im,[x y],s,a,'window',h,'border',bb,'border_color',bc,'border_size',bs),cIm,xGrid,yGrid,s,a,opt.border,opt.border_color,opt.border_size);
	else
		cellfun(@(im,x,y,s,a) shw.Image(im,[x y],s,a,'window',h),cIm,xGrid,yGrid,s,a);
	end
