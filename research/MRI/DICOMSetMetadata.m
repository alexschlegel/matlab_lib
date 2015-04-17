function cPathDICOM = DICOMSetMetadata(cPathDICOM,cLabel,cValue,varargin)
% DICOMSetMetadata
% 
% Description:	set metadata values for a set of DICOM files
% 
% Syntax:	DICOMSetMetadata(cPathDICOM,cLabel,cValue,<options>)
% 
% In:
% 	cPathDICOM	- a string/cell of paths to DICOM files or directories
%				  containing DICOM files
%	cLabel		- a string/cell of metadata labels to set
%	cValue		- a value/cell of new values for the metadata
%	<options>:
%		'subdir':	(true) true to search subdirectories for DICOM files
%		'warn:		(true) true to give warning prompts
%		'progress': (true) true to show the progress bar
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
		'progress'	, true	  ...
		);

%make sure we have cells
	[cPathDICOM,cLabel,cValue]	= ForceCell(cPathDICOM,cLabel,cValue);
	
	nLabel	= numel(cLabel);
%get the files to update
	if numel(cPathDICOM)>0 && isdir(cPathDICOM{1})
		cPathDICOM	= FindFilesByExtension(cPathDICOM,'dcm','subdir',opt.subdir,'usequick',true);
	end
	nPathDICOM	= numel(cPathDICOM);
%prompt to continue
	if opt.warn
		strPlural	= plural(nPathDICOM,'','s');
		strPrompt	= ['Metadata for ' num2str(nPathDICOM) ' DICOM file' strPlural ' will be updated.  Continue?'];
		res			= ask(strPrompt,'title',mfilename,'choice',{'Yes','No'},'default','Yes');
		if ~isequal(res,'Yes')
			error('Canceled by user.');
		end
	end
%update each DICOM file
	if opt.progress
		progress('action','init','total',nPathDICOM,'label','DICOM file');
	end
	
	for kD=1:nPathDICOM
		ifo	= dicominfo(cPathDICOM{kD});
		im	= dicomread(ifo);
		
		for kL=1:nLabel
			ifo.(cLabel{kL})	= cValue{kL};
		end
		
		dicomwrite(im,cPathDICOM{kD},ifo,'CreateMode','copy');
		
		if opt.progress
			progress;
		end
	end
