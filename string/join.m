function str = join(x,chr,varargin)
% join
% 
% Description:	join the elements of x with the string chr
% 
% Syntax:	str = join(x,chr,<options>)
% 
% In:
% 	x	- an array
%	chr	- the string to place between each element of x
%	<options>:
%		enclose:	(<none>) a string with which to enclose each element of x
%		escape:		(true) true to escape instances of the enclosing character
%					in the elements of x
% 
% Out:
% 	str	- the joined string
% 
% Example:	join({1,2,3},',') == '1,2,3'
% 
% Updated: 2012-12-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optDefault cOptDefault

if isempty(optDefault)
	optDefault	= struct(...
					'enclose'	, ''	, ...
					'escape'	, true	  ...
					);
	cOptDefault	= Opt2Cell(optDefault);
end

if numel(varargin)==0
	opt	= optDefault;
else
	opt	= ParseArgs(varargin,cOptDefault{:});
end

%convert to a cell
	if ~iscell(x)
		x	= num2cell(x);
	end
%convert each element to a string
	bToString		= ~cellfun(@ischar,x);
	x(bToString)	= cellfun(@tostring,x(bToString),'UniformOutput',false);
%escape the enclosing character
	if opt.escape && ~isempty(opt.enclose)
		x	= cellfun(@(x) strrep(x,opt.enclose,['\' opt.enclose]),x,'UniformOutput',false);
	end
%convert each element to a string and enclose
	if ~isempty(opt.enclose)
		x	= cellfun(@(x) [opt.enclose x opt.enclose],x,'UniformOutput',false);
	end
%add the delimiter
	n	= numel(x);
	x	= reshape([reshape(x,[],1) [repmat({chr},[n-1 1]); {''}]]',[],1);
	
	%x(1:end-1)	= cellfun(@(x) [x chr],x(1:end-1),'UniformOutput',false);
%concatenate
	str	= cat(2,x{:});
	