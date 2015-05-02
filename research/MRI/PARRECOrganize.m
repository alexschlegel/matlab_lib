function [b,cPathRawAll,cPathOutAll] = PARRECOrganize(strDirRaw,varargin)
% PARRECOrganize
% 
% Description:	organize raw PAR/REC data to structured folders of NIfTI files.
%				see PARRECParseRaw for info on overriding extracted information.
% 
% Syntax:	[b,cPathRaw,cPathOut] = PARRECOrganize(strDirRaw,<options>)
% 
% In:
% 	strDirRaw	- the path to a directory containing directories of raw PAR/REC
%				  data, with directory names formatted as ddMMMyyID
%	<options>:
%		structural:	(0) the indices of the structural scans to transfer. indices
%					that are <=0 are relative to the last structural.
%		diffusion:	(<all>) the indices of the diffusion scans to transfer.
%					indices that are <=0 are relative to the last diffusion
%					scan.
%		run:		(<all>) the runs to transfer. indices that are <=0 are
%					relative to the last functional scan.
%		run_name:	('functional') the name of the folder in which to place the
%					funtional runs, or a cell of names, one for each run.
%		paradigm:	('single') the experiment paradigm, to determine how data
%					are organized.  one of the following:
%						'single':	a single experiment.  assumes raw data are
%							in a folder structure of the form <raw>/<code>/....
%							data are organized as
%							<base>/<code>/<type>/xxx.nii.gz.
%						'multi':	a study with multiple experiments.  assumes
%							raw data are in a folder structure of the form
%							<raw>/<experiment>/<code>/....  data are
%							organized as
%							<base>/<experiment>/<code>/<type>/xxx.nii.gz.
%						'longitudinal':	a longitudinal study with multiple data
%							points.  assumes raw data are in a folder structure
%							of the form <raw>/<session>/.... the tsession option
%							must specify the start time of each session in nowms
%							format. organizes data as:
%							<base>/<type>/<init>/<session>/xxx.nii.gz.
%		b0first:	([]) the b0first option for PARREC2NIfTI
%		tsession:	([]) must be specified for longitudinal data: an array of
%					nowms times specifying the starting time for each session
%		minfile:	(1) the minimum number of files in the data set for it to
%					be considered
%		outbase:	(<auto>) the base output directory
%		cores:		(1) the number of processor cores to use
%		force:		(false) true to force construction of output files that
%					already exist
%		silent:		(false) true to suppress status messages
%
% Out:
%	b			- an Nx1 logical array indicating which conversions were
%				  successful
%	cPathRaw	- an Nx1 array of raw input data set file paths
%	cPathOut	- an Nx1 array of converted NIfTI file paths
%
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'structural'	, 0				, ...
		'diffusion'		, []			, ...
		'run'			, []			, ...
		'run_name'		, 'functional'	, ...
		'paradigm'		, 'single'		, ...
		'b0first'		, []			, ...
		'tsession'		, []			, ...
		'minfile'		, 1				, ...
		'outbase'		, []			, ...
		'cores'			, 1				, ...
		'force'			, false			, ...
		'silent'		, false			  ...
		);

opt.paradigm	= CheckInput(opt.paradigm,'paradigm',{'single','multi','longitudinal'});

if isequal(opt.paradigm,'longitudinal')
	nSession	= numel(opt.tsession);
	nStrSession	= numel(num2str(nSession));
	
	if nSession==0
		error('tsession option must be specified for longitudinal data.');
	end
end

%process the base output directories
	if isempty(opt.outbase)
		cDirRawSplit	= DirSplit(AddSlash(strDirRaw));
		
		switch opt.paradigm
			case {'single','longitudinal'}
			%outbase is one level up from raw data directory
				opt.outbase	= DirUnsplit(cDirRawSplit(1:end-1));
			case 'multi'
			%two levels up
				opt.outbase	= DirUnsplit([cDirRawSplit(1:end-2); cDirRawSplit(end)]);
		end
	end

%get the directories to process
	cDirRaw	= FindDirectories(strDirRaw,'\d\d\w\w\w\d\d\w+');
