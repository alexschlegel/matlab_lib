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
%		status:	(false) same as the status option for progress, but can also be
%				an input argument index if each element of that input should be
%				displayed as a status as that element is processed
% 
% Updated: 2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%find the last of the first continuous block of cell inputs
	bCell		= cellfun(@(x) isa(x,'cell'),varargin);
	kLastCell	= find(~bCell,1,'first')-1;
	if isempty(kLastCell)
		kLastCell	= numel(varargin);
	end

cOpt	= varargin(kLastCell+1:end);
opt		= ParseArgs(cOpt,...
			'status'	, false	, ...
			'noffset'	, []	  ...
			);
if ~isempty(opt.noffset)
	opt.noffset	= opt.noffset-1;
end

%parse the arguments
	%function inputs
		cCell	= varargin(1:kLastCell);
		s		= size(cCell{1});
		n		= numel(cCell{1});
	%are we displaying statuses?
		if ~islogical(opt.status)
			cStatus		= cCell{opt.status};
			opt.status	= true;
		else
			cStatus	= repmat({[]},s);
		end

%open the progress bar
	fName	= char(f);
	cOpt	= optadd(cOpt,'label',sprintf('cellfun: %s',fName));
	
	[strProgName,nStatus,optExtra]	= progress(n,cOpt{:},'noffset',opt.noffset,'status',opt.status);

%call cellfun
	f			= repmat({f},s);
	cProgName	= repmat({strProgName},s);
	cNOffset	= repmat({nStatus+1},s);
	cOptExtra	= opt2cell(optExtra);
	[varargout{1:nargout}]	= cellfun(@cellfunfun,f,cProgName,cStatus,cNOffset,cCell{:},cOptExtra{:});
	
%------------------------------------------------------------------------------%
function varargout = cellfunfun(f,strProgName,strStatus,nOffset,varargin)
	[varargout{1:nargout}]	= f(varargin{:});
	
	if ~isempty(strStatus)
		status(strStatus,nOffset);
	end
	progress('name',strProgName);
%------------------------------------------------------------------------------%
