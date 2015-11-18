function varargout = ParseArgs(vargin,varargin)
% ParseArgs
% 
% Description:	parse a varargin cell of optional arguments and options.
%				optional arguments are arguments that do not need to be included
%				in a function call and assume a default value if omitted.
%				options are 'key'/value pairs that come at the end of a function
%				call argument list.
% 
% Syntax:	[v1,v2,...,vn,[opt]] = ParseArgs(vargin,d1,...,dn[,opt1,opt1def,...,optM,optMdef])
%
% In:
%	vargin		- the varargin cell or an opt struct. if the last element of the
%				  cell is an opt struct, then that is treated as the options
%				  portion of the input
%	dK			- the default value of the Kth optional argument
%	[optJ]		- the name of the Jth option
%	[optJdef]	- the default value of the Jth option
% 
% Out:
%	vK			- the value of the Kth optional argument
%	[opt]		- a struct of option values. options specified by the user but
%				  not given default values are place in opt.opt_extra
%
% Note:	if the user calls the function like this:
%		func(v1,...,vN-1,vN,opt1,val1,...,optM,valM), vN-1 might possibly have
%		the same value as one of the option names, and that option wasn't
%		explicitly set in the options section, then vN-1 will be confused with
%		the option.
% 
% Updated: 2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isoptstruct(vargin)
	vargin	= opt2cell(vargin);
elseif numel(vargin)>0 && isoptstruct(vargin{end})
	cOpt	= reshape(opt2cell(vargin{end}),1,[]);
	vargin	= [reshape(vargin(1:end-1),1,[]) cOpt];
end

nUser		= numel(vargin);
nDefault	= numel(varargin);
nOut		= nargout;
bOption		= nDefault~=nOut;
nArgument	= nOut - bOption;

%reshape just to make sure
	vargin		= reshape(vargin,nUser,1);
	varargin	= reshape(varargin,nDefault,1);

if bOption
	varargout	= DoParseOpt;
else
	varargout	= DoParse;
end

