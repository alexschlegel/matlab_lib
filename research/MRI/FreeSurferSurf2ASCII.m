function strPathASCII = FreeSurferSurf2ASCII(strPathSurf,varargin)
% FreeSurferSurf2ASCII
% 
% Description:	convert a FreeSurfer surface to ASCII format (for use in
%				probtracx)
% 
% Syntax:	strPathASCII = FreeSurferSurf2ASCII(strPathSurf,<options>)
% 
% In:
% 	strPathSurf	- the path to the surface mesh
%	<options>:
%		force:	(true) true to force conversion even if the output already
%				exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	strPathASCII	- the path to the ASCII version of the surface mesh
% 
% Updated: 2011-02-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

strPathASCII	= [strPathSurf '.asc'];
strScript		= ['mris_convert "' strPathSurf '" "' strPathASCII '"'];

if (opt.force || ~FileExists(strPathASCII)) && RunBashScript(strScript,'silent',opt.silent)
	error(['Could not convert surface mesh "' strPathSurf '" to ASCII.']);
end
