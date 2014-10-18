function p = rgbWrite(rgb,strPath,varargin)
% rgbWrite
% 
% Description:	write an image as an RGB file
% 
% Syntax:	rgbWrite(im,strPath,<imwrite options...>)
%
% In:
%	im		- the image to write
%	strPath	- the output file path
%		
% Out:
%	p	- a struct of parameters passed to imwrite
% 
% Side-effects:	saves im to strPath
%  
% Updated: 2010-12-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%convert to uin8 to save space
	rgb	= im2uint8(rgb);
%make sure rgb is RGB
	if ndims(rgb)<3
		rgb	= repmat(rgb,[1 1 3]);
	end
%get the file format parameters
	p	= GetParameters(PathGetExt(strPath),varargin{:});
	cP	= opt2cell(p);
%write the file
	imwrite(rgb,strPath,cP{:});

%------------------------------------------------------------------------------%
function p = GetParameters(strExt,varargin)
	switch lower(strExt)
		case 'jpg'
			cDefault	=	{
								'quality'	; 90
							};
		otherwise
			cDefault	= {};
	end
	
	cParameter	= [cDefault; reshape(varargin,[],1)];
	
	cKey	= cParameter(1:2:end);
	cValue	= cParameter(2:2:end);
	
	[cKey,kKey]	= unique(cKey);
	cValue		= cValue(kKey);
	
	p	= cell2struct(cValue,cKey,1);
%------------------------------------------------------------------------------%
