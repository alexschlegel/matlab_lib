function b = Write(f,x,strName,varargin)
% Group.File.Write
% 
% Description:	write data to a named file
% 
% Syntax:	b = f.Write(x,strName,<options>)
% 
% In:
%	x		- the data.  if it is a char, then a text file is written. otherwise
%			  a .mat file is written.
% 	strName	- the name of the file (previously assigned using f.Set)
%	<options>:
%		overwrite:	(false) true to overwrite existing data
%		variable:	('x') the name of the variable in the saved MATLAB file
% 
% Out:
%	b	- true if the file was successfully written
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'overwrite'	, false	, ...
		'variable'	, 'x'	  ...
		);

b	= false;

if opt.overwrite || ~f.Exists(strName)
	strPath	= f.Get(strName);
	
	if ~isempty(strPath)
		b	= CreateDirPath(PathGetDir(strPath));
		
		if b
			switch class(x)
				case 'char'
					b	= fput(x,strPath);
				otherwise
					s	= struct(opt.variable,{x});
					
					sWarning	= warning('query','all');
					warning('off','all');
					
					save(strPath,'-struct','s');
					
					arrayfun(@(s) warning(s.state,s.identifier),sWarning);
					
					b	= FileExists(strPath);
			end
		end
	end
end
