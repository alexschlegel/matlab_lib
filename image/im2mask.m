function msk = im2mask(im,varargin)
% im2mask
% 
% Description:	create a binary mask from an image
% 
% Syntax:	msk = im2mask(im,<options>)
% 
% In:
% 	im	- the image
%	<options>:
%		background:	(<auto>) the background color of the image
%		tolerance:	(0.1) 0->1 the tolerance between choosing a pixel as
%					background or foreground
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'background'	, []	, ...
		'tolerance'		, 0.1	  ...
		);

if isempty(opt.background)
	opt.background	= GetBackgroundColor(im);
end

[h,w,p]	= size(im);

im				= im2double(im);
opt.background	= im2double(opt.background);

%figure out which pixels are background/foreground
	bgDiff		= sqrt(sum((im - repmat(reshape(opt.background,1,1,[]),[h w 1])).^2,3));
	bBackCol	= bgDiff <= opt.tolerance;

%fill in from the background border pixels
	bBorder	= bBackCol & imborder([h,w],'c',true,'b',false);
	bBack	= imfill(~bBackCol,find(bBorder)) & bBackCol;

msk	= ~bBack;
