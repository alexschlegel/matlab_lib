function TextureGrid(shw,hT,varargin)
% PTB.Show.TextureGrid
% 
% Description:	show a grid of texture
% 
% Syntax:	shw.TextureGrid(hT,[rect]=<all>,[s]=<no resize>,[a]=0,<options>)
% 
% In:
%	hT		- an array of texture handles or a cell of texture names, in the
%			  arrangement in which they should be shown (e.g a 2x3 array leads
%			  to a 2x3 grid of textures)
%	[rect]	- the rect of the portion of the textures to transfer, or a cell
%			  of rects
%	[s]		- the (w,h) size of the textures, in degrees of visual angle, or a
%			  cell of texture sizes.  a single value may be specified to fit the
%			  texture within a square box of that size.
%	[a]		- the rotation of the textures about their center, in clockwise
%			  degrees from vertical, or an array of rotations
%	<options>:
%		window:		('main') the name of the window on which to show the textures
%		cross:		(false) for four-element inputs, true to show them in a cross
%					pattern, with the first one top, two and three to the left
%					and right, and four on bottom
%		spacing:	(<auto>) the spacing between textures, in degrees of visual
%					angle.  either a scalar or a two-element [w h] array.
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'cross'			, false		, ...
						'spacing'		, []		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<3 || (isnumeric(varargin{1}) && (nargin<4 || (isnumeric(varargin{2}) && (nargin<5 || (isnumeric(varargin{3}) && nargin<6)))))
		opt	= optDefault;
		
		[rect,s,a]	= ParseArgs(varargin,[],[],0);
	else
		[rect,s,a,opt]	= ParseArgs(varargin,[],[],0,cOptDefault{:});
	end

if iscell(hT)
	hT	= cellfun(@(t) shw.parent.Window.Get(t),hT,'UniformOutput',false);
else
	hT	= num2cell(hT);
end
sT	= size(hT);
nT	= numel(hT);

[h,sz,dummy,szVA]	= shw.parent.Window.Get(opt.window);

%get the texture rects, sizes and rotations
	rect			= repto(ForceCell(rect),sT);
	bDefault		= cellfun(@isempty,rect);
	rect(bDefault)	= cellfun(@(t) Screen('Rect',t),hT(bDefault),'UniformOutput',false);
	
	s			= repto(ForceCell(s),sT);
	bDefault	= cellfun(@isempty,s);
	s(bDefault)	= cellfun(@(r) shw.parent.Window.px2va(r(3:4)-r(1:2)),rect(bDefault),'UniformOutput',false);
	
	kScalar	= find(cellfun(@isscalar,s));
	nScalar	= numel(kScalar);
	for kS=1:nScalar
		sPxT			= rect{kScalar(kS)}(3:4) - rect{kScalar(kS)}(1:2);
		s{kScalar(kS)}	= s{kScalar(kS)}.*(sPxT/max(sPxT));
	end
	
	a	= num2cell(repto(a,sT));
%get the grid cell size
	sCell	= max(cell2mat(reshape(s,[],1)),1);
	sCell	= sCell([2 1]);
%get the texture positions
	if nT==4 && opt.cross
	%show as a cross
		%get the texture spacing
			if isempty(opt.spacing)
				sSpace		= szVA - 3*sCell;
				opt.spacing	= sSpace./4;
			end
			opt.spacing	= repto(opt.spacing,[1 2]);
		%cell locations
			offset	= sCell + opt.spacing;
			xGrid	= reshape({0 -offset(1) offset(1) 0},sT);
			yGrid	= reshape({-offset(2) 0 0 offset(2)},sT);
	else
	%show as a grid
		%get the texture spacing
			if isempty(opt.spacing)
			%calculate the spacing
				%number of spaces
					nSpace	= sT([2 1])+1;
				%amount of space to distribute
					sSpace		= szVA - sT([2 1]).*sCell;
					opt.spacing	= sSpace./nSpace;
			end
			opt.spacing	= repto(opt.spacing,[1 2]);
		%get the texture positions
			%grid size
				sGrid	= sT([2 1]).*sCell + (sT([2 1])-1).*opt.spacing;
			%cell coordinates
				pEnd	= (sGrid-sCell)/2;
				xStep	= GetInterval(-pEnd(1),pEnd(1),sT(2));
				yStep	= GetInterval(-pEnd(2),pEnd(2),sT(1));
			%cell locations
				xGrid	= num2cell(repmat(xStep,[sT(1) 1]));
				yGrid	= num2cell(repmat(yStep',[1 sT(2)]));
	end
%show the textures
	cellfun(@(t,x,y,r,s,a) shw.Texture(t,r,[x y],s,a,'window',h),hT,xGrid,yGrid,rect,s,a);