%get info about the data sets
	ifo		= PARRECParseRaw(cDirRaw);
	
	%eliminate the data to ignore
		ifo([ifo.ignore])	= [];
%assign a session to each data set
	if isequal(opt.paradigm,'longitudinal')
		for kD=1:numel(ifo)
			ifo(kD).session	= unless(find(ifo(kD).t>=opt.tsession,1,'last'),0);
		end
		
		ifo([ifo.session]==0)	= [];
	end
%eliminate data sets with too few files
	nFile					= arrayfun(@(s) numel(s.files),ifo);
	ifo(nFile<opt.minfile)	= [];
%merge multiple within-session scans
	if isequal(opt.paradigm,'longitudinal')
		ifo	= MergeWithin(ifo);
	end

nDirRaw	= numel(ifo);

%get the files to convert
	[cPathIn,cPathOut]	= deal({});
	bConvert			= false(0);
	kDir				= [];
	
	[cPathRawAll,cPathOutAll]	= deal({});
	bConvertAll					= false(0);
	
	for kD=1:nDirRaw
		switch opt.paradigm
			case 'longitudinal'
				strDirTemplate	= DirAppend(opt.outbase,'<type>','<session>',ifo(kD).id);
				strSession		= num2str(ifo(kD).session);
			otherwise
				strDirTemplate	= DirAppend(opt.outbase,'<type>',ifo(kD).code);
				strSession		= '';
		end
		
		%structural
			nStruct				= numel(ifo(kD).structural);
			kStruct				= arrayfun(@(k) conditional(k<=0,nStruct+k,k),opt.structural);
			kStruct(kStruct<1)	= 1;
			cPathStructural		= ifo(kD).structural(kStruct);
			nPathStructural		= numel(cPathStructural);
			
			strDirStructural	= strrep(strrep(strDirTemplate,'<type>','structural'),'<session>',strSession);
			if nPathStructural==1
				cPathStructuralOut	= {PathUnsplit(strDirStructural,'data','nii.gz')};
			else
				nFill				= numel(num2str(nPathStructural));
				cPathStructuralOut	= arrayfun(@(k) PathUnsplit(strDirStructural,['data_' StringFill(k,nFill)],'nii.gz'),(1:nPathStructural)','UniformOutput',false);
			end
		%diffusion
			nDiffusion		= numel(ifo(kD).diffusion);
			kDiffusion		= unless(opt.diffusion,1:nDiffusion);
			kDiffusion		= arrayfun(@(k) conditional(k<=0,nDiffusion+k,k),kDiffusion);
			cPathDiffusion	= ifo(kD).diffusion(kDiffusion);
			nPathDiffusion	= numel(cPathDiffusion);
			
			strDirDiffusion	= strrep(strrep(strDirTemplate,'<type>','diffusion'),'<session>',strSession);
			if nPathDiffusion==1
				cPathDiffusionOut	= {PathUnsplit(strDirDiffusion,'data','nii.gz')};
			else
				nFill				= numel(num2str(nPathDiffusion));
				cPathDiffusionOut	= arrayfun(@(k) PathUnsplit(strDirDiffusion,['data_' StringFill(k,nFill)],'nii.gz'),(1:nPathDiffusion)','UniformOutput',false);
			end
		%functional
			kRun			= unless(opt.run,1:numel(ifo(kD).functional));
			nRun			= numel(kRun);
			
			if iscell(opt.run_name)
				cNameFunctional	= reshape(opt.run_name(1:nRun),[],1);
			else
				cNameFunctional	= repmat({opt.run_name},[nRun 1]);
			end
			
			cPathFunctional	= ifo(kD).functional(kRun);
			nPathFunctional	= numel(cPathFunctional);
			
			cPathFunctionalOut	= cell(nPathFunctional,1);
			
			cNameU	= unique(cNameFunctional);
			nNameU	= numel(cNameU);
			for kN=1:nNameU
				kPathCur	= FindCell(cNameFunctional,cNameU{kN});
				nPathCur	= numel(kPathCur);
				
				strDirFunctional	= strrep(strrep(strDirTemplate,'<type>',cNameU{kN}),'<session>',strSession);
				if nPathCur==1
					cPathFunctionalOut{kPathCur}	= PathUnsplit(strDirFunctional,'data','nii.gz');
				else
					nFill							= numel(num2str(nPathCur));
					cPathFunctionalOut(kPathCur)	= arrayfun(@(k) PathUnsplit(strDirFunctional,['data_' StringFill(k,nFill)],'nii.gz'),(1:nPathCur)','UniformOutput',false);
				end
			end
		
		cType		= [repmat({'structural'},[nPathStructural 1]); repmat({'diffusion'},[nPathDiffusion 1]); repmat({'functional'},[nPathFunctional 1])];
		cPathRaw	= [cPathStructural; cPathDiffusion; cPathFunctional];
		cPathOut	= [cPathStructuralOut; cPathDiffusionOut; cPathFunctionalOut];
		nPath		= numel(cPathRaw);
		
		%check for output files
			if opt.force
				bConvert	= true(nPath,1);
			else
				bConvert	= ~cellfun(@(f,t) CheckPaths(f,t),cPathOut,cType);
			end
		%create the output directories
			cDir	= unique(cellfun(@PathGetDir,cPathOut,'UniformOutput',false));
			
			cellfun(@CreateDirPath,cDir);
		
		cPathRawAll	= [cPathRawAll; cPathRaw];
		cPathOutAll	= [cPathOutAll; cPathOut];
		bConvertAll	= [bConvertAll; bConvert];
	end
%convert!
	b	= PARREC2NIfTI(cPathRawAll(bConvertAll),cPathOutAll(bConvertAll),'b0first',opt.b0first,'cores',opt.cores,'silent',opt.silent);


%------------------------------------------------------------------------------%
function ifoM = MergeWithin(ifo)
	if isempty(ifo)
		ifoM	= ifo;
		return;
	end
	
	nData	= numel(ifo);
	
	%sort by date
		[d,kSort]	= sort([ifo.t]);
		ifo			= ifo(kSort);
	%merge within subjects
		cSubject	= unique(reshape({ifo.id}',[],1));
		nSubject	= numel(cSubject);
		
		ifoM	= ifo(1);
		nM		= 0;
		for kS=1:nSubject
			bSubject	= cellfun(@(id) isequal(id,cSubject{kS}),{ifo.id}');
			kSession	= unique([ifo(bSubject).session]);
			nSessionMW	= numel(kSession);
			
			for kE=1:nSessionMW
				bMerge	= bSubject & [ifo.session]'==kSession(kE);
				kMerge	= find(bMerge);
				nMerge	= numel(kMerge);
				
				nM			= nM+1;
				ifoM(nM)	= ifo(kMerge(1));
				
				for kM=2:nMerge
					ifoM(nM).files		= [ifoM(nM).files; ifo(kMerge(kM)).files];
					ifoM(nM).scantype	= [ifoM(nM).scantype; ifo(kMerge(kM)).scantype];
					ifoM(nM).runmap		= [ifoM(nM).runmap; ifo(kMerge(kM)).runmap+numel(ifoM(nM).runmap)];
					ifoM(nM).structural	= [ifoM(nM).structural; ifo(kMerge(kM)).structural];
					ifoM(nM).diffusion	= [ifoM(nM).diffusion; ifo(kMerge(kM)).diffusion];
					ifoM(nM).functional	= [ifoM(nM).functional; ifo(kMerge(kM)).functional];
				end
			end
		end
end
%------------------------------------------------------------------------------%
function b = CheckPaths(strPathNII,strType)
%check to make sure the .mat and bvecs/bvals files exist
	cPathCheck	=	{
						strPathNII
						PathAddSuffix(strPathNII,'','mat','favor','nii.gz')
					};
	if isequal(lower(strType),'diffusion')
		strDirNII	= PathGetDir(strPathNII);
		cPathCheck	=	[cPathCheck
							PathUnsplit(strDirNII,'bvecs')
							PathUnsplit(strDirNII,'bvals')
						];
	end
	
	b	= all(FileExists(cPathCheck));
end
%------------------------------------------------------------------------------%

end
