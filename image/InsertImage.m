function imTo = InsertImage(imTo,imFrom,varargin)
% InsertImage
% 
% Description:	insert one image into another
% 
% Syntax:	im = InsertImage(imTo,imFrom,[pInsert]=[1 1],[pTypeTo]='tl',[pTypeFrom]=pTypeTo,<options>)
% 
% In:
% 	imTo		- the image into which to insert the other
%	imFrom		- the image to insert
%	[pInsert]	- the point at which to insert the image
%	[pTypeTo]	- 'tl' if pInsert is in top-left format, 'center' if it is
%				  relative to the center of the image
%	[pTypeFrom]	- 'tl' if pInsert refers to the top-left of the insertion image
%				  'center' if it refers to the center
%	<options>:
%		alpha:	(1) specify either an alpha value to apply to the inserted image
%				or a 2D array of alpha values
% 
% Out:
% 	im	- imTo with imFrom inserted at the specified location
% 
% Note: NaNs aren't inserted
%
% Updated:	2010-04-30
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[pInsert,pTypeTo,pTypeFrom,opt]	= ParseArgsOpt(varargin,[1 1],'tl',[],...
									'alpha'	, 1	  ...
									);

if isempty(pTypeFrom)
	pTypeFrom	= pTypeTo;
end

[imFrom,opt.alpha]	= FillSingletonArrays(imFrom,opt.alpha);
if ndims2(imFrom)==3 & ndims2(opt.alpha)==2
	opt.alpha	= repmat(opt.alpha,[1 1 3]);
end
opt.alpha(isnan(opt.alpha))	= 0;

%get the position of the to image
	switch lower(pTypeTo)
		case 'tl'
			pTo		= [1 1];
		case 'center'
			pTo	= [0 0];
		otherwise
			error(['"' pTypeTo '" is not a valid position type.']);
	end

sTo		= size(imTo);
sFrom	= size(imFrom);

%get the intersection points
	[kYTo,kXTo,kYFrom,kXFrom]	= GetImageIntersection(sTo,pTo,sFrom,pInsert,pTypeTo,pTypeFrom);
%get the intersecting portion of the insertion image
	imFrom			= im2double(imFrom(kYFrom,kXFrom,:));
	imToIntersect	= im2double(imTo(kYTo,kXTo,:));
	opt.alpha		= im2double(opt.alpha(kYFrom,kXFrom,:));
%fill in NaNs if necessary
	bNaN			= isnan(imFrom);
	imFrom(bNaN)	= imToIntersect(bNaN);
	
	bNaN				= isnan(imToIntersect);
	imToIntersect(bNaN)	= imFrom(bNaN);
%insert the image
	imInsert	= opt.alpha.*imFrom+(1-opt.alpha).*imToIntersect;
	switch class(imTo)
		case 'uint8'
			imInsert	= im2uint8(imInsert);
	end
	
	imTo(kYTo,kXTo,:)	= imInsert;
