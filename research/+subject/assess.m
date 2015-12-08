function obj = assess(f,varargin)
% subject.assess
% 
% Description:	wrapper for the subject.assess classes
% 
% Syntax: obj = subject.assess(f,<options>)
% 
% In:
%	f	- the assessment functions. see subject.assess.base.
%	<options>: (see also the help for the specified subject.assess method)
%		method:	('psi') the assessment method to use. must be the name of a
%				subject.assess object
% 
% Out:
%	obj	- an instance of the specified subject.assess object
% 
% Updated:	2015-12-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'method'	, 'psi'	  ...
	);
	
	cOpt	= opt2cell(opt.opt_extra);


obj	= subject.assess.(opt.method)(f,cOpt{:});
