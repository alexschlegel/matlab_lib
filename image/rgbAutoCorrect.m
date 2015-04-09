function rgbc = rgbAutoCorrect(rgb,varargin)
% rgbAutoCorrect
% 
% Description:	attempt to autocorrect a photo
% 
% Syntax:	rgbc 		= rgbAutoCorrect(rgb,<options>) OR
%			[cPathOut]	= rgbAutoCorrect(rgb,<options>)
% 
% In:
% 	rgb	- an rgb photo loaded with rgbRead, a string/cell of paths to images, or
%		  a directory containing images
%	<options>:
%		compare:		(false) true to compare the two images
%		white_cutoff:	(0) cutoff the upper white_cutoff fraction of values at
%						white
%		black_cutoff:	(0) cutoff the lower white_cutoff fraction of values at
%						black
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	rgbc		- the autocorrected photo
%	cPathOut	- the output image path(s)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch class(rgb)
	case 'char'
		if isdir(rgb)
			f		= imformats;
			rgbc	= rgbAutoCorrect(FindFilesByExtension(rgb,[f.ext]),varargin{:});
			if numel(rgbc)>0
				rgbc	= PathGetDir(rgbc{1});
			end
		else
			rgbc	= rgbAutoCorrect({rgb},varargin{:});
		end
	case 'cell'
		opt	= ParseArgs(varargin,...
				'compare'		, []	, ...
				'white_cutoff'	, []	, ...
				'black_cutoff'	, []	, ...
				'silent'		, false	  ...
				);
		
		nIm			= numel(rgb);
		rgbc		= cell(nIm,1);
		bOverwrite	= [];
		
		progress('action','init','total',nIm,'label','Auto-correcting images');
		for kIm=1:nIm
			[strDirIn,strPathPre,strExt]	= PathSplit(rgb{kIm});
			
			strDirOut	= DirAppend(strDirIn,'autocorrect');
			if ~CreateDirPath(strDirOut)
				error(['Directory "' strDirOut '" could not be created.']);
			end
			
			rgbc{kIm}	= PathUnsplit(strDirOut,strPathPre,strExt);
			
			if FileExists(rgbc{kIm})
				if isempty(bOverwrite)
					if ~opt.silent
						res	= ask(['Autocorrected ' PathGetFilename(rgbc{kIm}) ' already exists.  Overwrite?'],'title','autocorrect','choice',{'Always','Never','Cancel'},'default','Never');
						if isempty(res) || isequal(res,'Cancel');
							progress('action','end');
							error('User aborted.');
						else
							bOverwrite	= isequal(res,'Always');
							if ~bOverwrite
								progress;
								continue;
							end
						end
					else
						bOverwrite	= true;
					end
				else
					if ~bOverwrite
						progress;
						continue;
					end
				end
			end
			
			im	= rgbRead(rgb{kIm});
			im	= rgbAutoCorrect(im,varargin{:});
			rgbWrite(im,rgbc{kIm});
			
			progress;
		end
	otherwise
		opt	= ParseArgs(varargin,...
				'compare'		, false	, ...
				'white_cutoff'	, 0		, ...
				'black_cutoff'	, 0		, ...
				'silent'		, false	  ...
				);
		
		rgbc	= reshape(rgb,[],3);
		n		= size(rgbc,1);
		
		%set black to black
			hsl		= rgb2hsl(rgbc);
			bMin	= hsl(:,3)<=prctile(hsl(:,3),100*opt.black_cutoff);
			rgbMin	= mean(rgbc(bMin,:));
			
			rgbc	= rgbc - repmat(rgbMin,[n 1]);
		%set white to white
			bMax	= hsl(:,3)>=prctile(hsl(:,3),100*(1-opt.white_cutoff));
			rgbMax	= mean(rgbc(bMax,:));
			
			rgbc	= rgbc./repmat(rgbMax,[n 1]);
		
		rgbc	= max(0,min(1,rgbc));
		rgbc	= reshape(rgbc,size(rgb));
		
		%compare the results
			if opt.compare
				imshow([rgb; rgbc]);
			end
end
