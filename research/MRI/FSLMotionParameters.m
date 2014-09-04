function d = FSLMotionParameters(strDirFEAT)
% FSLMotionParameters
% 
% Description:	read the motion parameters for a functional run or set of runs
%				that have been preprocessed using FEAT
% 
% Syntax:	d = FSLMotionParameters(strDirFEAT)
% 
% In:
% 	strDirFEAT	- the path to a feat directory or a root functional directory.
%				  if a root functional directory is specified, then 6*nRun motion
%				  parameters are returned that apply to a concatenation of the
%				  runs in the directory, i.e. each motion parameter is nTR-cat
%				  elements long and consists of zeros except for those TRs in the
%				  concatenated data that match up with the corresponding run.
% 
% Out:
% 	d	- an nParam x nTR array of motion parameters
% 
% Updated: 2012-07-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%did we get a FEAT directory or a root functional directory?
	cDirFEAT	= FindDirectories(strDirFEAT,'feat[-]?\d*$');
	nDirFEAT	= numel(cDirFEAT);

if nDirFEAT==0
%single feat directory
	d	= GetMP(strDirFEAT);
else
%multiple feat directories
	%load each motion parameter
	d	= cellfun(@GetMP,cDirFEAT,'UniformOutput',false);
	
	%get the number of TRs per run
		nTR			= cellfun(@(x) size(x,1),d);
		nTRTotal	= sum(nTR);
		nTROffset	= [0; cumsum(nTR(1:end-1))];
	%convert each parameter array to the equivalent for the cat data
		d	= cellfun(@(d,tro) [zeros(tro,size(d,2)); d; zeros(nTRTotal-tro-size(d,1),size(d,2))],d,num2cell(nTROffset),'UniformOutput',false);
	%concatenate
		d	= cat(2,d{:});
end

%------------------------------------------------------------------------------%
function mp = GetMP(strDirFEAT)
	strPathMP	= PathUnsplit(DirAppend(strDirFEAT,'mc'),'prefiltered_func_data_mcf','par');
	
	if ~FileExists(strPathMP)
		error(['Motion parameters do not exist for feat directory "' strDirFEAT '".']);
	end
	
	mp	= str2array(fget(strPathMP));
end
%------------------------------------------------------------------------------%

end
