function rgb = str2rgb(varargin)
% str2rgb
% 
% Description:	convert a string color representation to its RGB color
% 
% Syntax:	rgb = str2rgb(str1,...strN) OR
%			sColor = str2rgb (for all colors as a struct)
% 
% In:
% 	strK	- the color name, or a cell of color names (see below)
% 
% Out:
% 	rgb	- an Nx3 array representing the colors
% 
% Updated: 2014-02-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent sColor;

if isempty(sColor)
	sColor	= struct(...
				'black'			, [0		0		0]		, ...
				'white'			, [1		1		1]		, ...
				'red'			, [1		0		0]		, ...
				'green'			, [0		1		0]		, ...
				'blue'			, [0		0		1]		, ...
				'yellow'		, [1		1		0]		, ...
				'magenta'		, [1		0		1]		, ...
				'cyan'			, [0		1		1]		, ...
				'orange'		, [1		0.5		0]		, ...
				'grape'			, [0.5		0		1]		, ...
				'deepskyblue'	, [0		0.5		1]		, ...
				'marigold'		, [1		0.75	0]		, ...
				'mint'			, [0		1		0.75]	, ...
				'fuschia'		, [1		0		0.75]	, ...
				'electric'		, [0		0.75	1]		, ...
				'purple'		, [0.75		0		1]		, ...
				'minty'			, [0		0.9		0.5]	, ...
				'cantaloupe'	, [1		0.8		0.25]	, ...
				'cerulean'		, [0.5		0.5		1]		, ...
				'brown'			, [0.375	0.1875	0]		, ...
				'gray'			, [0.5		0.5		0.5]	, ...
				'paper'			, [0.95		0.95	0.95]	  ...
				);
	cColor	= fieldnames(sColor);
	nColor	= numel(cColor);
	
	for kC=1:nColor
		col	= sColor.(cColor{kC});
		
		sColor.(['dark' cColor{kC}])	= col/2;
		sColor.(['d' cColor{kC}])		= sColor.(['dark' cColor{kC}]);
		
		sColor.(['light' cColor{kC}])	= col + (1-col)/2;
		sColor.(['l' cColor{kC}])		= sColor.(['light' cColor{kC}]);
		
		sColor.(['darkish' cColor{kC}])		= 3*col/4;
		sColor.(['lightish' cColor{kC}])	= col + (1-col)/4;
	end
	
	sLUT	= struct(...
				'default'		, 'bgr'																						, ...
				'rgb'			, {{'red','yellow','green','cyan','blue'}}													, ...
				'bgr'			, {{'blue','cyan','green','yellow','red'}}													, ...
				'rainbow'		, {{'red','yellow','green','cyan','blue','magenta','red'}}									, ...
				'statistic'		, {{'red','yellow'}}																		, ...
				'statistic2'	, {{'blue','cyan'}}																			, ...
				'plot'			, {{'red','deepskyblue','minty','cantaloupe','purple','cerulean','orange','darkishgreen'}}	, ...
				'plotbw'		, {{repmat([0;0.6;0.8;0.4],[1 3])}}															, ...
				'jellyfish'		, {{'dblue','blue','white','lorange'}}														, ...
				'grayscale'		, {{'black','white'}}																		  ...
				);
	cLUT	= fieldnames(sLUT);
	nLUT	= numel(cLUT);
	for kL=1:nLUT
		strLUT	= cLUT{kL};
		sColor.(strLUT)	= sLUT.(strLUT);
	end
end

switch nargin
	case 0
		rgb	= sColor;
		return;
	case 1
		switch class(varargin{1})
			case 'char'
				rgb	= str2rgb(GetColor(varargin{1}));
			case 'cell'
				rgb	= str2rgb(varargin{1}{:});
			otherwise
				if isnumeric(varargin{1})
					rgb	= varargin{1};
				else
					error(sprintf('%s inputs are invalid.',class(varargin{1})));
				end
		end
	otherwise
		rgb	= cellfun(@str2rgb,varargin,'uni',false);
		rgb	= cat(1,rgb{:});
end

rgb	= im2double(rgb);

%------------------------------------------------------------------------------%
function col = GetColor(str)
	str	= lower(str);
	
	if isfield(sColor,str)
		col	= sColor.(str);
	else
		switch str
			case 'random'
				col	= rand(1,3);
			otherwise
				error(sprintf('"%s" is not a valid color.',str));
		end
	end
end
%------------------------------------------------------------------------------%

end
