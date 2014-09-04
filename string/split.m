function [cSplit,varargout] = split(str,delim,varargin)
% split
% 
% Description:	split a string into a cell of strings based on a delimiter
% 
% Syntax:	[cSplit,[cAux]] = split(str,delim,<options>)
% 
% In:
% 	str		- the string to split
%	delim	- the regexp pattern delimiter
%	<options>:
%		aux:		(<none>) an auxillary array to split the same as str
%		withdelim:	(false) true to include the delimiter in each split string
%		delimpost:	(false) true to, if <withdelim>==true include the delimiter
%					with the following split string
%		splitend:	(false) true to include empty elements if the string begins
%					or ends with the dlimiter
% 
% Out:
% 	cSplit	- a cell of each split substring of str
%	[cAux]	- the split auxillary cell
% 
% Example:	split('1,2,3',',')			=> {'1','2','3'};
%			split('1/2\3/','[\\\/]')	=> {'1','2','3'};
% 
% Updated:	2014-07-09
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optD cOptD

if isempty(optD)
	optD	= struct(...
				'aux'		, []	, ...
				'withdelim'	, false	, ...
				'delimpost'	, false	, ...
				'splitend'	, false	  ...
				);
	cOptD	= Opt2Cell(optD);
end

if numel(varargin)==0
	opt	= optD;
else
	opt	= ParseArgsOpt(varargin,cOptD{:});
end

n	= numel(str);

delim	= char(delim);

%split the string
	[kStart,kEnd,cSplit,cDelim]	= regexp(str,delim,'start','end','split','match');
	nSplit	= numel(kStart);
	kStart	= reshape(kStart,nSplit,1);
	kEnd	= reshape(kEnd,nSplit,1);
	cSplit	= reshape(cSplit,nSplit+1,1);
	cDelim	= reshape(cDelim,nSplit,1);
%optionally include the delimiter
	if opt.withdelim
		if opt.delimpost
			cDelim	= [{''}; cDelim];
			cSplit	= cellfun(@(x,y) [y x],cSplit,cDelim,'UniformOutput',false);
		else
			cDelim	= [cDelim; {''}];
			cSplit	= cellfun(@(x,y) [x y],cSplit,cDelim,'UniformOutput',false);
		end
	end
%split the auxillary array
	if nargout>1
		%get the split endpoints
			if numel(cSplit)>=1
				kStartSplit	= [1; kEnd+1];
				kEndSplit	= [kStart-1; n];
			else
				[kStartSplit,kEndSplit]	= deal([]);
			end
		%make the split
			varargout{1}	= arrayfun(@(x,y) opt.aux(x:y),kStartSplit,kEndSplit,'UniformOutput',false);
		%optionally add the delimiter
			if opt.withdelim
				cDelim	= [arrayfun(@(u,v) opt.aux(u:v),kStart,kEnd,'UniformOutput',false)];
				if opt.delimpost
					cDelim			= [{[]}; cDelim];
					varargout{1}	= cellfun(@(x,y) [y x],varargout{1},cDelim,'UniformOutput',false);
				else
					cDelim			= [cDelim; {[]}];
					varargout{1}	= cellfun(@(x,y) [x y],varargout{1},cDelim,'UniformOutput',false);
				end
				
				
			end
	end
%delete empty end elements
	if ~opt.splitend
		if numel(cSplit)>0
			if isempty(cSplit{1})
				cSplit(1)	= [];
				if nargout>1
					varargout{1}(1)	= [];
				end
			end
			if numel(cSplit)>0 && isempty(cSplit{end})
				cSplit(end)	= [];
				if nargout>1
					varargout{1}(end)	= [];
				end
			end
		end
	end
