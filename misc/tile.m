function x = tile(x,varargin)
% tile
% 
% Description:	tile an ND array into a (N-1)D grid
% 
% Syntax:	t = tile(x,[dim]=<last>,<options>)
% 
% In:
% 	x		- an ND array
%	[dim]	- the dimension along which to tile
%	<options>:
%		border:	(<none>) the value of the border to add around each tile piece
% 
% Out:
% 	t	- the tiled array
% 
% Example:
%~ 	n		= 100;
%~ 	t		= linspace(-1,1,n);
%~ 	[x,y,z]	= ndgrid(t,t,t);
%~ 	r		= sqrt(x.^2 + y.^2 + z.^2);
%~ 	im		= normalize(tile(r));
%~ 	imshow(im);
% 
% Updated: 2012-07-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s		= size(x);
sCell	= s(1:end-1);
nInCell	= prod(sCell);
nCell	= s(end);
nd		= numel(s);

[dim,opt]	= ParseArgs(varargin,nd,...
				'border'	, []	  ...
				);

%get the optimal image grid size (minimize dead space while staying squarish)
	rcTry		= 1:sqrt(nCell);
	crTry		= ceil(nCell./rcTry);
	wtf			= 1./((1+rcTry.*crTry-nCell).*(1+crTry-rcTry).^3);
	[wtfMax,k]	= max(wtf);
	rc			= [rcTry(k) crTry(k)];
	r			= min(rc);
	c			= max(rc);

%permute
	x	= permute(x,[1:dim-1 dim+1:nd dim]);
%break into cells
	csCell	= num2cell(sCell);
	x		= squeeze(mat2cell(x,csCell{:},ones(nCell,1)));
%pad the grid with NaNs
	[x{nCell+1:r*c}]	= deal(NaN(sCell));
%border each cell
	if ~isempty(opt.border)
		x	= cellfun(@(x) border(x,opt.border),x,'UniformOutput',false);
	end
%gridify
	x	= reshape(x,c,r)';
%arrayify
	x	= cell2mat(x);

