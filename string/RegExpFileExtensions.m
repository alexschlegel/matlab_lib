function re = RegExpFileExtensions(cExt)
% RegExpFileExtensions
% 
% Description:	construct a regular expression to match one of a set of file
%				extensions
% 
% Syntax:	re = RegExpFileExtensions(cExt)
% 
% In:
% 	cExt	- a file extension or cell of file extensions to match, or one of
%			  the following strings:
%					'image':	return image files
% 
% Out:
% 	re	- the regular expression
% 
% Example:	Find files with the .txt or .doc extensions:
%				re		= RegExpFileExtensions({'txt','doc'});
%				cPath	= FindFiles(strDir,re,'casei',true);
% 
% Updated:	2009-06-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

cExt	= reshape(ForceCell(cExt),[],1);
nExt	= numel(cExt);
cRE		= cell(nExt,1);

%expand strings
	kExt	= 1;
	while kExt<=nExt
		switch cExt{kExt}
			case 'image'
				cExtImage	= GetExtImage();
				nExtImage	= numel(cExtImage);
				cExt		= [cExt(1:kExt-1); cExtImage; cExt(kExt+1:end)];
				kExt		= kExt+nExtImage-1;
				nExt		= nExt+nExtImage-1;
		end
		
		kExt	= kExt+1;
	end

for kExt=1:nExt
	
	cRE{kExt}	= ['(\.' cExt{kExt} '$)'];
end

re	= join(cRE,'|');

%------------------------------------------------------------------------------%
function cExt = GetExtImage()
% get the extensions of image files
	sFormat	= imformats;
	cExt	= reshape([sFormat.ext],[],1);
%------------------------------------------------------------------------------%
