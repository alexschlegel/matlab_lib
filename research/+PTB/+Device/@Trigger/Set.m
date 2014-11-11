function Set(tr,strName,vTrigger,varargin)
% PTB.Trigger.Set
% 
% Description:	set a named trigger code 
% 
% Syntax:	tr.Set(strName,vTrigger,<options>)
% 
% In:
%	strName		- the name of the trigger code
%	vTrigger	- the value of the trigger (number for 'numeric', array of bit
%				  indices for 'bit' mode)  
%	<options>: 
%		replace:	(true) true to replace existing trigger code
%
% Updated: 2012-03-28
% Copyright 2012 Scottie Alexander (scottiealexander11@gmail.com).  This 
% work is licensed under a Creative Commons Attribution-NonCommercial-
% ShareAlike 3.0 Unported License.
opt	= ParseArgs(varargin,...
		'replace'	, true	  ...
		);

% format the trigger value
switch tr.parent.Info.Get(tr.type,'mode')
	case 'numeric'
		vTrigger	= find(bitget(vTrigger,1:16));
	case 'bit'
		%nothing to do
end

% add the set to the info struct
tr.parent.Info.Set(tr.type,{'code',strName},vTrigger,'replace',opt.replace);
