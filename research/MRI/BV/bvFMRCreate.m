function cPathFMR = bvFMRCreate(strDirRoot,strSession,varargin)
% bvFMRCreate
% 
% Description:	create a set of FMR files for the given session (Windows only).
%				optionally also preprocesses the FMR files
% 
% Syntax:	cPathFMR = bvFMRCreate(strDirRoot,strSession,<options>)
% 
% In:
%	strDirRoot		- root experimental directory
%	strSession		- the session code
%	<options>:
%		'path_amr':		(<none>) the path to either an AMR file to associate
%						with the FMR files
%		'path_prt':		
%		'path_vmr':		(<find>) path to a VMR file.  specify this if no VMR
%						exists within the given root directory
%		'runs':			(<all>) an array of run numbers for which to create VTCs
%		'suffixfmr':	(<determine>) suffix of FMR files
%		'suffixvtc':	('') suffix to add to the end of the created VTC file
%						names
%		'path_ia':		(<find>) path to the initial adjustment TRF file
%		'path_fa':		(<find>) path to the fine adjustment TRF file
%		'path_acpc':	(<none>) path to the ACPC TRF file
%		'path_tal':		(<none>) path to the TAL file
%		'bounds':		('normal') a 2x3 array specifying the x, y, and z lower
%						and upper bounds of the VTC files in BV system space, or
%						one of the following strings to specify a standard set
%						of bounds:
%							'normal':		[ 30  30  1
%											 225 255 200]
%							'retinotopy':	[ 30 150  1]
%											 225 255 200]
%		'resolution':	(3) either 1, 2, or 3 to specify the resolution, in mm,
%						of the output VTC files
%		'showbv'		(false) true to show the BVQX window
% 
% Out:
% 	cPathVTC	- a cell of paths to the created VTC files
% 
% Note:	requires BVQX's COM object
% 
% Updated:	2009-07-13
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'path_vmr'		, []		, ...
		'runs'			, []		, ...
		'suffixfmr'		, []		, ...
		'suffixvtc'		, ''		, ...
		'path_ia'		, []		, ...
		'path_fa'		, []		, ...
		'path_acpc'		, []		, ...
		'path_tal'		, []		, ...
		'bounds'		, 'normal'	, ...
		'resolution'	, 3			, ...
		'showbv'		, false		  ...
		);

n	= status(['Creating VTCs for session ' strSession]);

%get some info
	%get some paths
		if isempty(opt.path_vmr)
			opt.path_vmr	= FindPathVMR(strDirRoot,strSession);
			if isempty(opt.path_vmr)
				error('No VMR file found.  Please specify explicitly.');
			end
		end
		strDirSession		= GetDirSession(strDirRoot,strSession);
		strDirFunctional	= GetDirFunctional(strDirRoot,strSession);
	%get the runs to process
		[cDirRun,opt.runs]	= GetRunsToProcess(strDirRoot,strSession,opt.runs);
	%get the FMR suffix
		opt.suffixfmr	= GetSuffixFMR(cDirRun,opt.suffixfmr);
	%get the path to the IA transformation file
		opt.path_ia	= GetPathTRF(cDirRun,strDirSession,'_IA',opt.path_ia);
	%get the path to the FA transformation file
		opt.path_fa	= GetPathTRF(cDirRun,strDirSession,'_FA',opt.path_fa);
	%ACPC/TAL transform?
		bDoACPC	= ~isempty(opt.path_acpc);
		if bDoACPC
			bDoTAL	= ~isempty(opt.path_tal);
		else
			bDoTAL	= false;
		end
		
		if bDoTAL
			strSpace		= 'Talairach';
			strSuffixVTC	= '_TAL';
			cArgTRF			= {opt.path_ia,opt.path_fa,opt.path_acpc,opt.path_tal};
		elseif bDoACPC
			strSpace		= 'ACPC';
			strSuffixVTC	= '_ACPC';
			cArgTRF			= {opt.path_ia,opt.path_fa,opt.path_acpc};
		else
			strSpace		= 'VMR';
			strSuffixVTC	= '';
			cArgTRF			= {opt.path_ia,opt.path_fa};
		end
		strSuffixVTC	= [strSuffixVTC opt.suffixvtc];
		status(['VTCs will be in ' strSpace ' space'],n+1);
	%get VTC bounds
		if ischar(opt.bounds)
			switch lower(opt.bounds)
				case 'normal'
					opt.bounds	= [30 30 1; 225 255 200];
				case 'retinotopy'
					opt.bounds	= [30 150 1; 225 255 200];
				otherwise
					error(['"' opt.bounds '" is not a valid choice for VTC bounds']);
			end
		end
	%make sure we have a valid VTC resolution
		switch opt.resolution
			case {1 2 3}
			otherwise
				error('VTC resolution must be either 1, 2, or 3');
		end

