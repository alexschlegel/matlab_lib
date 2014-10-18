function opt = optreplace(opt,varargin)
% optreplace
% 
% Description:	replace options in a varargin cell or opt struct
% 
% Syntax:	opt = optreplace(opt[,opt1,opt1def,...,optM,optMdef])
% 
% In:
% 	opt			- a parse opt struct or a varargin cell
% 	[optJ]		- the name of the Jth option to replace
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
		bReshape	= size(opt,1)>1;
		opt			= reshape(opt,1,[]);
		
		cOptExist		= opt(1:2:end);
		cOptValExist	= opt(2:2:end);
		
		[bOptReplace,kOptReplace]				= ismember(cOpt,cOptExist);
		cOptValExist(kOptReplace(bOptReplace))	= cOptVal(bOptReplace);
		
		bOptAdd		= ~bOptReplace;
		cOptAdd		= reshape(cOpt(bOptAdd),1,[]);
		cOptValAdd	= reshape(cOptVal(bOptAdd),1,[]);
		
		cOpt	= [cOptExist cOptAdd];
		cOptVal	= [cOptValExist cOptValAdd];
		
		opt	= reshape([cOpt; cOptVal],1,[]);
		
		if bReshape
			opt	= reshape(opt,[],1);
		end
	case 'struct'
		nReplace	= numel(cOpt);
		
		for kR=1:nReplace
			opt.(cOpt{kR})	= cOptVal{kR};
		end
	otherwise
		error('Invalid opt argument');
end
