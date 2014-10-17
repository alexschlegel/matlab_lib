function strSuffix = FSLSuffixTract(varargin)
% FSLSuffixTract
% 
% Description:	get the suffix added to a tract file name
% 
% Syntax:	strSuffix = FSLSuffixTract(<options>)
% 
% In:
% 	<options>:
%		seedspace:		('diffusion') the space of the seed masks
%		lengthcorrect:	(false) true if length correction was used
% 
% Out:
% 	strSuffix	- the suffix at the end of the tract file name, i.e.
%				  fdt_path[strSuffix].nii.gz
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'seedspace'		, 'diffusion'	, ...
		'lengthcorrect'	, false			  ...
		);


strSuffix	= '';

switch lower(opt.seedspace)
	case 'diffusion'
	%nothing to do
	otherwise
		strSuffix	= [strSuffix '-' lower(opt.seedspace)];
end

if opt.lengthcorrect
	strSuffix	= [strSuffix '_lc'];
end
