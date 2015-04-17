function m = MaskMean(nii,msk)
% NIfTI.MaskMean
% 
% Description:	get the mean value of a NIfTI data set within a mask
% 
% Syntax:	m = NIfTI.MaskMean(nii,msk)
% 
% In:
% 	nii	- the path to a NIfTI file, a NIfTI struct loaded with NIfTI.Read, or
%		  a 3d or 4d array
%	msk	- the path to a NIfTI mask file, a NIfTI mask struct loaded with
%		  NIfTI.Read, or a 3d logical array
% 
% Out:
% 	m	- an Nx1 array of the mean value at each volume of nii
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the data and mask
	nii	= GetData(nii);
	msk	= logical(GetData(msk));
%get the mean
	s	= size(nii);
	
	switch numel(s)
		case 3
			m	= nanmean(nii(msk));
		case 4
			s	= size(nii);
			nT	= s(4);
			kZ	= zeros(nT,1);
			kT	= (0:nT-1)';
			
			kMask	= find(msk);
			
			k	= squeeze(krel(kMask,s,kZ,kZ,kZ,kT));
			if size(k,1)==nT && size(k,2)==1
				k	= k';
			end
			
			if isempty(k)
				m	= [];
			else
				m		= nanmean(nii(k),1)';
			end
		otherwise
			error('Unrecognized data array size.');
	end

%------------------------------------------------------------------------------%
function nii = GetData(nii)
	switch class(nii)
		case 'char'
			nii	= NIfTI.Read(nii,'return','data');
		case 'struct'
			nii	= nii.data;
		otherwise
	end
end
%------------------------------------------------------------------------------%

end
