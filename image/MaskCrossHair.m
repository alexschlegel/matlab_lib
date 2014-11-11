function b = MaskCrossHair(varargin)
% MaskCrossHair
% 
% Description:	generate a cross hair image
% 
% Syntax:	b = MaskCrossHair(<options>)
% 
% In:
%	<options>:
%		l:		(3) length of each cross line
%		t:		(1) thickness of the lines
%		space:	(2) space between the center and the cross lines
% 
% Out:
% 	b	- the crosshair mask
% 
% Updated: 2010-05-01
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'l'		, 3	, ...
		't'		, 1	, ...
		'space'	, 2	  ...
		);

%initialize the image
	s	= 2*(opt.l+opt.space)+opt.t;
	b	= nan(s);
%fill the cross hair
	b(:,[opt.l+opt.space+(1:opt.t)])	= 1;
	b([opt.l+opt.space+(1:opt.t)],:)	= 1;
%add the space
	b(:,[opt.l+(1:opt.space) end-opt.l-(1:opt.space)+1])	= NaN;
	b([opt.l+(1:opt.space) end-opt.l-(1:opt.space)+1],:)	= NaN;
