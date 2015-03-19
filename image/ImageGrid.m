function varargout = ImageGrid(im,varargin)
% ImageGrid
% 
% Description:	create a grid of images
% 
% Syntax:	imGrid = ImageGrid(im,<options>)
% 
% In:
% 	im	- a cell of paths to images, cell of images, a 4D array of images, or
%		  a cell of any of the above to construct multiple images
%	<options>:
%		h:			(no resize) height of the output image
%		gridsize:	(<auto>) the [row column] output grid size
%		interp:		('bilinear') the resize interpolation method
%		save:		({}) a path or cell of path to which to save images
%		silent:		(false) true to not show progress bar/prompts
%
% Out:
% 	imGrid	- the image grid or cell of image grids
% 
% Updated: 2013-03-21
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dWarning	= 10000;

opt	= ParseArgs(varargin,...
		'h'			, []			, ...
		'gridsize'	, []			, ...
		'interp'	, 'bilinear'	, ...
		'save'		, {}			, ...
		'silent'	, false			  ...
		);

%parse the input
	switch class(im)
		case 'cell'
			if numel(im)==0
				imGrid	= [];
				return;
			end
			
			switch class(im{1})
				case 'double'
					if ndims2(im{1})==4
						opt.save				= ForceCell(opt.save);
						[im,opt.save]			= FillSingletonArrays(im,opt.save);
						[varargout{1:nargout}]	= cellfun(@(x,y) ImageGrid(x,varargin{:},'save',y),im,opt.save,'UniformOutput',false);
						return;
					end
				case 'cell'
					opt.save				= ForceCell(opt.save);
					[im,opt.save]			= FillSingletonArrays(im,opt.save);
					[varargout{1:nargout}]	= cellfun(@(x,y) ImageGrid(x,varargin{:},'save',y),im,opt.save,'UniformOutput',false);
					return;
			end
		case 'double'
			switch ndims2(im)
				case {1,2,3}
					im	= {im};
				case 4
					s	= num2cell(size(im));
					im	= mat2cell(im,s{1:3},ones(s{4},1));
				otherwise
					error('Unsupported image array size.');
			end
	end
	nIm	= numel(im);

%get the optimal image grid size (minimize dead space while staying squarish)
	if ~isempty(opt.gridsize)
		r	= opt.gridsize(1);
		c	= opt.gridsize(2);
	elseif ~iscell(im) || any(size(im)==1)
		rcTry		= 1:sqrt(nIm);
		crTry		= ceil(nIm./rcTry);
		s			= 1./((1+rcTry.*crTry-nIm).*(1+crTry-rcTry).^3);
		[sMax,k]	= max(s);
		rc			= [rcTry(k) crTry(k)];
		r			= min(rc);
		c			= max(rc);
	else
		[r,c] = size(im);
	end
	
	im	= reshape(im,[],1);
	
	hCell	= opt.h/r;
	
%load the images
	im	= cellfunprogress(@(x) LoadResize(x,hCell),im,'UniformOutput',false,'label','Image Grid','silent',opt.silent);

%initialize the image
	%get the size of the biggest image
		s		= cell2mat(cellfun(@size,im,'UniformOutput',false));
		if ndims2(s)==2
			s	= [s ones(nIm,1)];
		end
		hCell	= max(s(:,1));
		wCell	= max(s(:,2));
	
	if isempty(opt.h)
		h	= hCell*r;
	else
		h	= opt.h;
	end
	w	= wCell*c;
	
	mxDim	= max(h,w);
	if ~opt.silent && mxDim>=dWarning
		yn	= ask(['Maximum image dimension will be ' num2str(h) 'px.  Continue?'],'title',mfilename,'choice',{'Yes','No'},'default','No');
		if isequal(yn,'No')
			error('Aborted by user.');
		end
	end
	
	if ~opt.silent
		status(['Image grid will be ' num2str(h) 'x' num2str(w)]);
	end
	
	imGrid	= ones(h,w,s(1,3));

%insert the images
	for kIm=1:nIm
		%kR	= floor((kIm-1)/c);
		%kC	= (kIm-1)-kR*c;
		kC	= floor((kIm-1)/r);
		kR	= (kIm-1)-kC*r;
		
		tInsert	= hCell*kR;
		lInsert	= wCell*kC;
		
		imGrid	= InsertImage(imGrid,im{kIm},[tInsert lInsert]);
	end
	
%save/return the image
	if ~isempty(opt.save)
		rgbWrite(imGrid,opt.save);
	end
	if nargout>0
		varargout{1}	= imGrid;
	end

%------------------------------------------------------------------------------%
function im = LoadResize(im,h)
	if ischar(im)
		im	= rgbRead(im);
	end
	
	if ~isempty(h)
		hPre	= size(im,1);
		im		= imresize(im,h/hPre,opt.interp);
	end
end
%------------------------------------------------------------------------------%

end