%------------------------------------------------------------------------------%
function out = DoParseOpt
	%split the input between optional arguments and options
		%split the defaults between optional arguments and options
			defArgument	= varargin(1:nArgument);
			defOptKey	= varargin(nArgument+1:2:nDefault);
			defOptVal	= varargin(nArgument+2:2:nDefault);
		%split user input between optional arguments and options
			if nUser>0
			%the user specified arguments explicitly
				%head backward to find the earliest user argument that might be
				%an option key
					%last possible option key is one from the end
						kChar	= nUser - 1;
					%find the first argument going backward that isn't a string
						while kChar>0 && ischar(vargin{kChar})
							kChar	= kChar - 2;
						end
					%earliest possible option key is two forward from that
						kChar	= kChar + 2;
				%what do we have?
					if kChar<1 || kChar>nUser || ~ischar(vargin{kChar})
					%no options were specified
						kFirstOptKey	= nUser+1;
						
						optKey	= defOptKey;
						optVal	= defOptVal;
						[optKeyExtra,optValExtra]	= deal({});
					else
						kKeyUserPossible	= kChar:2:nUser-1;
						optKeyUserPossible	= vargin(kKeyUserPossible);
						optValUserPossible	= vargin(kKeyUserPossible+1);
						
						%which strings match default options?
						[bOptKeyUserMatch,kDefOptKey]	= ismembercellstr(optKeyUserPossible,defOptKey);
						
						%the first user opt key is either:
						%	a) the first possible key that matches a default key
						%	b) the first possible key after the number of
						%	   optional arguments,
						%whichever comes earlier.
						%
						%in case of b, shift back by one key/value pair if that
						%would leave dangling values in between the last
						%optional argument and the first option key
						
						%position in user vargin of first matching option key
							kFirstOptKeyUserMatch	= kChar + 2*(find(bOptKeyUserMatch,1)-1);
							if isempty(kFirstOptKeyUserMatch)
								kFirstOptKeyUserMatch	= inf;
							end
						
						%position of first option key based on optional
						%arguments
							kFirstOptKeyFromArgument	= max(kChar,nArgument+1);
						
						if kFirstOptKeyUserMatch <= kFirstOptKeyFromArgument
						%case a above
							kFirstOptKey	= kFirstOptKeyUserMatch;
						else
						%case b above
							if kFirstOptKeyFromArgument>nUser
							%no options specified
								kFirstOptKey	= nUser+1;
							elseif ~ischar(vargin{kFirstOptKeyFromArgument})
							%we landed on an opt value rather than an opt key.
							%push one index backward.
								kFirstOptKey	= kFirstOptKeyFromArgument - 1;
							else
								kFirstOptKey	= kFirstOptKeyFromArgument;
							end
						end
						
						%separate the matching and extra options
							%first just get the actual option key/value pairs
								kOptFirst	= find(kKeyUserPossible>=kFirstOptKey,1);
								kOptKeep	= kOptFirst:numel(kKeyUserPossible);
								
								userOptKey			= optKeyUserPossible(kOptKeep);
								userOptVal			= optValUserPossible(kOptKeep);
								bOptKeyUserMatch	= bOptKeyUserMatch(kOptKeep);
								kDefOptKey			= kDefOptKey(kOptKeep);
							
							%now extract the ones that don't match
								bOptKeyUserNoMatch	= ~bOptKeyUserMatch;
								optKeyExtra			= userOptKey(bOptKeyUserNoMatch);
								optValExtra			= userOptVal(bOptKeyUserNoMatch);
								
								userOptKey(bOptKeyUserNoMatch)	= [];
								userOptVal(bOptKeyUserNoMatch)	= [];
								kDefOptKey(bOptKeyUserNoMatch)	= [];
						
						%eliminate explicitly unspecified options
							bUserUnspecified	= cellfun(@isempty,userOptVal);
							
							userOptKey(bUserUnspecified)	= [];
							userOptVal(bUserUnspecified)	= [];
							kDefOptKey(bUserUnspecified)	= [];
						
						%replace default options with user specified options
							optKey	= defOptKey;
							optVal	= defOptVal;
							
							nUserOpt	= numel(userOptKey);
							for kO=1:nUserOpt
								optVal{kDefOptKey(kO)}	= userOptVal{kO};
							end
					end
				
				%user optional arguments
					userArgument	= vargin(1:min(nArgument,kFirstOptKey-1));
			else
			%user didn't specify any arguments, just use the defaults
				if ~isempty(defOptVal)
					opt	= cell2struct(defOptVal,defOptKey);
				else
					opt	= struct;
				end
				
				opt	= optstruct(opt);
				out	= [defArgument; opt];
				
				return;
			end
	
	%parse optional arguments
		out				= defArgument;
		bOmitted		= cellfun(@isempty,userArgument);
		out(~bOmitted)	= userArgument(~bOmitted);
	%parse the options
		if ~isempty(optVal)
			opt	= cell2struct(optVal,optKey);
		else
			opt	= struct;
		end
		
		%get the extra options specified by the user
		if ~isempty(optKeyExtra)
			try
			%first assume there are no duplicate field names
				opt_extra	= cell2struct(optValExtra, optKeyExtra);
			catch me
				switch me.identifier
					case 'MATLAB:DuplicateFieldName'
					%ok, this will be a bit slower
						[optKeyExtra,kUnique]	= unique(ptKeyExtra);
						optValExtra				= optValExtra(kUnique);
						opt_extra				= cell2struct(optValExtra, optKeyExtra);
					otherwise
						disp(errID);
						rethrow(me);
				end
			end
		else
			opt_extra	= struct;
		end
		
		out{end+1}	= optstruct(opt,opt_extra); 
end
%------------------------------------------------------------------------------%
function out = DoParse
	out	= vargin;
	if nUser<nArgument
		out{nArgument}	= [];
	end
	
	for k=1:nArgument
		if isempty(out{k})
			out{k}	= varargin{k};
		end
	end
end
%------------------------------------------------------------------------------%

end
