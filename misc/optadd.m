function opt = optadd(opt,varargin)
% optadd
% 
% Description:	add options to a varargin cell or opt struct, if they aren't
%				already specified
% 
% Syntax:	opt = optadd(opt[,opt1,opt1def,...,optM,optMdef])
% 
% In:
% 	opt			- a parse opt struct or a varargin cell
% 	[optJ]		- the name of the Jth option to add
% 	[optJdef]	- the default value of the Jth option
% 
% Out:
% 	opt	- the updated opt struct/varargin cell
% 
% Updated: 2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cOpt	= varargin(1:2:end);
cOptVal	= varargin(2:2:end);

switch class(opt)
	case 'cell'
		cOptExist		= opt(1:2:end);
		cOptValExist	= opt(2:2:end);
		
		bOptAdd		= ~ismember(cOpt,cOptExist);
		cOptAdd		= reshape(cOpt(bOptAdd),1,[]);
		cOptValAdd	= reshape(cOptVal(bOptAdd),1,[]);
		
		cSize		= switch2(size(opt,1),1,{1,[]},{[],1});
		varginAdd	= reshape([cOptAdd; cOptValAdd],cSize{:});
		opt			= append(opt,varginAdd);
	case 'struct'
		cOptExist		= fieldnames(opt);
		[cOptAdd,kAdd]	= setdiff(cOpt,cOptExist);
		nAdd			= numel(kAdd);
		
		for kA=1:nAdd
			kAddCur				= kAdd(kA);
			opt.(cOpt{kAddCur})	= cOptVal{kAddCur};
		end
	otherwise
		error('Invalid opt argument');
end
