function varargout = ParseArgsOptExt(vArg,varargin)
% ParseArgsOptExt
% 
% Description:	parse a varargin cell of optional arguments, with a trailing
%				list of options specified as ...,'<optionK_name>',optionK,...
% 
% Syntax:	[v1,v2,...,vn,opt,optExtra] = ParseArgsOptExt(vArg,d1,...,dn,'<option1_name>',option1_default,...)
%
% In:
%	vArg	- the varargin cell
%	dk		- the default value of the kth varargin element
%	'<optionk_name>'/optionk_defaultk
% 
% Out:
%	vk			- the value of the kth varargin element
%	opt			- a struct specifying the options specified by the user
%	optExtra	- a struct of options that were specified by the user but not by
%				  the input arguments
%
% Note:	if the user calls the function like this:
%	FUNCTION(optarg1,...,optargN-1,optargN,'<option1>',optval1,...,'<optionM>',optvalM),
%	and optargN-1, optargN-3, etc. are all chars, then each will be counted as
%	an extra option rather than an optional argument
%
% Updated:	2011-02-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%number of things
	nIn			= numel(vArg);
	nTotal		= numel(varargin);
	nArgument	= nargout-2;
	nOption		= (nTotal-nArgument)/2;
%make everything happy
	varargin	= reshape(varargin,nTotal,1);
	vArg		= reshape(vArg,nIn,1);
%split the input between optional arguments and options
	%split between specified optional arguments and options specification
		defArgument	= varargin(1:nArgument);
		defOptKey	= lower(varargin(nArgument+1:2:end));
		defOptVal	= varargin(nArgument+2:2:end);
	%split between input optional arguments and options specification
		[inArgument,inOptKey,inOptVal]	= SplitInputArgOpt;

%parse optional arguments
	varargout				= defArgument;
	bOmitted				= cellfun(@isempty,inArgument);
	varargout(~bOmitted)	= inArgument(~bOmitted);
%parse options
	%get rid of explicitly unspecified options
		bUnspecified			= cellfun(@isempty,inOptVal);
		inOptKey(bUnspecified)	= [];
		inOptVal(bUnspecified)	= [];
	
	optKey	= [defOptKey; inOptKey];
	optVal	= [defOptVal; inOptVal];
	
	[optKey,kUnique]	= unique(optKey,'last');
	optVal				= optVal(kUnique);
	
	varargout{end+1}	= cell2struct(optVal,optKey);

%find the input options that weren't specified options
	cExtra				= lower(setdiff(inOptKey,defOptKey));
	if ~isempty(cExtra)
		cExtraVal			= cellfun(@(x) varargout{end}.(x),cExtra,'UniformOutput',false);
		varargout{end+1}	= cell2struct(cExtraVal,cExtra);
	else
		varargout{end+1}	= struct;
	end
	
%------------------------------------------------------------------------------%
function [inArgument,inOptKey,inOptVal] = SplitInputArgOpt()
%splits the arguments portion and options portion of the varargin cell
	
	%find the last possibility heading backward that's a string
		for kChar=nIn-1:-2:1
			if ~ischar(vArg{kChar})
				kChar	= kChar+2;
				break;
			end
		end
	%find the first possibility going forward that matches
		kMatch	= unless(kChar,nIn+1);
% 		bMatch	= false;
% 		for kMatch=kChar:2:nIn
% 			bMatch	= ismember(vArg{kMatch},defOptKey);
% 			if bMatch
% 				break;
% 			end
% 		end
% 		if ~bMatch
% 			kMatch	= nIn+1;
% 		end
	%split
		inArgument	= vArg(1:min(nArgument,kMatch-1));
		inOptKey	= lower(vArg(kMatch:2:nIn));
		inOptVal	= vArg(kMatch+1:2:nIn);
end
%------------------------------------------------------------------------------%

end
