function p = LoadPalette(strPathPalette)
% LoadPalette
% 
% Description:	load a palette either from an ASCII file or a one-dimensional
%				image file
% 
% Syntax:	p = LoadPalette(strPathPalette)
% 
% In:
% 	strPathPalette	- the path to the palette
% 
% Out:
% 	p	- an Nx3 array of the palette colors
% 
% Updated:	2008-05-20
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.


%is the file an image?
	imf			= imformats;
	extImage	= [imf.ext];
	
	[dummy,dummy,ext]	= strPathSplit(strPathPalette);
	switch lower(ext)
		case extImage
			bImage	= true;
		otherwise
			bImage	= false;
	end

%get the palette info
if bImage
	p	= rgbRead(strPathPalette);
	p	= reshape(p,[],3);
else
	p	= TxtRead(strPathPalette);
	
	nPal	= numel(p);
	cSpace	= num2cell(char(' '*ones(nPal,1)));
	p		= cell2mat(reshape([p' cSpace]',1,[]));
	p		= reshape(str2num(p),3,[])';
	
	if any(p(:)>1)
		p		= p / 255;
	end
end
