function [im,b,opt] = grass(varargin)
% grass
% 
% Description:	generate an image of a blade of grass
% 
% Syntax:	im = grass(<options>)
% 
% In:
%	<options>:
%		length:				(<random>) the approximate length of the blade of
%							grass, in pixels
%		width:				(<random>) the width of the base of the blade of
%							grass, in pixels
%		direction:			(<random>) the direction of bend of the blade of
%							grass (either 'l' or 'r')
%		bendiness:			(<random>) a number between 0 and 1 specifying how
%							much the blade should bend
%		lut:				(<greens>) the color lut for the grass color
%		background:			([0 0 0]) the background color
%		min_length:			(100) the minimum blade length
%		max_length:			(400) the maximum blade length
%		min_width:			(10) the minimum blade width
%		max_width:			(max([<min_width> <length>/15])) the maximum blade
%							width
%		min_bendiness:		(0.1) the minimum bendiness
%		max_bendiness:		(0.6) the maximum bendiness
% 
% Out:
% 	im	- the grass blade image
%	b	- a binary mask of the blade
%	opt	- the options used for the blade of grass
% 
% Updated: 2013-04-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
%lutD	= [0 0.1 0; 0 0.2 0; 0 0.4 0; 0 0.5 0; 0 0.9 0; 0.5 1 0.25];
lutD	= [MakeLUT([0 0.1 0; 0 0.5 0; 0 0.8 0],5); 0.5 1 0.125];

opt	= ParseArgs(varargin,...
		'length'		, []		, ...
		'width'			, []		, ...
		'direction'		, []		, ...
		'bendiness'		, []		, ...
		'lut'			, lutD		, ...
		'background'	, [0 0 0]	, ...
		'min_length'	, 100		, ...
		'max_length'	, 400		, ...
		'min_width'		, 10		, ...
		'max_width'		, []		, ...
		'min_bendiness'	, 0.1		, ...
		'max_bendiness'	, 0.6		  ...
		);

opt.length		= unless(opt.length,randBetween(opt.min_length,opt.max_length));
opt.max_width	= unless(opt.max_width,max([opt.min_width opt.length/15]));
opt.width		= unless(opt.width,randBetween(opt.min_width,opt.max_width));
opt.direction	= CheckInput(unless(opt.direction,char(randFrom({'l','r'}))),'direction',{'l','r'});
opt.bendiness	= unless(opt.bendiness,randBetween(opt.min_bendiness,opt.max_bendiness));

switch opt.direction
	case 'r'
		xOuter	= 1;
		yOuter	= 1;
		
		xPoint	= opt.length*opt.bendiness + opt.width/2;
		yPoint	= opt.length*(1 - opt.bendiness);
		
		xInner	= opt.width - 1;
		yInner	= 1;
		
		xOuterMid	= xPoint/2;
		yOuterMid	= yPoint*(0.5 + opt.bendiness/2);
		
		xInnerMid	= xOuterMid + opt.width/2;
		yInnerMid	= yPoint*(0.5 + opt.bendiness/2);
		
		xBottom	= round(xOuter:xInner);
	case 'l'
		xOuter	= opt.length*opt.bendiness + opt.width;
		yOuter	= 1;
		
		xPoint	= opt.width/2;
		yPoint	= opt.length*(1 - opt.bendiness);
		
		xInner	= xOuter - opt.width + 1;
		yInner	= 1;
		
		xOuterMid	= xOuter/2;
		yOuterMid	= yPoint*(0.5 + opt.bendiness/2);
		
		xInnerMid	= xOuterMid - opt.width/2;
		yInnerMid	= yPoint*(0.5 + opt.bendiness/2);
		
		xBottom	= round(xInner:xOuter);
end

%construct the blade mask
	pad	= 2;
	s	= ceil([max([yOuter yPoint yInner]) max([xOuter xPoint xInner])])+2*pad;
	
	%construct the contour images
		bOuter	= contour2im([yOuter yOuterMid yPoint]+pad,[xOuter xOuterMid xPoint]+pad,s);
		bInner	= contour2im([yInner yInnerMid yPoint]+pad,[xInner xInnerMid xPoint]+pad,s);
	%get a center line
		xCenter		= (xOuter+xInner)/2;
		yCenter		= (yOuter+yInner)/2;
		xCenterMid	= (xOuterMid+xInnerMid)/2;
		yCenterMid	= (yOuterMid+yInnerMid)/2;
		bCenter		= flipud(contour2im([yCenter yCenterMid yPoint],[xCenter xCenterMid xPoint],s));
	%combine the contours
		b						= bOuter | bInner;
		b(1+pad,xBottom+pad)	= true;
		b						= flipud(b);
	%get the filled image
		props	= regionprops(b,'FilledImage','BoundingBox');
		bb		= round(props.BoundingBox);
		b		= false(size(b));
		
		b(bb(2)+(0:bb(4)-1),bb(1)+(0:bb(3)-1))	= props.FilledImage;
	%unpad
		b		= b(pad+1:end-pad,pad+1:end-pad);
		bCenter	= bCenter(pad+1:end-pad,pad+1:end-pad);
%color the blade
	%get the distance between each blade point and the blade center
		d		= bwdist(bCenter);
		d(~b)	= NaN;
	%get the lookup table
		nLUT	= size(opt.lut,1);
		lut		= [opt.background; opt.lut];
	%color the image
		d			= round(MapValue(1 - normalize(d),0,1,2,nLUT+1));
		d(isnan(d))	= 1;
		
		im	= ind2rgb(d,lut);
