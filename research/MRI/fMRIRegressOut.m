function nii = fMRIRegressOut(nii,R,varargin)
% fMRIRegressOut
% 
% Description:	regress a set of timecourses out of a 4D data set
% 
% Syntax:	nii = fMRIRegressOut(nii,R,<options>)
% 
% In:
% 	nii	- the path to a functional NIfTI file, a functional NIfTI struct
%		  loaded with NIfTI.Read, or a 4d array
%	R	- an nT-length timecourse to regress out; or one of the following
%		  representations of a mask in the same space as nii from which to
%		  extract a timecourse to regress out: the path to a NIfTI mask file, a
%		  NIfTI mask struct loaded with NIfTI.Read, or a 3d logical array
%		  representing a mask; or a cell of the above to regress out multiple
%		  timecourses
%	<options>:
%		demean:		(true) true to demean everything
%		output:		(<none>) a file path to which to save the regressed data.
%					only applicable if nii is a NIfTI file path or NIfTI struct.
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force processing if the output already exists
% 
% Out:
% 	nii	- if the 'output' was not specified, nii with the specified timecourses
%		  regressed out.  otherwise, the path to the output file.
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'demean'	, true	, ...
		'output'	, []	, ...
		'cores'		, 1		, ...
		'force'		, true	  ...
		);

if ~ismember(class(nii),{'char','struct'})
	opt.output	= [];
end

if ~isempty(opt.output) && ~opt.force && FileExists(opt.output)
	return;
end

%get the data
	bCollapseStruct	= false;
	switch class(nii)
		case 'char'
		%NIfTI file
			nii	= NIfTI.Read(nii);
		case 'struct'
		%NIfTI struct already
		otherwise
			bCollapseStruct	= true;
			nii				= struct('data',nii);
	end
	
	nii.data	= double(nii.data);
	
	if opt.demean
		s			= size(nii.data);
		nii.data	= nii.data - repmat(mean(nii.data,4),[1 1 1 s(4)]);
	end
%get the timecourses to regress out
	R	= cellfun(@GetTimecourse,ForceCell(R),'UniformOutput',false);
	R	= cat(2,R{:});
	
	if opt.demean
		R	= R - repmat(mean(R,1),[size(R,1) 1]);
	end
%regress
	nii.data	= DoRegress(nii.data,R);
	
	if bCollapseStruct
		nii	= nii.data;
	end
%save?
	if ~isempty(opt.output)
		NIfTI.Write(nii,opt.output);
		
		nii	= opt.output;
	end

%------------------------------------------------------------------------------%
function t = GetTimecourse(R)
	switch class(R)
		case {'char','struct'}
		%NIfTI mask file or mask struct
			t	= NIfTI.MaskMean(nii,R);
		otherwise
			s	= size(R);
			nd	= numel(s);
			
			switch nd
				case 2
					if any(s==1)
					%timecourse
						t	= reshape(R,[],1);
					else
					%WTF?
						error('Invalid mask specified.');
					end
				case 3
				%mask
					t	= NIfTI.MaskMean(nii,R);
				otherwise
				%WTF?
					error('Invalid mask specified.');
			end
	end
end
%------------------------------------------------------------------------------%
function d = DoRegress(d,R)
	[b,bint,d]	= regressMulti(d,R,'cores',opt.cores);
end
%------------------------------------------------------------------------------%

end
