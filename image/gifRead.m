function [im,ifo] = gifRead(strPathGIF,varargin)
% gifRead
% 
% Description:	read a gif file
% 
% Syntax:	[im,ifo] = gifRead(strPathGIF) OR
% 
% In:
%	strPathGIF	- the path to a gif file, or a cell of paths to image frames
%	<options>:
%		rgb:		(true) true to convert the output from an index to an RGB
%					image
%		background:	([0 0 0]) the background color. only applies when a cell of
%					file paths is passed and some need to be padded
% 
% Out:
%	im		- if the <rgb>==true, then an H x W x 3 x nFrame array of RGB image
%			  frames. otherwise, an H x W x nFrame array of index image frames.
%	ifo		- a struct of info about the gif
% 
% Updated:	2015-10-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%defaults
	im	= [];
	ifo	= struct('version','89a','background',NaN,'transparent',NaN,'delay',0,'dispose',{{'doNotSpecify'}});

%parse the inputs
	opt	= ParseArgs(varargin,...
			'rgb'			, true		, ...
			'background'	, [0 0 0]	  ...
			);

switch class(strPathGIF)
	case 'cell'	%cell of frame paths
		if isempty(strPathGIF)
			return;
		end
		
		%get info about each frame
			s	= cellfun(@imfinfo,strPathGIF,'uni',false);
			
			nFrame	= numel(s);
		
		%transfer existing properties
			cFieldTransfer	= {'background';'transparent';'delay';'dispose'};
			nFieldTransfer	= numel(cFieldTransfer);
			
			for kT=1:nFieldTransfer
				strField		= cFieldTransfer{kT};
				ifo.(strField)	= repmat(ifo.(strField),[nFrame 1]);
				
				for kF=1:nFrame
					if isfield(s{kF},strField)
						if iscell(ifo.(strField))
							ifo.(strField){kF}	= s{kF}.(strField);
						else
							ifo.(strField)(kF)	= s{kF}.(strField);
						end
					end
				end
			end
		
		%read the frames
			im	= cell(nFrame,1);
			
			for kF=1:nFrame
				switch lower(s{kF}.Format)
					case 'gif'
						[im{kF},map]	= imread(strPathGIF{kF});
						im{kF}			= ind2rgb(im{kF},map);
					otherwise
						im{kF}	= rgbRead(strPathGIF{kF});
				end
			end
		
		%make sure we have uniform image sizes
			szIm	= cellfun(@size,im,'uni',false);
			szMax	= max(cat(1,szIm{:}),[],1);
			
			for kF=1:nFrame
				if szIm{kF}(1)<szMax(1) || szIm{kF}(2)<szMax(2)
					im{kF}	= imPad(im{kF},opt.background,szMax(1),szMax(2));
				end
			end
		
		%convert to an index map
			%stack the frames
				imInd	= cat(1,im{:});
			
			[imInd,ifo.map]	= rgb2ind(imInd,256);
			
			if ~opt.rgb
				%unstack the frames
					im	= reshape(imInd,szIm(1),nFrame,szIm(2));
					im	= permute(im,[1 3 2]);
			else
				im	= cat(4,im{:});
			end
	case 'char'
		%get information about the gif
			s	= imfinfo(strPathGIF);
			
			ifo.version		= s(1).FormatVersion;
			
			if isfield(s,'BackgroundColor')
				ifo.background	= reshape([s.BackgroundColor],[],1);
			else
				ifo.background	= NaN;
			end
			
			if isfield(s,'TransparentColor')
				ifo.transparent	= reshape([s.TransparentColor],[],1);
			else
				ifo.transparent	= NaN;
			end
			
			ifo.delay		= reshape([s.DelayTime]/100,[],1);
			ifo.dispose		= reshape({s.DisposalMethod},[],1);

		%read the images
			[im,ifo.map]	= imread(strPathGIF);

		%convert to RGB
			if opt.rgb
				im	= arrayfun(@(k) ind2rgb(im(:,:,1,k),ifo.map),(1:size(im,4)),'uni',false);
				im	= cat(4,im{:});
			else
				im	= permute(im,[1 2 4 3]);
			end
	otherwise
		error('invalid input path');
end
