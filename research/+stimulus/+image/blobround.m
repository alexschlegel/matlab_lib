function varargout = blobround(varargin)
% stimulus.image.blobround
% 
% Description:	create a roundy blobbish figure
% 
% Syntax:	see stimulus.image.blob
% 
% In:
%	<options>:
%		rmin:			(0.25)
%		rmax:			(1)
%		interp:			('pchip')
%		interp_space:	('polar')
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

varargin	= optadd(varargin,...
				'rmin'			, 0.25		, ...
				'rmax'			, 1			, ...
				'interp'		, 'pchip'	, ...
				'interp_space'	, 'polar'	  ...
				);

[varargout{1:nargout}]	= stimulus.image.blob(varargin{:});
