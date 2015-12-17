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
% Updated: 2015-12-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cKey	= varargin(1:2:end);
cVal	= varargin(2:2:end);
nKey	= numel(cKey);

switch class(opt)
	case 'cell'
		%existing options
			cKeyOld	= reshape(opt(1:2:end),1,[]);
			cValOld	= reshape(opt(2:2:end),1,[]);
		
		%which of the new options already exist?
			[bExist,kExist]	= ismember(cKey,cKeyOld);
		
		%options that don't already exist
			cKeyNew	= reshape(cKey(~bExist),1,[]);
			cValNew	= reshape(cVal(~bExist),1,[]);
		
		%check if the existing options are empty
			cValExist	= cVal(bExist);
			kExist		= kExist(bExist);
			nExist		= numel(kExist);
			for kE=1:nExist
				if isempty(cValOld{kExist(kE)})
					cValOld{kExist(kE)}	= cValExist{kE};
				end
			end
		
		cSize	= switch2(size(opt,1),1,{1,[]},{[],1});
		opt		= reshape([cKeyOld cKeyNew; cValOld cValNew],cSize{:});
	case 'struct'
		for kK=1:nKey
			strKey	= cKey{kK};
			
			if ~isfield(opt,strKey) || isempty(opt.(strKey))
				opt.(strKey)	= cVal{kK};
			end
		end
		
		if isfield(opt,'opt_extra')
			opt_extra	= opt.opt_extra;
		else
			opt_extra	= struct;
		end
		opt	= optstruct(opt,opt_extra);
	otherwise
		error('Invalid opt argument');
end
