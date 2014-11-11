function [bSuccess,strPathMaskInv] = MRIMaskInvert(strPathMask,varargin)
% MRIMaskInvert
% 
% Description:	invert a binary NIfTI mask
% 
% Syntax:	[bSuccess,strPathMaskInv] = MRIMaskInvert(strPathMask,<options>)
% 
% In:
% 	strPathMask		- the path to a binary NIfTI mask
%	<options>:
%		output:	(<auto>) the output file name
%		force:	(true) true to force processing even if the output file already
%				exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess		- true if the inverted mask was successfully created
%	strPathMaskInv	- the path to the inverted mask
% 
% Updated: 2011-03-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bSuccess	= false;

opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

strPathMaskInv	= unless(opt.output,PathAddSuffix(strPathMask,'_inv','favor','nii.gz'));

if opt.force || ~FileExists(strPathMaskInv)
	try
		%load the mask
			nii	= NIfTIRead(strPathMask);
		%invert it
			nii.data	= ~logical(nii.data);
		%save the inverse
			NIfTIWrite(nii,strPathMaskInv);
	catch me
		status('Error while inverting the mask.','warning',true,'silent',opt.silent);
		return;
	end
end

%success!
	bSuccess	= true;
