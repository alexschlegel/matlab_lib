function [mask,ifo] = generate_mask(obj,ifo)
% stimulus.image.construct.generate_mask
% 
% Description:	generate the construct mask
% 
% Syntax: [mask,ifo] = obj.generate_mask(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	mask	- the binary construct image
%	ifo		- the updated info struct
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%load the parts
	persistent imPart;
	
	if isempty(imPart)
		strDirMe	= PathGetDir(mfilename('fullpath'));
		
		strDirImage	= DirAppend(strDirMe,'image');
		
		cPathPart	= arrayfun(@(k) PathUnsplit(strDirImage,sprintf('%03d',k),'bmp'),(1:obj.N_PART)','uni',false);
		imPart		= cellfun(@imread,cPathPart,'uni',false);
		imPart		= cat(3,imPart{:});
	end

%construct the image
	szPart		= repto(ceil(ifo.param.size/2),[1 2]);
	
	cMask	= arrayfun(@(k) imresize(imPart(:,:,k),szPart,'nearest'),ifo.param.part,'uni',false);
	
	if numel(ifo.param.part)==1 %part image
		mask	= cMask{1};
	else
		cMask(1:3)	= cellfun(@imrotate,cMask(1:3),{-90; -180; -270},'uni',false);
		
		switch ifo.param.style
			case 'figure'	%figure image
				mask	= [cMask{4} cMask{1}; cMask{3} cMask{2}];
			case 'parts'	%parts image
				pxPad	= round(szPart*ifo.param.pad);
				imPad	= false(size(cMask{1},1),pxPad);
				
				mask	= [cMask{1} imPad cMask{2} imPad cMask{3} imPad cMask{4}];
		end
	end
