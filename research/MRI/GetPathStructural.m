function strPathStructural = GetPathStructural(strDirData,strSession,varargin)
% GetPathStructural
% 
% Description:	get the path to a subject's structural data
% 
% Syntax:	strPathStructural = GetPathStructural(strDirData,strSession,<options>)
% 
% In:
% 	strDirData	- the root data directory
%	strSession	- the session code (or the subject id, for longitudinal studies)
%	<options>:
%		type:		('raw') the type of functional file to return. one of the
%					following:
%						raw: the unprocessed data
%						brain: the BETed version of the structural data
%		session:	([]) for longitudinal data, the session number
% 
% Out:
% 	strPathStructural	- the path to the structural data file
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(strSession)
	strPathStructural	= '';
	return;
end

opt	= ParseArgs(varargin,...
		'type'		, 'raw'	, ...
		'session'	, []	  ...
		);

strType	= CheckInput(opt.type,'type',{'raw','brain'});

strSuffix	= switch2(strType,...
				'raw'	, ''		, ...
				'brain'	, '_brain'	  ...
				);

strDirStructural	= GetDirData(strDirData,'structural',...
						'session_code'	, strSession	, ...
						'session'		, opt.session	  ...
						);

strPathStructural	= PathUnsplit(strDirStructural,sprintf('data%s',strSuffix),'nii.gz');
