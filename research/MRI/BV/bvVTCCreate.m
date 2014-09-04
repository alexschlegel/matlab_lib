function cPathVTC = bvVTCCreate(strDirBase,strSession,varargin)
% bvVTCCreate
% 
% Description:	create a set of VTC files for the given session (requires
%				BVQXtools)
%				
% 
% Syntax:	cPathVTC = bvVTCCreate(strDirBase,strSession,<options>)
% 
% In:
%	strDirBase		- base experimental directory
%	strSession		- the session code, or a cell of session codes
%	<options>:
%		'path_vmr':			(<find>) path to a VMR file.  specify this if no VMR
%							exists within the given root directory
%		'runs':				(<all>) an array of run numbers for which to create
%							VTCs, or a cell of arrays of runs (one for each
%							session)
%		'suffixfmr':		(<determine>) suffix of FMR files
%		'suffixvtc':		('') suffix to add to the end of the created VTC
%							file names
%		'path_ia':			(<find>) path to the initial adjustment TRF file, or
%							a cell of paths (one for each session)
%		'path_fa':			(<find>) path to the fine adjustment TRF file, or a
%							cell of paths (one for each session)
%		'path_acpc':		(<none>) path to the ACPC TRF file, or a cell of
%							paths (one for eah session)
%		'path_tal':			(<none>) path to the TAL file, or a cell of paths
%							(one for each session)
%		'bounds':			('normal') a 2x3 array specifying the x, y, and z
%							lower and upper bounds of the VTC files in BV system
%							space, or one of the following strings to specify a
%							standard set of bounds:
%								'normal':		[ 30  30  1
%												 225 255 200]
%								'retinotopy':	[ 30 150  1]
%												 225 255 200]
%		'resolution':		(3) either 1, 2, or 3 to specify the resolution, in
%							mm,
%							of the output VTC files
%		'interpolation':	('cubic') either 'nearest', 'linear', 'cubic', or
%							'spline' to specify the interpolation method to use
% 
% Out:
% 	cPathVTC	- a cell of cells of paths to the created VTC files (one cell
%				  for each session)
% 
% Note:	requires BVQX's COM object
% 
% Updated:	2009-07-29
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
		'interpolation'	, 'cubic'	  ...
		);
%make cells
	[strSession,opt.runs,opt.path_ia,opt.path_fa,opt.path_acpc,opt.path_tal]	= ForceCell(strSession,opt.runs,opt.path_ia,opt.path_fa,opt.path_acpc,opt.path_tal);
%make them the right size
	[strSession,opt.runs,opt.path_ia,opt.path_fa,opt.path_acpc,opt.path_tal]	= FillSingletonArrays(strSession,opt.runs,opt.path_ia,opt.path_fa,opt.path_acpc,opt.path_tal);

%find and load a VMR file
	if isempty(opt.path_vmr)
		opt.path_vmr	= FindPathVMR(strDirBase,strSession);
		if isempty(opt.path_vmr)
			error('No VMR file found.  Please specify explicitly.');
		end
	end
	strFileVMR	= PathGetFileName(opt.path_vmr);
	vmr			= BVQXfile(opt.path_vmr);
%get VTC bounds
	if ischar(opt.bounds)
		switch lower(opt.bounds)
			case 'normal'
				opt.bounds	= [30 30 1; 225 254 200];
			case 'retinotopy'
				opt.bounds	= [30 150 1; 225 254 200];
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
%make sure the interpolation method is valid
	switch lower(opt.interpolation)
		case {'nearest','linear','cubic','spline'}
		otherwise
			error(['"' opt.interpolation '" is an invalid interpolation method.']);
	end

status(['Base study directory: ' strDirBase]);

nSession	= numel(strSession);
cPathVTC	= cell(nSession,1);
for kS=1:nSession
	n	= status(['Creating VTCs for session ' strSession{kS}]);
	
	%get some info
		%get some paths
			strDirSession		= GetDirSession(strDirBase,strSession{kS});
			strDirFunctional	= GetDirFunctional(strDirBase,strSession{kS});
		%get the runs to process
			[cDirRun,opt.runs{kS}]	= GetRunsToProcess(strDirBase,strSession{kS},opt.runs{kS});
		%get the FMR suffix
			strSuffixFMR	= GetSuffixFMR(cDirRun,opt.suffixfmr);
		%get the IA transformation file
			opt.path_ia{kS}	= GetPathTRF(cDirRun,strDirSession,'_IA',opt.path_ia{kS});
			ia				= BVQXfile(opt.path_ia{kS});
		%get the path to the FA transformation file
			opt.path_fa{kS}	= GetPathTRF(cDirRun,strDirSession,'_FA',opt.path_fa{kS});
			fa				= BVQXfile(opt.path_fa{kS});
		%ACPC/TAL transform?
			bDoACPC	= ~isempty(opt.path_acpc{kS});
			if bDoACPC
				acpc	= BVQXfile(opt.path_acpc{kS});
				
				bDoTAL	= ~isempty(opt.path_tal{kS});
				if bDoTAL
					tal	= BVQXfile(opt.path_tal{kS});
				end
			else
				bDoTAL	= false;
			end
			
			if bDoTAL
				strSpace		= 'Talairach';
				strSuffixVTC	= '_TAL';
				cTRF			= {ia,fa,acpc,tal};
			elseif bDoACPC
				strSpace		= 'ACPC';
				strSuffixVTC	= '_ACPC';
				cTRF			= {ia,fa,acpc};
			else
				strSpace		= 'VMR';
				strSuffixVTC	= '';
				cTRF			= {ia,fa};
			end
			strSuffixVTC	= [strSuffixVTC opt.suffixvtc];
			status(['VTCs will be in ' strSpace ' space'],n+1);
	
	%do it
		%create each VTC file
			nRun			= numel(opt.runs{kS});
			cPathVTC{kS}	= cell(nRun,1);
			for kRun=1:nRun
				strRun			= StringFill(opt.runs{kS}(kRun),2);
				
				status(['Creating VTC for run ' strRun],n+1);
				
				strPathFMR			= [cDirRun{kRun} strSession{kS} '_' strRun strSuffixFMR '.fmr'];
				cPathVTC{kS}{kRun}	= PathAddSuffix(strPathFMR,strSuffixVTC,'vtc');
				
				%make sure .CoordinateSystem in the FMR is set to 1 (per
				%Jochen's advice)
					fmr						= BVQXfile(strPathFMR);
					fmr.CoordinateSystem	= 1;
				
				%create the VTC
					try
						vtc	= vmr.CreateVTC(fmr,cTRF,cPathVTC{kS}{kRun},opt.resolution,opt.interpolation,opt.bounds);
						vtc.ClearObject;
					catch
						status(['VTC creation failed for run ' strRun],n+2,'error',true);
						cPathVTC{kS}	= '';
					end
					
				%clear some objects
					fmr.ClearObject;
			end
			
	%clear some objects
		ia.ClearObject;
		fa.ClearObject;
		if bDoACPC
			acpc.ClearObject;
		end
		if bDoTAL
			tal.ClearObject;
		end
end

%clear some objects
	vmr.ClearObject;


%------------------------------------------------------------------------------%
function [cDirRun,kRun] = GetRunsToProcess(strDirBase,strSession,kRun)
	%get the run directories
		[cDirRun,kRun]	= GetDirRun(strDirBase,strSession,kRun,'cell_output',true);
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
