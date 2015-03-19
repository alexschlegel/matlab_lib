function strPathDTI = GetPathDTI(strDirData,strSession,varargin)
% GetPathDTI
% 
% Description:	get the path to a subject's DTI data
% 
% Syntax:	strPathDTI = GetPathDTI(strDirData,strSession,<options>)
% 
% In:
% 	strDirData	- the root data directory
%	strSession	- the session code (or the subject id, for longitudinal studies)
%	<options>:
%		type:		('raw') the type of DTI file to return. one of the
%					following:
%						raw: the unprocessed data
%						bvals: the bvals file
%						bvecs: the bvecs file
%						nodif: the nodif (no diffusion) file
%						fa/md/rd/ad/l1/l2/l3/mo/s0/v1/v2/v3: one of the
%							FSL-produced files (append a 'z' to the type to
%							return the Z-scored version)
%		session:	([]) for longitudinal data, the session number
% 
% Out:
% 	strPathDTI	- the path to the DTI data file
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(strSession)
	strPathDTI	= '';
	return;
end

opt	= ParseArgs(varargin,...
		'type'		, 'raw'	, ...
		'session'	, []	  ...
		);

cTypeFSL	= {'fa','md','rd','ad','l1','l2','l3','mo','s0','v1','v2','v3'};
cTypeFSLZ	= cellfun(@(s) sprintf('%sz',s),cTypeFSL,'uni',false);
strType		= CheckInput(opt.type,'type',['raw','bvals','bvecs','nodif',cTypeFSL,cTypeFSLZ]);

strDirDTI	= GetDirData(strDirData,'diffusion',...
				'session_code'	, strSession	, ...
				'session'		, opt.session	  ...
				);

%pre-extension
	switch opt.type
		case 'raw'
			strFile	= 'data';
		case {'bvals','bvecs','nodif'}
			strFile	= opt.type;
		otherwise
			strFile	= sprintf('data_%s',upper(opt.type));
	end
%extension
	switch opt.type
		case {'bvals','bvecs'}
			strExt	= '';
		otherwise
			strExt	= 'nii.gz';
	end

strPathDTI	= PathUnsplit(strDirDTI,strFile,strExt);
