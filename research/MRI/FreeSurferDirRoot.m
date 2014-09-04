function strDirFS = FreeSurferDirRoot
% FreeSurferDirRoot
% 
% Description:	get the root FreeSurfer directory
% 
% Syntax:	strDirFS = FreeSurferDirRoot
% 
% Updated: 2011-03-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent dfs;

if isempty(dfs)
	if isunix
		[ec,dfs]	= RunBashScript('echo $FREESURFER_HOME','silent',true);
		
		if ec~=0 || isempty(dfs)
			error('FreeSurfer not found.');
		end
		
		dfs			= AddSlash(StringTrim(dfs));
	else
		error('Not implemented for non-unix OSes.');
	end
end

strDirFS	= dfs;
