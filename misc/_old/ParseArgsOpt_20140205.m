function varargout = ParseArgs(vargin,varargin)
% ParseArgs
% 
% Description:	parse a varargin cell of optional arguments and options.
%				optional arguments are arguments that do not need to be included
%				in a function call and assume a default value if omitted.
%				options are 'key'/value pairs that come at the end of a function
%				call argument list.
% 
% Syntax:	[v1,v2,...,vn,opt] = ParseArgs(vargin,d1,...,dn,opt1,opt1def,...,optM,optMdef)
%
% In:
%	vargin	- the varargin cell
%	dK		- the default value of the Kth optional argument
%	optJ	- the name of the Jth option
%	optJdef	- the default value of the Jth option
% 
% Out:
%	vK			- the value of the Kth optional argument
%	opt			- a struct of option values. options specified by the user but
%				  not given default values are place in opt.opt_extra
%
% Note:	if the user calls the function like this:
%		func(v1,...,vN-1,vN,opt1,val1,...,optM,valM), vN-1 might possibly have
%		the same value as one of the option names, and that option wasn't
%		explicitly set in the options section, then vN-1 will be confused with
%		the option.
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%number of things
	nUser		= numel(vargin);
	nDefault	= numel(varargin);
	nArgument	= nargout-1;
%make everything happy
	varargin	= reshape(varargin,nDefault,1);
	vargin		= reshape(vargin,nUser,1);
%split the input between optional arguments and options
	%split the defaults between optional arguments and options
		defArgument	= varargin(1:nArgument);
		defOptKey	= varargin(nArgument+1:2:nDefault);
		defOptVal	= varargin(nArgument+2:2:nDefault);
	%split user input between optional arguments and options
		if nUser
			%find the last possibility heading backward that's a string
				for kChar=nUser-1:-2:1
					if ~ischar(vargin{kChar})
						kChar	= kChar+2;
						break;
					end
				end
			%find the user-defined options
				%backwards so later options take precedent
					userOptKey	= vargin(nUser-1:-2:kChar);
					userOptVal	= vargin(nUser:-2:kChar);
				
				[bOverridden,kUserOption]	= ismembercellstr(defOptKey,userOptKey);
				kOverridden					= find(bOverridden);
				kUserOption					= kUserOption(bOverridden);
			%split
				bUserOption	= ~isempty(kUserOption);
				if bUserOption
					kUserArgEnd		= nUser - 2*max(kUserOption);
					userArgument	= vargin(1:min(nArgument,kUserArgEnd));
					
					userOptKeyExtra	= userOptKey;
					userOptValExtra	= userOptVal;
					userOptKeyExtra(kUserOption)	= [];
					userOptValExtra(kUserOption)	= [];
					
					userOptKey	= userOptKey(kUserOption);
					userOptVal	= userOptVal(kUserOption);
					
					%eliminate explicitly unspecified options
						bUserUnspecified	= cellfun(@isempty,userOptVal);
						bOverridden(kOverridden(bUserUnspecified))	= false;
						
						userOptKey(bUserUnspecified)	= [];
						userOptVal(bUserUnspecified)	= [];
				else
					userArgument			= vargin(1:min(nArgument,nUser));
					
					[userOptKey,userOptVal,userOptKeyExtra,userOptValExtra]	= deal({});
				end
		else
			varargout	= [defArgument; cell2struct(defOptVal,defOptKey)];
			
			return;
		end

%parse optional arguments
	varargout				= defArgument;
	bOmitted				= cellfun(@isempty,userArgument);
	varargout(~bOmitted)	= userArgument(~bOmitted);
%parse the options
	if bUserOption
		%concatenate the default options with the specified options
			optKey	= [defOptKey(~bOverridden); userOptKey];
			optVal	= [defOptVal(~bOverridden); userOptVal];
	else
		optKey	= defOptKey;
		optVal	= defOptVal;
	end
	
	opt	= cell2struct(optVal,optKey);
	
	%get the extra options specified by the user
	if ~isempty(userOptKeyExtra)
		try
		%first assume there are no duplicate field names
			opt.opt_extra	= cell2struct(userOptValExtra, userOptKeyExtra);
		catch me
			[errMsg,errID]	= lasterr;
			switch errID
				case 'MATLAB:DuplicateFieldName'
				%ok, this will be a bit slower
					[userOptKeyExtra,kUnique]	= unique(userOptKeyExtra);
					userOptValExtra				= userOptValExtra(kUnique);
					opt.opt_extra				= cell2struct(userOptValExtra, userOptKeyExtra);
				otherwise
					rethrow(me);
			end
		end
	else
		opt.opt_extra	= struct;
	end
	
	varargout{end+1}	= opt; 
