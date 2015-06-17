function cPathDICOM = DICOMSetSessionName(cPathDICOM,strSession,varargin)
% DICOMSetSessionName
% 
% Description:	set the session name for a set of DICOM files
% 
% Syntax:	cPathDICOM = DICOMSetSessionName(cPathDICOM,strSession,<options>)
% 
% In:
% 	cPathDICOM	- a string/cell of paths to DICOM files or directories
%				  containing DICOM files
%	strSession	- the new session name
%	<options>:
%		'subdir':	(true) true to search subdirectories for DICOM files
%		'warn:		(true) true to give warning prompts
%		'progress': (true) true to show the progress bar
%		'debug':	(false) true to display debug info
% 
% Out:
% 	cPathDICOM	- a cell of paths to DICOM files that were altered
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'subdir'	, true	, ...
		'warn'		, true	, ...
		'progress'	, true	, ...
		'debug'		, false	  ...
		);

if opt.debug
	tStart	= tic;
end

%get the files to update
	cPathDICOM	= ForceCell(cPathDICOM);
	if numel(cPathDICOM)>0 && isdir(cPathDICOM{1})
		cPathDICOM	= FindFilesByExtension(cPathDICOM,'dcm','subdir',opt.subdir,'usequick',true);
	end
	nPathDICOM	= numel(cPathDICOM);
%prompt to continue
	if opt.warn
		strPlural	= plural(nPathDICOM,'','s');
		strPrompt	= ['Session name for ' num2str(nPathDICOM) ' DICOM file' strPlural ' will be updated.  Continue?'];
		res			= ask(strPrompt,'title',mfilename,'choice',{'Yes','No'},'default','Yes');
		if ~isequal(res,'Yes')
			error('Canceled by user.');
		end
	end
%update each DICOM file
	if opt.progress
		progress('action','init','total',nPathDICOM,'label','DICOM file');
	end
	
	cDirRename	= {};
	for kDCM=1:nPathDICOM
		if toc(tStart)>60
			tStart = tic;
			
			DispDebug;
		end
		
		%get the old info
			ifo				= dicominfo(cPathDICOM{kDCM});
			im				= dicomread(ifo);
			strSessionOld	= ifo.PatientID;
		%delete the old file
			delete(cPathDICOM{kDCM});
		%get the new path
			[strDir,strPre,strExt]	= PathSplit(cPathDICOM{kDCM});
			strPreNew				= strrep(strPre,strSessionOld,strSession);
			cPathDICOM{kDCM}		= PathUnsplit(strDir,strPreNew,strExt);
		%check to see if the directory path needs to be changed later
			cDir	= DirSplit(strDir);
			kDir	= FindCell(cDir,strSessionOld);
			if ~isempty(kDir)
				nDir	= numel(kDir);
				for kD=1:nDir
					cDirRename	= [cDirRename; {DirUnsplit(cDir(1:kDir(kD)))}];
				end
			end
		%update metadata
			ifo.PatientID				= strSession;
			ifo.PatientName.FamilyName	= strSession;
		%write the new DICOM file
			dicomwrite(im,cPathDICOM{kDCM},ifo,'CreateMode','copy');
		
		if opt.progress
			progress;
		end
	end
%rename directories
	nDirRename	= numel(cDirRename);
	
	if nDirRename>0
		if opt.progress
			progress('action','init','total',nDirRename,'label','Renaming directory');
		end
		
		for kD=1:nDirRename
			if isdir(cDirRename{kD})
				cDir		= DirSplit(cDirRename{kD});
				cDir{end}	= strSession;
				strDirNew	= DirUnsplit(cDir);
				
				movefile(cDirRename{kD},strDirNew);
			end
			
			if opt.progress
				progress;
			end
		end
	end

%------------------------------------------------------------------------------%
function DispDebug()
	mem	= memory;
	status(['Memory available: ' num2str(mem.MemAvailableAllArrays/1000000) 'MB']);
%------------------------------------------------------------------------------%
