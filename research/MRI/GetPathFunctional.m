function strPathFunctional = GetPathFunctional(strDirData,strSession,varargin)
% GetPathFunctional
% 
% Description:	get the path to a subject's functional data
% 
% Syntax:	strPathFunctional = GetPathFunctional(strDirData,strSession,<options>)
% 
% In:
% 	strDirData	- the root data directory
%	strSession	- the session code (or the subject id, for longitudinal studies)
%	<options>:
%		type:		('raw') the type of functional file to return. one of the
%					following:
%						raw: the unprocessed data (also specify <run>)
%						pp: the preprocessed data (also specify <run>)
%						cat: the preprocessed, concatenated data
%		run:		(1) the run number, or an array of numbers, or 'all' to
%					search for existing runs (only applies to types that are
%					separated by run)
%		session:	([]) for longitudinal data, the session number
% 
% Out:
% 	strPathFunctional	- the path to the functional data file
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(strSession)
	strPathFunctional	= '';
	return;
end

opt	= ParseArgs(varargin,...
		'type'		, 'raw'	, ...
		'run'		, 1		, ...
		'session'	, []	  ...
		);

strType	= CheckInput(opt.type,'type',{'raw','pp','cat'});

strDirFunctional	= GetDirData(strDirData,'functional',...
						'session_code'	, strSession	, ...
						'session'		, opt.session	  ...
						);

switch strType
	case {'raw','pp'}
		strSuffix	= switch2(strType,'raw','','pp','-pp');
		
		if isequal(opt.run,'all')
			strPathFunctional	= FindFiles(strDirFunctional,['data_\d+' strSuffix '\.nii\.gz']);
		else
			
			strPathFunctional	= arrayfun(@(r) PathUnsplit(strDirFunctional,sprintf('data_%02d%s',r,strSuffix),'nii.gz'),opt.run,'uni',false);
			
			if numel(opt.run)==1
				strPathFunctional	= strPathFunctional{1};
			end
		end
	case 'cat'
		strPathFunctional	= PathUnsplit(strDirFunctional,'data_cat','nii.gz');
end

strSuffix	= switch2(strType,...
				'raw'	, sprintf('_%02d',opt.run)		, ...
				'pp'	, sprintf('_%02d-pp',opt.run)	, ...
				'cat'	, '_cat'						  ...
				);
