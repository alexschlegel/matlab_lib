function [bSuccess,strPathOut] = MRIMaskGrow(strPathMask,nGrow,varargin)
% MRIMaskGrow
% 
% Description:	dilate or erode a NIfTI mask
% 
% Syntax:	[bSuccess,strPathOut] = MRIMaskGrow(strPathMask,nGrow,<options>)
% 
% In:
% 	strPathMask	- the path to a binary NIfTI mask
%	nGrow		- if a positive number, dilate nGrow times.  if negative, erode
%				  nGrow times.
%	<options>:
%		output:	(<auto>) output file path
%		force:	(true) true to force processing even if the output file already
%				exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the mask was successfully grown
%	strPathOut	- the output mask path
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess	= false;

opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

strPathOut	= unless(opt.output,PathAddSuffix(strPathMask,['_g(' num2str(nGrow) ')'],'favor','nii.gz'));

if opt.force || ~FileExists(strPathOut)
	try
		%load the mask
			nii	= NIfTI.Read(strPathMask);
		%dilate/erode
			if nGrow>0
			%dilate
				for kG=1:nGrow
					nii.data	= imdilate(nii.data,ones(3,3,3));
				end
			else
			%erode
				for kG=1:-nGrow
					nii.data	= imerode(nii.data,ones(3,3,3));
				end
			end
		%save the mask
			NIfTI.Write(nii,strPathOut);
	catch me
		status('Error while growing the mask.','warning',true,'silent',opt.silent);
		return;
	end
end

%success!
	bSuccess	= true;
