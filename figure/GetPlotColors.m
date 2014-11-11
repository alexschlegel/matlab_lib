function col = GetPlotColors(n,varargin)
% GetPlotColors
% 
% Description:	return an array of colors to use in a plot
% 
% Syntax:	col = GetPlotColors(n,<options>)
% 
% In:
% 	n	- the number of colors to return
%	<options>:
%		color:	('color') one of the following:
%					'color':	some highly-contrasting semi-colorblind-safe
%								colors
%					'bw':		some grayscale colors
%					col:		an Nx3 array of colors to choose from.
%				if n > the number of colors in the array then any additional
%				colors are filled according to the 'fill' property
%		fill:	('random') one of the following to specify how to fill
%				additional colors:
%					'last':		use the last color
%					'random':	use random values
%					x:			an input to str2rgb
% 
% Out:
% 	col	- an N x 3 array of RGB colors
% 
% Updated: 2014-02-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'color'	, 'color'	, ...
		'fill'	, 'random'	  ...
		);

bColor	= true;

%get the default colors
	if ischar(opt.color)
		switch opt.color
			case 'color'
				opt.color	= 'plot';
			case 'bw'
				bColor		= false;
				opt.color	= 'plotbw';
		end
	end
	
	opt.color	= im2double(str2rgb(opt.color));

%fill extra colors
	nColDefault	= size(opt.color,1);
	nFill		= n-nColDefault;
	if nFill>0
		switch class(opt.fill)
			case 'char'
				switch lower(opt.fill)
					case 'last'
						colFill	= repmat(opt.color(end,:),[nFill 1]);
					otherwise
						colFill	= str2rgb(repmat({opt.fill},[nFill 1]));
				end
			otherwise
				colFill	= repto(str2rgb(opt.fill),[nFill 3]);
		end
		
		if ~bColor
			colFill	= repmat(mean(colFill,2),[1 3]);
		end
		
		opt.color(nColDefault+1:n,:)	= colFill;
	end

%return the specified colors
	col	= opt.color(1:n,:);
