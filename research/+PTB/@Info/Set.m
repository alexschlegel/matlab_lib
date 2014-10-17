function Set(ifo,strDomain,cPath,x,varargin)
% PTB.Info.Set
% 
% Description:	set an info value
% 
% Syntax:	ifo.Set(strDomain,cPath,x,<options>)
% 
% In:
%	strDomain	- the domain of the info (e.g. 'subject')
%	cPath		- the path to the info, either a string or cell of strings
%	x			- the new value
%	<options>:
%		replace:	(true) true to replace existing info
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

opt	= ParseArgs(varargin,...
		'replace'	, true	  ...
		);

cPath	= [strDomain; reshape(ForceCell(cPath),[],1)];

if opt.replace || isempty(GetFieldPath(PTBIFO,cPath{:}))
	PTBIFO	= SetFieldPath(PTBIFO,cPath{:},x);
end
