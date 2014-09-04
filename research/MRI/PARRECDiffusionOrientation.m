function m = PARRECDiffusionOrientation(hdr)
% PARRECDiffusionOrientation
% 
% Description:	determine the orientation of the diffusion directions stored in
%				a PAR header
% 
% Syntax:	m = PARRECDiffusionOrientation(hdr)
% 
% In:
% 	hdr	- the PAR header read with PARRECReadHeader
% 
% Out:
% 	m	- a 3x3 matrix specifying the directions of the (i,j,k) image grid
% 		  indices corresponding to the diffusion direction vectors in the header.
%		  The columns of the matrix correspond to standard NIfTI space
%		  (lr, pa, is).  The first row specifies the direction of the i index
%		  with a 1/-1 in the corresponding column, etc.  E.g. data oriented with
%		  (i,j,k)->(ap,is,lr) would produce the following matrix:
% 			[ 0 -1  0
% 			  0  0  1
% 			  1  0  0 ] 
% 
% Updated: 2011-11-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the (i,j,k) directions
	re		= '\((?<i>\w\w),[ ]*(?<j>\w\w),[ ]*(?<k>\w\w)\)';
	sIJK	= regexp(GetFieldPath(hdr,'description','diffusion'),re,'names');
	
	if isempty(sIJK)
		error('Unsupported PAR/REC format.');
	end
	
	m	= cell2mat(cellfun(@GetRow,{sIJK.i; sIJK.j; sIJK.k},'UniformOutput',false));
	
	
%------------------------------------------------------------------------------%
function r = GetRow(str) 
	[strSort,kS]	= sort(str);
	
	switch lower(strSort)
		case 'lr'
			r	= [1 0 0];
		case 'ap'
			r	= [0 -1 0];
		case 'fh'
			r	= [0 0 1];
		otherwise
			error(['Unsupported direction found: "' str '".']);
	end
	
	if all(kS==[2 1])
		r	= -r;
	end
%------------------------------------------------------------------------------%
