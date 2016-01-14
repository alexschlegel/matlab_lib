function varargout = cellfunprogress(f,varargin)
% cellfunprogress
% 
% Description:	cellfun with a progress bar
% 
% Syntax:	cellfunprogress(<cellfun inputs>,<options>)
% 
% In:
%	<cellfun inputs>:	see cellfun
%	<options>:	options for cellfun and progress.  In addition:
%		status:	([]) same as the status option for progress, but can also be
%				an input argument index if each element of that input should be
%				displayed as a status as that element is processed
% 
% Updated: 2016-01-14
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	%find the last of the first continuous block of cell inputs
		bCell		= cellfun(@iscell,varargin);
		kLastCell	= unless(find(~bCell,1,'first')-1,numel(varargin));
	
	cOpt	= varargin(kLastCell+1:end);
	opt		= ParseArgs(cOpt,...
				'status'	, []	  ...
				);

	%parse the arguments
		%function inputs
			cCell	= varargin(1:kLastCell);
			if isempty(cCell)
				s	= [0 0];
				n	= 0;
			else
				s	= size(cCell{1});
				n	= numel(cCell{1});
			end
		%are we displaying statuses?
			if ~isempty(opt.status) && ~islogical(opt.status)
				cStatus		= cCell{opt.status};
				opt.status	= true;
			else
				cStatus	= repmat({[]},s);
			end

%open the progress bar
	fName	= char(f);
	
	opt_progress	= optadd(opt.opt_extra,...
						'label',	sprintf('cellfun: %s',fName)	  ...
						);
	opt_progress	= optreplace(opt_progress,...
						'action'	, 'init'		, ...
						'total'		, n				, ...
						'status'	, opt.status	  ...
						);
	
	cOpt		= opt2cell(opt_progress);
	sProgress	= progress(cOpt{:});

%call cellfun
	f			= repmat({f},s);
	cProgName	= repmat({sProgress.name},s);
	cOptExtra	= opt2cell(sProgress.opt_extra);
	[varargout{1:nargout}]	= cellfun(@cellfunfun,f,cProgName,cStatus,cCell{:},cOptExtra{:});
	
%------------------------------------------------------------------------------%
function varargout = cellfunfun(f,strProgName,strStatus,varargin)
	[varargout{1:nargout}]	= f(varargin{:});
	
	if ~isempty(strStatus)
		status(strStatus);
	end
	progress('name',strProgName);
%------------------------------------------------------------------------------%
