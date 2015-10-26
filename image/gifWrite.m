function gifWrite(im,strPathOut,varargin)
% gifWrite
% 
% Description:	write an image array to a gif
% 
% Syntax: gifWrite(im,strPathOut,[ifo]=<none>,<options>)
% 
% In:
%	im			- an H x W x 3 x nFrame set of rgb image frames, or an
%				  H x W x nFrame set of index image frames
%	strPathOut	- the output file path
%	[ifo]		- an info struct returned by gifRead
%	<options>:
%		map:			(<from ifo or auto>) the nColor x 3 color map to use
%		background:		(<from ifo or 1>) the index of the background color, or
%						an array of indices, one for each frame
%		transparent:	(<from ifo or none>) the index of the transparent color,
%						or an array of indices, one for each frame
%		delay:			(<from ifo or 0>) the frame delay, in ms, or an array of
%						delays, one for each frame
%		dispose:		(<from ifo or 'doNotSpecify'>) the frame disposal method
%						(see imwrite)
% 
% Updated:	2015-10-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[ifo,opt]	= ParseArgs(varargin,struct,...
					'map'			, []	, ...
					'background'	, []	, ...
					'transparent'	, []	, ...
					'delay'			, []	, ...
					'dispose'		, []	  ...
	);
	
	assert(isstruct(ifo),'ifo must be a struct');
	
	%color map
		if isempty(opt.map)
			if isfield(ifo,'map')
				opt.map	= ifo.map;
			end
		end
	
	%background color index
		if isempty(opt.background)
			if isfield(ifo,'background')
				opt.background	= ifo.background;
				
				opt.background(isnan(opt.background))	= 1;
			else
				opt.background	= 1;
			end
		end
		
		szBackground	= size(opt.background);
		assert(numel(szBackground)==2 && sum(szBackground==1)>0,'background option must be 1xN or Nx1');
		
		opt.background	= reshape(opt.background,[],1);
	
	%transparent color index
		if isempty(opt.transparent)
			if isfield(ifo,'transparent')
				opt.transparent	= ifo.transparent;
			else
				opt.transparent	= NaN;
			end
		end
		
		szTransparent	= size(opt.transparent);
		assert(numel(szTransparent)==2 && sum(szTransparent==1)>0,'transparent option must be 1xN or Nx1');
		
		opt.transparent	= reshape(opt.transparent,[],1);
	
	%frame delay
		if isempty(opt.delay)
			if isfield(ifo,'delay')
				opt.delay	= ifo.delay;
			else
				opt.delay	= 0;
			end
		end
		
		szDelay	= size(opt.delay);
		assert(numel(szDelay)==2 && sum(szDelay==1)>0,'delay option must be 1xN or Nx1');
		
		opt.delay	= reshape(opt.delay,[],1);
	
	%frame disposal method
		if isempty(opt.dispose)
			if isfield(ifo,'dispose')
				opt.dispose	= ForceCell(ifo.dispose);
			else
				opt.dispose	= {'doNotSpecify'};
			end
		else
			opt.dispose	= ForceCell(opt.dispose);
		end
		
		szDispose	= size(opt.dispose);
		assert(numel(szDispose)==2 && sum(szDispose==1)>0,'dispose option must be 1xN or Nx1');
		
		opt.dispose	= reshape(opt.dispose,[],1);

%make sure we have a valid image
	%image size info
		sIm		= size(im);
		nDim	= numel(sIm);
	
	%some automatic conversions
		if isa(im,'logical') && nDim==2
			im		= repmat(double(im),[1 1 3]);
			sIm		= [sIm 3 1];
			nDim	= 4;
		end
	
	%validate the image
		switch class(im)
			case 'double'
				assert(all(im(:)>=0) && all(im(:)<=1),'double image values must range from 0 to 1');
				assert((nDim==3 || nDim==4) && sIm(3)==3,'double images must be H x W x 3 x nFrame');
				
				if nDim==3
					sIm		= [sIm 1];
					nDim	= 4;
				end
				
				%convert to an index map
					%stack the frames
						im	= permute(im,[1 3 2 4]);
						im	= im(:,:,:);
						im	= permute(im,[1 3 2]);
					
					if isempty(opt.map)
						[im,opt.map]	= rgb2ind(im,256);
					else
						im	= rgb2ind(im,opt.map);
					end
					
					%unstack the frames
						im	= reshape(im,sIm(1),sIm(2),sIm(4));
			case 'uint8'
				assert(nDim==3,'index images must be H x W x nFrame');
				assert(all(isint(im(:))) && all(im(:)>0),'index image values must be positive integers');
				
				if isempty(opt.map)
					nIndex	= max(im(:));
					opt.map	= repmat(GetInterval(0,1,nIndex)',[1 3]);
				end
			otherwise
				error('invalid image type');
		end
	
	nFrame	= size(im,3);

%make sure we have one option value for each frame
	opt.background	= repto(opt.background,[nFrame 1]);
	opt.transparent	= repto(opt.transparent,[nFrame 1]);
	opt.delay		= repto(opt.delay,[nFrame 1]);
	opt.dispose		= repto(opt.dispose,[nFrame 1]);

%write each frame
	for kF=1:nFrame
		cOpt	=	{'DelayTime' opt.delay(kF) 'DisposalMethod' opt.dispose{kF}};
		
		if ~isnan(opt.transparent(kF))
			cOpt	= [cOpt 'TransparentColor' opt.transparent(kF)-1];
		end
		
		if kF==1
			cOpt	= [cOpt 'BackgroundColor' opt.background(kF)-1 'Loopcount' inf];
		else
			cOpt	= [cOpt 'WriteMode' 'append'];
		end
		
		imwrite(im(:,:,kF),opt.map,strPathOut,cOpt{:});
	end
