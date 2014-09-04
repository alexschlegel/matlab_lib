function matlabbatch = DICOM2Analyze(varargin)
% DICOM2Analyze
% 
% Description:	uses an SPM8 batch to convert a set of DICOM files to Analyze
%				format
% 
% Syntax:	matlabbatch = DICOM2Analyze([strDirIn]=<prompt>,[strDirOut]=<prompt>,<options>) OR
%			matlabbatch = DICOM2Analyze(strPathDICOM,[strDirOut]=<prompt>,<options>) OR
% 
% In:
% 	[strDirIn]		- path to the directory containing DICOM files to convert,
%					  or a cell of directories
%	strPathDICOM	- the path to the DICOM file to convert, or a cell of paths
%	[strDirOut]		- output directory
%	<options>:
%		'subdir'		- (true) true to search all subdirectories of strDirIn
%						  for DICOM files
%		'gui'			- (true) true to show the SPM GUI
%		'organize'		- (true) true to organize the output file structure.
%						  only applies if directories were passed as input
%		'shutdown'		- (false) true to attempt to shutdown the computer after
%						  the process finishes
%		'prompt'		- (true) true to show prompts
%		'out_structure'	- ('patid_date') string specifying output directory
%						  structure (see matlabbatch{1}.spm.util.dicom.root in
%						  SPM DICOM Import batch file).  only applies if
%						  'organize' is false.
%		'format'		- ('img') string specifying the output file format (see
%						  matlabbatch{1}.spm.util.dicom.convopts.format in SPM
%						  DICOM Import batch file).  only applies if 'organize'
%						  is false.
%		'icedims'		- (false) true to use additional SIEMENS ICEDims
%						  information
%
% Out:
%	matlabbatch	- the struct to pass to spm_jobman to execute the specified
%				  batch conversion
% 
% Assumptions:	assumes SPM8 is installed
% 
% Updated:	2009-07-08
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%parse optional arguments
	[strIn,strDirOut,opt]	= ParseArgsOpt(varargin,[],[], ...
		'subdir'		, true			, ...
		'gui'			, true			, ...
		'organize'		, true			, ...
		'shutdown'		, false			, ...
		'prompt'		, true			, ...
		'out_structure'	, 'patid_date'	, ...
		'format'		, 'img'			, ...
		'icedims'		, false			  ...
		);
	if opt.organize
		opt.out_structure	= 'patid_date';
	end
	if opt.gui
		hChildrenBefore	= get(0,'Children');
	end
%current directory
	strDirCur	= pwd;
%get the input and output directories
	%input
		strIn	= ForceCell(strIn);
		
		bPrompt	= isequal(strIn,{[]}) || exist(strIn{1},'dir');
		if bPrompt
			cDirIn	= GetInputDirectory(strIn);
		end
	%output
		strDirOut	= GetOutputDirectory(strDirOut);
		
		%get the directories already in the output
			if opt.organize
				cSubDirBefore	= FindDirectories(strDirOut,'subdir',true);
			end
%organize input files directories
	if bPrompt
		status('Searching for input DICOM files');
		[cPathDICOM,cDirDICOM]	= FindFilesByExtension(cDirIn,'dcm','subdir',opt.subdir,'groupbydir',true);
	else
		[cPathDICOM,cDirDICOM]	= PathGroupByDir(ForceCell(strIn));
		opt.organize			= false;
	end

%initialize jobman
	status('Initializing spm_jobman');
	
	if opt.gui
		spm('fmri');
	end
	
	spm_jobman('initcfg');
%run one job per directory
	nDir	= numel(cDirDICOM);
	
	for kDir=1:nDir
		%prepare the SPM batch
			matlabbatch{1}.spm.util.dicom	= struct(		  ...
				'data'		, {cPathDICOM{kDir}}			, ...
				'root'		, opt.out_structure				, ...
				'outdir'	, {{strDirOut}}					, ...
				'convopts'	, struct(						  ...
								'format'	, opt.format	, ...
								'icedims'	, opt.icedims	  ...
								)							  ...
				);
		%run the job
			status(['Running the DICOM conversion batch job for directory: ' cDirDICOM{kDir}]);
			try
				spm_jobman('run',matlabbatch);
			catch
				status(['DICOM conversion batch job for directory "' cDirDICOM{kDir} '" failed.']);
				
				cd(strDirCur);
				
				%reopen SPM
					if opt.gui
						hChildrenAfter	= get(0,'Children');
						hSPM			= setdiff(hChildrenAfter,hChildrenBefore);
						delete(hSPM);
						spm('fmri');
						spm_jobman('initcfg');
					end
			end
	end
%delete the SPM windows
	if opt.gui
		hChildrenAfter	= get(0,'Children');
		hSPM			= setdiff(hChildrenAfter,hChildrenBefore);
		delete(hSPM);
	end

%organize the file structure
	if opt.organize
		%get the newly created subdirectories
			cSubDirAfter	= FindDirectories(strDirOut,'subdir',true);
			cSubDirNew		= setdiff(cSubDirAfter,cSubDirBefore);
			nSubDirNew		= numel(cSubDirNew);
			
			if nSubDirNew==0
				status('No new directories created.  Not organizing.');
			else
				cUndo	= OrganizeMRIFolders(cSubDirNew,strDirOut,'subdir',false,'warn',false,'prompt',opt.prompt);
			end
	end
	
%shutdown the computer
	if opt.shutdown
		shutdown('prompt',opt.prompt);
	end


%------------------------------------------------------------------------------%
function cIn = GetInputDirectory(cIn)
	if isequal(cIn,{[]})
		cIn	= PromptDir([],'Choose the Directory to Convert');
		
		if isempty(cIn)
			error('User Aborted');
		end
	end
%------------------------------------------------------------------------------%
function strDirOut = GetOutputDirectory(strDirOut)
	strDirOut	= PromptDir(strDirOut,'Choose the Base Output Directory');
	
	if isempty(strDirOut)
		error('User Aborted');
	end
%------------------------------------------------------------------------------%
