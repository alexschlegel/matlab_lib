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
% Example:
%	chance = 0.25;
%	ability = 0.66;
%	f = @(d,varargin) subject.assess.base.SimulateProbe(d,varargin{:},'ability',ability,'chance',chance);
%	n=100; d=rand(n,1); res=arrayfun(f,d);
%	a = subject.assess(f,'chance',chance,'d_hist',d,'res_hist',res);
% 
% Updated:	2016-02-06
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'method'	, 'psi'	  ...
	);
	
	cOpt	= opt2cell(opt.opt_extra);


obj	= subject.assess.(opt.method)(f,cOpt{:});
