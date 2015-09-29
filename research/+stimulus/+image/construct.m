function [im,b,ifo] = construct(varargin)
% stimulus.image.construct
% 
% Description:	create a construct figure
% 
% Syntax:	[im,b,ifo] = stimulus.image.construct(<options>)
% 
% In:
%	<options>:
%		d:		(0.05) the difficulty level (0->1)
%		parts:	([]) a 4-element array of part indices, or a single index to
%				return just that part's image. overrides <d>.
%		style:	('figure') the style of image to construct:
%					'figure':	assemble into a figure
%					'part':		a row of parts
%		pad:	(0.25) the padding between parts for part figures, as a fraction
%				of the part size
% 
% Out:
%	im	- the stimulus image
% 	b	- a binary mask of the stimulus image
%	ifo	- a struct of info about the stimulus
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%load the parts
	persistent imPart;
	
	nPart	= 100;
	
	if isempty(imPart)
		[strDirMe,strFileMe,strExtMe]	= PathSplit(mfilename('fullpath'));
		
		strDirImage	= DirAppend(strDirMe,strFileMe);
		
		cPathPart	= arrayfun(@(k) PathUnsplit(strDirImage,sprintf('%03d',k),'bmp'),(1:nPart)','uni',false);
		imPart		= cellfun(@imread,cPathPart,'uni',false);
		imPart		= cat(3,imPart{:});
	end

%default option values
	persistent cDefault;
	
	if isempty(cDefault)
		cDefault	=	{
							'd'		, 0.05		, ...
							'parts'	, []		, ...
							'style'	, 'figure'	, ...
							'pad'	, 0.25		  ...
							};
	end

%generate the stimulus
	[im,b,ifo]	= stimulus.image.common_pipeline(...
					'vargin'		, varargin				, ...
					'defaults'		, cDefault				, ...
					'f_validate'	, @Construct_Validate	, ...
					'f_mask'		, @Construct_Mask		  ...
					);

%------------------------------------------------------------------------------%
function [opt,ifo] = Construct_Validate(opt,ifo)
	opt.style	= CheckInput(opt.style,'style',{'figure','parts'});
end
%------------------------------------------------------------------------------%
function [b,ifo] = Construct_Mask(opt,ifo)
	%pick the parts
		if ~isempty(opt.parts)
			kPart	= opt.parts;
		else
			kPart	= C_PickParts(4,opt);
		end
		
		ifo.part	= kPart;
	
	%construct the image
		szPart	= opt.size/2;
		
		cB	= arrayfun(@(k) imresize(imPart(:,:,k),[szPart szPart],'nearest'),kPart,'uni',false);
		
		if numel(kPart)==1 %part image
			b	= cB{1};
		else
			switch opt.style
				case 'figure'	%figure image
					b	= [cB{4} imrotate(cB{1},-90); imrotate(cB{3},-270) imrotate(cB{2},-180)];
				case 'parts'	%parts image
					pxPad	= round(szPart*opt.pad);
					imPad	= false(size(cB{1},1),pxPad);
					
					b	= [imrotate(cB{1},-90) imPad imrotate(cB{2},-180) imPad imrotate(cB{3},-270) imPad cB{4}];
			end
		end
end
%------------------------------------------------------------------------------%
function kPart = C_PickParts(nPick,opt)
	%possible parts to choose from
		rngMax = min(nPart, 2 + floor(opt.d*(nPart-1)));
		rngMin = max(1, rngMax - 25);
		rngMean = (rngMin + rngMax)/2;
	
	%choose parts that have a mean d close the midpoint of our part range
		sumPart	= 0;
		kPart	= NaN(nPick,1);
		
		for kP=1:nPick
			if kP==nPick
			%get close to the midpoint
				pMid = rngMean*nPick - sumPart;
				pMin = max(rngMin,floor(pMid-0.5));
				pMax = min(rngMax,ceil(pMid+0.5));
				
				kPart(end)	= randi([pMin pMax]);
			else
			%choose a part that allows us to reach the midpoint by the end
				nLeft	= nPick - kP;
				partMin	= max(rngMin,ceil(nPick*rngMean - sumPart - rngMax*nLeft));
				partMax	= min(rngMax,floor(nPick*rngMean - sumPart - rngMin*nLeft));
				
				endMin	= (sumPart + partMin + rngMin*nLeft)/nPick;
				endMax	= (sumPart + partMax + rngMax*nLeft)/nPick;
				
				kPart(kP)	= randi([partMin partMax]);
				sumPart		= sumPart + kPart(kP);
			end
		end
	
	%randomize the order
		kPart = randomize(kPart,'seed',false);
end
%------------------------------------------------------------------------------%

end
