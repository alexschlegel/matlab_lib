function varargout = blobspike(varargin)
% stimulus.image.blobspike
% 
% Description:	create a spiky blobbish figure
% 
% Syntax:	see stimulus.image.blob
% 
% In:
%	<options>:
%		rmin:			(0)
%		rmax:			(1)
%		interp:			('linear')
%		interp_space:	('cartesian')
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

varargin	= optadd(varargin,...
				'rmin'			, 0				, ...
				'rmax'			, 1				, ...
				'interp'		, 'linear'		, ...
				'interp_space'	, 'cartesian'	  ...
				);

[varargout{1:nargout}]	= stimulus.image.blob(varargin{:});
