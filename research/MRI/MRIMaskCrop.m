function b = MRIMaskCrop(x,f,varargin)
% MRIMaskCrop
% 
% Description:	crop a binary NIfTI mask
% 
% Syntax:	bSuccess = MRIMaskCrop(strPathMask,f,<options>)
%			b = MRIMaskCrop(b,f,<options>)
% 
% In:
% 	strPathMask		- the path to a binary NIfTI mask
%	b				- a binary mask array
%	f				- a 2x3 array specifying the fractional (x,y,z) coordinates
%					  of the bounding box to crop.  e.g. if
%					  <f>==[0 0.5 0; 0.5 1 1], then half of the mask will be
%					  kept in the x direction (from the lowest to the halfway
%					  point), half in the y direction (from the halfway point to
%					  the highest), and all in the z direction.
%	<options>:
%		output:	(<auto>) the output file name (only applies if strPathMask was
%				passed)
%		force:	(true) true to force processing even if the output file already
%				exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the mask was successfully created
%	b			- the cropped mask array
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

switch class(x)
	case 'char'
		strPathIn	= x;
		bSuccess	= false;
		
		opt	= ParseArgs(varargin,...
				'output'	, []	, ...
				'force'		, true	, ...
				'silent'	, false	  ...
				);
		
		if isempty(opt.output)
			cF			= num2cell(roundn(f,-2));
			strF		= ['(' join(cF(1,:),',') ';' join(cF(2,:),',') ')'];
			strPathOut	= PathAddSuffix(strPathIn,['-' strF]);
		else
			strPathOut	= opt.output;
		end
		
		if opt.force || ~FileExists(strPathOut)
			try
				%load the mask
					nii	= NIfTI.Read(strPathIn);
				%crop it
					nii.data	= DoCrop(nii.data);
				%save the inverse
					NIfTI.Write(nii,strPathOut);
			catch me
				status(['Could not crop the mask "' strPathOut '".'],'warning',true,'silent',opt.silent);
				return;
			end
		end
		
		%success!
			bSuccess	= true;
	otherwise
		b	= DoCrop(x);
end

%------------------------------------------------------------------------------%
function d = DoCrop(d)
	if ~isempty(f)
		k		= find(d);
		n		= numel(k);
		[x,y,z]	= ind2sub(size(d),k);
		
		mn	= cellfun(@(w) min(w(:)),{x y z});
		rng	= cellfun(@(w) range(w(:)),{x y z});
		
		vCropMin	= repmat(mn + f(1,:).*rng,[n 1]);
		vCropMax	= repmat(mn + f(2,:).*rng,[n 1]);
		
		bCrop	= all([x y z] >= vCropMin & [x y z] <= vCropMax,2);
		
		d(k(~bCrop))	= 0;
	end
end
%------------------------------------------------------------------------------%

end
