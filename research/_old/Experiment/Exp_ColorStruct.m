function s = Exp_ColorStruct(varargin)
% Exp_ColorStruct
% 
% Description:	return a struct of named 1x3 colors
% 
% Syntax:	s = Exp_ColorStruct(<options>)
% 
% In:
%	<options>:
%		type:	('stimulus') the type of color struct to return:
%					'stimulus':	colors to use in stimuli
%					'figure':	colors to use in figures
%		class:	('uint8') the class of colors to return.  either 'double' or
%				'uint8'.
% 
% Out:
% 	s	- a struct of 1x3 colors
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'type'	, 'stimulus'	, ...
		'class'	, 'uint8'		  ...
		);

switch opt.type
	case 'stimulus'
		s	= struct(...
				'gray'		, [	128	128	128	]	, ...
				'red'		, [	199	23	18	]	, ...
				'yellow'	, [	255	160	32	]	, ...
				'green'		, [	40	208	0	]	, ...
				'blue'		, [	64	0	255	]	  ...
				);
	case 'figure'
		s	= struct(...
				'red'		, [	255	0	0	]	, ...
				'yellow'	, [	255	192	0	]	, ...
				'green'		, [	0	208	0	]	, ...
				'blue'		, [	0	128	255	]	, ...
				'purple'	, [	192	0	192	]	, ...
				'orange'	, [	255	128	0	]	  ...
				);
	otherwise
		error(['"' tostring(opt.type) '" is not a recognized color type.']);
end

s	= structfun2(@uint8,s);

switch opt.class
	case 'uint8'
	case 'double'
		s	= structfun2(@im2double,s);
	otherwise
		error(['"' tostring(opt.class) '" is not a recognized color class.']);
end
