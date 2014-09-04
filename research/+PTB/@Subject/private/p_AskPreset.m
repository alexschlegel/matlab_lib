function p_AskPreset(sub,x,varargin)
% p_AskPreset
% 
% Description:	ask a preset question
% 
% Syntax:	p_AskPreset(sub,strPreset,<options>)
% 
% In:
% 	strPreset	- the name of a preset or scheme
%	<options>: (see p_Ask)
% 
% Updated: 2011-12-09
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[b,k]	= ismember(x,sub.p_preset(:,1));

if b
%we got a preset
	p_Ask(sub,sub.p_preset{k,:},varargin{:});
else
%scheme?
	[b,k]	= ismember(x,sub.p_scheme(:,1));
	
	if b
	%we got a scheme
		cellfun(@(x) p_AskPreset(sub,x,varargin{:}),sub.p_scheme{k,2});
	else
		error(['"' tostring(x) '" is not a recognized subject prompt preset or scheme.']);
	end
end