%do it
	%start BVQX
		bvqx		= BVQXObject('visible',opt.showbv);
		strFileVMR	= PathGetFileName(opt.path_vmr);
		
	%create each VTC file
		nRun		= numel(opt.runs);
		cPathVTC	= cell(nRun,1);
		for kRun=1:nRun
			strRun			= StringFill(opt.runs(kRun),2);
			
			status(['Creating VTC for run ' strRun],n+1);
			
			%BVQX looks in the VMR directory rather than the FMR directory (as
			%it should) for the FMR's STC files.  Using SetCurrentDiretory
			%doesn't work either.  So we'll have to copy the VMR file to the
			%FMR directory and reopen it before every VTC creation
				strPathVMRTemp	= [cDirRun{kRun} strFileVMR];
				copyfile(opt.path_vmr,strPathVMRTemp,'f');
				
				vmr	= bvqx.OpenDocument(strPathVMRTemp);
				
				if bDoTAL
					CreateVTC	= @vmr.CreateVTCInTALSpace;
				elseif bDoACPC
					CreateVTC	= @vmr.CreateVTCInACPCSpace;
				else
					CreateVTC	= @vmr.CreateVTCInVMRSpace;
				end
			
			strPathFMR		= [cDirRun{kRun} strSession '_' strRun opt.suffixfmr '.fmr'];
			cPathVTC{kRun}	= PathAddSuffix(strPathFMR,strSuffixVTC,'vtc');
			
			%make the VTC with intensity low threshold.  The COM object doesn't
			%support fixed VTC bounds so we'll have to load it in after and to
			%the bounds ourselves (ugh).
				try
					bSuccess	= CreateVTC(strPathFMR,cArgTRF{:},cPathVTC{kRun},opt.resolution,1,0);
				catch
					bSuccess	= false;
				end
				
				%close the VMR document
					vmr.Close;
				%delete it
					delete(strPathVMRTemp);
				
				if bSuccess
					%open the VTC and keep the specified bounds
						status('Constructing VTC subset',n+2);
						vtc	= BVQXfile(cPathVTC{kRun});
						bvVTCRebound(vtc,opt.bounds);
					%save it
						vtc.SaveAs(cPathVTC{kRun});
					%clear it
						vtc.ClearObject;
				
					status('Success!',n+2);
				else
					status(['VTC creation failed for run ' strRun],n+2);
				end
		end
	
	%quit BVQX
		BVQXClose(bvqx);
	
	
%------------------------------------------------------------------------------%
function [cDirRun,kRun] = GetRunsToProcess(strDirRoot,strSession,kRun)
	%get the run directories
		[cDirRun,kRun]	= GetDirRun(strDirRoot,strSession,kRun,'cell_output',true);
	%find which ones contain FMR files
		[cPathFMR,cDirRunFMR]	= FindFilesByExtension(cDirRun,'fmr','groupbydir',true);
		bNoFMR					= cellfun(@isempty,cPathFMR);
		cDirRunFMR				= cDirRunFMR(~bNoFMR);
		
		[bFMR,kRunFMR]	= IsMemberCell(cDirRunFMR,cDirRun);
		cDirRun			= cDirRunFMR;
		kRun			= kRun(kRunFMR);
	
	status(['Runs to process: ' join(kRun,',')]);
%------------------------------------------------------------------------------%
function strSuffixFMR	= GetSuffixFMR(cDirRun,strSuffixFMR)
	%assume FMR files are named as <session>_<run><suffix> and that the desired
	%suffix comes from the longest-named FMR file in the first directory with
	%FMR files
		if isempty(strSuffixFMR)
			bSuccess	= false;
			
			nDirRun	= numel(cDirRun);
			for k=1:nDirRun
				cPathFMR	= FindFilesByExtension(cDirRun{k},'fmr');
				
				if numel(cPathFMR)
					%get the longest file name
						kLength			= cellfun(@numel,cPathFMR);
						[dummy,kMax]	= max(kLength);
					%get the pre-extension file name
						[dummy,strFile]	= PathSplit(cPathFMR{kMax});
					%get the suffix
						kStartSuffix	= find(strFile=='_',1,'first')+3;
						strSuffixFMR	= strFile(kStartSuffix:end);
					%done!
						bSuccess	= true;
						break;
				end
			end
		else
			bSuccess	= true;
		end
	
	if ~bSuccess
		error('No FMR files found.');
	end
	
	status(['FMR Suffix: ' strSuffixFMR]);
%------------------------------------------------------------------------------%
function strPathTRF = GetPathTRF(cDirRun,strDirSession,strSuffixTRF,strPathTRF)
	if isempty(strPathTRF)
		re	= [StringForRegExp(strSuffixTRF) '\.trf$'];
		
		nDirRun	= numel(cDirRun);
		for k=1:nDirRun
			cPathTRF	= FindFiles(cDirRun{k},re,'casei',true);
			
			if ~isempty(cPathTRF)
				strPathTRF	= cPathTRF{1};
				break;
			end
		end
	end
	
	if isempty(strPathTRF)
		error(['No ' strSuffixTRF ' TRF file found.']);
	end
	
	status([strSuffixTRF ' TRF: ' PathAbs2Rel(strPathTRF,strDirSession)]);
%------------------------------------------------------------------------------%
