function [im,b] = ApplyMask(im,b,varargin)
% ApplyMask
% 
% Description:	apply a binary mask to an image
% 
% Syntax:	[im,b] = ApplyMask(im,b) (b same size as im) OR
%			[im,b] = ApplyMask(im,b,[bCrop]=true,[pMask]=[1 1],[pTypeIm]='tl',[pTypeMask]=pTypeIm) OR
% 
% In:
% 	im			- an image (or an HxWx... matrix)
%	b			- a binary 2D mask, or a mask the same size as im with NaNs
%				  already set
%	[bCrop]		- true to crop the input image to the size of the mask.  if
%				  false, the output image is the same size as the input
%	[pMask]		- the position in the input image at which to apply the mask
%	[pTypeIm]	- 'tl' if pMask is in top-left format, 'center' if it is
%				  relative to the center point
%	[pTypeMask]	- 'tl' if pMask refers to the top-left of the mask, 'center' if
%				  if refers to the center
% 
% Out:
% 	im	- the image with the mask applied.  points corresponding to 0-values in
%		  the mask are set to NaN
%	b	- the mask resized for direct multiplication (for future calls to
%		  ApplyMask)
% 
% Updated:	2009-03-21
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isequal(size(im),size(b)) && nargin==2
	im	= im.*b;
else
	[bCrop,pMask,pTypeIm,pTypeMask]	= ParseArgs(varargin,true,[1 1],'tl',[]);
	if isempty(pTypeMask)
		pTypeMask	= pTypeIm;
	end
	
	%get the position of the image
		switch lower(pTypeIm)
			case 'tl'
				pIm		= [1 1];
			case 'center'
				pIm	= [0 0];
			otherwise
				error(['"' pTypeIm '" is not a valid position type.']);
		end
	
	%get the matrix dimensions
		s		= size(im);
		h		= s(1);
		w		= s(2);
		dRest	= prod(s(3:end));
	
		[hM,wM]		= size(b);
	
	%get the mask/image intersection points
		[kYMask,kXMask,kYIm,kXIm]	= GetImageIntersection([hM wM],pMask,[h w],pIm,pTypeMask,pTypeIm);
		nYIm						= numel(kYIm);
		nXIm						= numel(kXIm);
	%get the portion of the mask within the image bounds
		b	= b(kYMask,kXMask);
	%substitute NaNs for 0s
		b		= double(b);
		b(b==0)	= NaN;
	%get the masked image
		b	= repmat(b,[1 1 s(3:end)]);
		b	= b(:,:,:);
		
		if bCrop && (nYIm~=h || nXIm~=w)
			imMasked		= zeros([nYIm nXIm s(3:end)],class(im));
			imMasked(:,:,:)	= im(kYIm,kXIm,:);
			clear im;
			
			imMasked	= imMasked .* b;
			im			= imMasked;
		else
			im(kYIm,kXIm,:)	= im(kYIm,kXIm,:) .* b;
		end
end
	