function rgbWriteGIF(rgb,strFile,varargin)
% RGBWRITEGIF
%
% Description:	write an rgb image to a gif file
%
% Syntax:	rgbWriteGIF(rgb,strFile,[colT]=none,[colF]=none)
%
% In:
%	rgb		- an rgb image
%	strFile	- the output file path
%	[colT]	- optional, a 3-element array specifying the transparent color
%	[colF]	- optional, an Nx3 element array specifying colors to force into the
%			  map
%
% Side-effects:	saves rgb as a gif file after constructing a color map for it
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[colT,colF]	= ParseArgs(varargin,[],[]);

[x,map]	= rgb2ind(uint8(255*rgb),256);

if ~isempty(colF)
	if any(colF(:)>1)
		colF	= double(colF)./255;
	end
	
	for k=1:size(colF,1)
		[c,kc]		= rgbFindCloseColors(map,colF(k,:));
		map(kc,:)	= colF(k,:);
	end
end

if ~isempty(colT)
	[c,k]	= rgbFindCloseColors(map,colT);
	imwrite(x,map,strFile,'TransparentColor',k-1);
else
	imwrite(x,map,strFile);
end
