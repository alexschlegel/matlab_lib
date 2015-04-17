function b = CheckSize(cPathNII,s)
% NIfTI.CheckSize
% 
% Description:	check the data dimensions of a set of NIfTI files against the
%				expected size. requires FSL.
% 
% Syntax:	b = NIfTI.CheckSize(cPathNII,s)
% 
% In:
% 	cPathNII	- the path to a NIfTI file or a cell of paths
%	s			- a 1 x N array specifying the expected data dimensions, or a
%				  cell of 1xN arrays if multiple dimensions are ok. set values
%				  to NaN to skip checking those dimensions.
% 
% Out:
% 	b	- a logical array specifying which NIfTI files have the expected
%		  dimensions
%
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%cellify
	cPathNII	= ForceCell(cPathNII);
	sNII		= size(cPathNII);
	nNII		= numel(cPathNII);
	
	cPathNII	= reshape(cPathNII,[],1);
	
	s	= ForceCell(s);
	nS	= numel(s);
%get the files to check
	b		= false(nNII,1);
	bCheck	= FileExists(cPathNII);
	nCheck	= sum(bCheck);
%get the actual dimensions
	sActual	= cellfunprogress(@NIfTI.GetSize,cPathNII(bCheck),'UniformOutput',false,'label','Reading Dimensions');
	ndMax	= max(max(cellfun(@numel,sActual)),max(cellfun(@numel,s)));
	sActual	= cellfun(@(x) [x ones(1,ndMax-numel(x))],sActual,'UniformOutput',false);
	s		= cellfun(@(x) [x ones(1,ndMax-numel(x))],s,'UniformOutput',false);
	sActual	= cell2mat(sActual);
%compare
	if ~isempty(sActual)
		for kS=1:nS
			sCur		= repmat(s{kS},[nCheck 1]);
			b(bCheck)	= b(bCheck) | all(sCur==sActual | isnan(sCur),2);
		end
	end
%reshape
	b	= reshape(b,sNII);
