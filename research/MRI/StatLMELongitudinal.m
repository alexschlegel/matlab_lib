function [F,p,pCorrFWE,pCorrFDR,Chat] = StatLMELongitudinal(nii,t,g,varargin)
% StatLMELongitudinal
% 
% Description:	perform a longitudinal linear mixed effects analysis on MRI data
% 
% Syntax:	[F,p,pCorrFWE,pCorrFDR,Chat] = StatLMELongitudinal(nii,t,g,varargin)
% 
% In:
% 	nii	- an nSubject x nTime array of one of the following, or one of the
%		  following representing an nX x nY x nZ x (nSubject*nTime) data set 
%		  (sorted by time and then by subject within time) with all data sets
%		  in the same space:
%			paths to 3D NIfTI files
%			loaded NIfTI structs
%			numerical data sets
%	t	- an nSubject x nTime array of data acquisition times
%	g	- an nSubject x 1 logical array specifying which group each subject is
%		  in. true should be used for the experimental group.
%	<options>:
%		mask:		(<none>) a 3D mask specifying the voxels to analyze. same as
%					for nii.
%		dir_out:	(<none>) the path to a directory in which to save F and p
%					(actually 1-p) volumes
%		analysis:	('lmelongitudinal') the prefix for output file names
%		est_method:	([]) the estimation method to use. see LMELongitudinal.
%		fdr_q:		([]) the fdr correction q value. see LMELongitudinal.
%		cores:		(1) the number of processor cores to use
% 
% Out:
% 	F			- a 3D array of F-statistics from a linear contrast on the
%				  model's time x group interaction term
%	p			- a 3D array of p-values associated with the F-statistics 
%	pCorrFWE	- a 3D array of FWE corrected p-values (Bonferroni)
%	pCorrFDR	- a 3D array of FDR corrected p-values
%	Chat		- a 3D array of contrast values
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'mask'			, []				, ...
		'dir_out'		, []				, ...
		'analysis'		, 'lmelongitudinal'	, ...
		'est_method'	, []				, ...
		'fdr_q'			, []				, ...
		'cores'			, 1					  ...
		);

[nSubject,nTime]	= size(t);

%get the data to analyze as an nSubject x nTime x nVoxel array
	niiBase		= [];
	[d,sData]	= GetData(nii);
	
	clear nii;
%load the mask
	msk = GetMask(opt.mask,d);
%apply the mask
	d	= ApplyMask(d,msk);

%analyze!
	fstats	= LMELongitudinal(d,t,g,...
				'est_method'	, opt.est_method	, ...
				'fdr_q'			, opt.fdr_q			, ...
				'cores'			, opt.cores			  ...
				);
%reshape the results
	[F,p,pCorrFWE,pCorrFDR,Chat]	= deal(NaN(sData));
	
	F(msk)			= fstats.F;
	p(msk)			= fstats.p;
	pCorrFWE(msk)	= fstats.pcorrfwe;
	pCorrFDR(msk)	= fstats.pcorrfdr;
	Chat(msk)		= fstats.Chat;
%save the results
	if ~isempty(opt.dir_out)
		if ~CreateDirPath(opt.dir_out)
			error('Could not create output directory.');
		end
		
		if isempty(niiBase)
			niiBase	= NIfTI.Create(zeros(sData));
		end
		
		[niiF,niiP,niiPFWE,niiPFDR,niiChat]	= deal(niiBase);
		
		strPathF	= PathUnsplit(opt.dir_out,[opt.analysis '-F'],'nii.gz');
		strPathP	= PathUnsplit(opt.dir_out,[opt.analysis '-p'],'nii.gz');
		strPathPFWE	= PathUnsplit(opt.dir_out,[opt.analysis '-pcorrFWE'],'nii.gz');
		strPathPFDR	= PathUnsplit(opt.dir_out,[opt.analysis '-pcorrFDR'],'nii.gz');
		strPathChat	= PathUnsplit(opt.dir_out,[opt.analysis '-Chat'],'nii.gz');
		
		niiF.data		= F;
		niiP.data		= 1-p;
		niiPFWE.data	= 1-pCorrFWE;
		niiPFDR.data	= 1-pCorrFDR;
		niiChat.data	= Chat;
		
		NIfTI.Write(niiF,strPathF);
		NIfTI.Write(niiP,strPathP);
		NIfTI.Write(niiPFWE,strPathPFWE);
		NIfTI.Write(niiPFDR,strPathPFDR);
		NIfTI.Write(niiChat,strPathChat);
	end
	

%------------------------------------------------------------------------------%
function [d,sData] = GetData(d)
	%make sure we have a cell of data sets
		if isstruct(d)
		%array of structs
			d	= num2cell(d);
		else
		%just make sure we have a cell
			d	= ForceCell(d);
		end
	%load each cell member
		d	= cellfunprogress(@(x) GetDataOne(x),d,...
				'label'			, 'loading data'	, ...
				'UniformOutput'	, false				  ...
				);
	%what did we end up with?
		if isequal(size(d),[nSubject nTime])
		%nSubject x nTime array of 3D data sets
			bNaN	= cellfun(@(x) isequalwithequalnans(x,nan),d);
			%get the data size
				sData	= size(d{find(~bNaN,1)});
			%fill the NaN data sets
				d(bNaN)	= {nan(sData)};
			
			d		= cell2mat(cellfun(@(x) reshape(x,1,1,[]),d,'UniformOutput',false));
		elseif numel(d)==1 && ndims(d{1})==4 && size(d{1},4)==nSubject*nTime
		%nX x nY x nZ x (nSubject*nTime) data set
			sData	= size(d{1});
			sData	= sData(1:3);
			
			d	= reshape(permute(d{1},[4 1 2 3]),[nSubject nTime prod(sData)]);
		else
		%wtf?
			error('malformed input data.');
		end
end
%------------------------------------------------------------------------------%
function msk = GetMask(msk,d)
	if ~isempty(msk)
		msk	= logical(reshape(GetDataOne(msk),[],1));
	else
		msk	= true(size(d,3),1);
	end
end
%------------------------------------------------------------------------------%
function d = ApplyMask(d,msk)
	d	= d(:,:,msk);
end
%------------------------------------------------------------------------------%
function d = GetDataOne(nii)
	switch class(nii)
		case 'char'
		%file path
			nii	= NIfTI.Read(nii);
			
			if isempty(niiBase)
				niiBase			= nii;
				niiBase.data	= [];
			end
			
			d	= nii.data;
		case 'struct'
		%NIfTI struct
			if isempty(niiBase)
				niiBase			= nii;
				niiBase.data	= [];
			end
			
			d	= nii.data;
		otherwise
		%assume we have what we want
			d	= nii;
	end
	
	d	= double(d);
end
%------------------------------------------------------------------------------%

end
