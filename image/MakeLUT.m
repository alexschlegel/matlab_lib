function lut = MakeLUT(c,n,varargin)
% MakeLUT
% 
% Description:	construct a color look-up-table
% 
% Syntax:	lut = MakeLUT(c,n,[tC]=<uniform>,<options>) OR
%			lut = MakeLUT(c,t,[tC]=<uniform>,<options>)
% 
% In:
% 	c		- an Nx3 array of RGB color control points, or string/cell of
%			  strings of colors from str2rgb
%	n		- the number of colors in the LUT
%	t		- an array of (0->1) parametric values along the LUT
%	[tC]	- the parametric positions of the colors in c
%	<options>:
%		interp:	('linear') the interpolation method
% 
% Out:
% 	lut	- the Nx3 LUT
% 
% Example:	red->green->blue: lut = MakeLUT([255 0 0; 255 255 0; 0 255 0; 0 255 255; 0 0 255],20);
% 
% Updated:	2014-02-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[tC,opt]	= ParseArgs(varargin,[],...
				'interp'	, 'linear'	  ...
				);

if ~isnumeric(c)
	c	= GetPresetLUT(c);
end

nColor	= size(c,1);

if isempty(n)
	lut	= zeros(0,3);
	return;
end

%convert to doubles
	[c,b2int]	= im2double(c);
%positions of the control point
	kCP		= reshape(unless(tC,GetInterval(0,1,nColor)),[],1);
%position of the LUT colors
	if numel(n)>1 || (n<1 && n>0)
		kLUT	= n;
	else
		kLUT	= GetInterval(0,1,n)';
	end
%interpolate each color channel
	if numel(kCP)==1
		lut	= repmat(c,[numel(kLUT) 1]);
	else
		%x=interp1nd(kCP,c,kLUT,opt.interp);
		%k=(1:n)'; plot(k,x(:,1)-0.1,'r',k,x(:,2)+0.1,'g',k,x(:,3),'b')
		
		lut	= min(1,max(0,interp1nd(kCP,c,kLUT,opt.interp)));
	end
%convert back to uint8
	if b2int
		lut	= im2uint8(lut);
	end

%------------------------------------------------------------------------------%
function c = GetPresetLUT(str)
	persistent randSource;
	
	if isempty(randSource)
		step	= 0:0.5:1;
		[r,g,b]	= ndgrid(step,step,step);
		rgb		= [r(:) g(:) b(:)];
		hsl		= rgb2hsl(rgb);
		
		hsl(hsl(:,2)<0.5,:)	= [];
		hsl(hsl(:,3)<0.5,:)	= [];
		
		randSource	= hsl2rgb(hsl);
	end
	
	try
		if isequal(str,'random')
			error('get down there!');
		end
		
		c	= str2rgb(str);
	catch me
		switch class(str)
			case 'char'
				str	= lower(str);
				switch str
					case 'random'
						k	= randFrom(1:size(randSource,1),3);
						c	= randSource(k,:);
					otherwise
						rethrow(me);
				end
			otherwise
				rethrow(me);
		end
	end
end
%------------------------------------------------------------------------------%

end
