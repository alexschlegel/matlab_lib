function t = ReadTemplate(strPathTemplate,varargin)
% ReadTemplate
% 
% Description:	read and optionally parse a template file
% 
% Syntax:	t = ReadTemplate(strPathTemplate,<options>)
% 
% In:
% 	strPathTemplate	- the path to a template file
%	<options>:
%		subtemplate:	(false) true if the template consists of subtemplates
% 
% Out:
% 	t	- if 'subtemplate' is false, the contents of the template file.
%		  otherwise a mapping from each subtemplate name to the subtemplate.
%		  each subtemplate starts with a line of the form "<!--...<name>--...>",
%		  e.g. "<!---blah----------->" and ends with the beginning of the next
%		  subtemplate.
% 
% Updated: 2011-11-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'subtemplate'	, false	  ...
		);

if ~opt.subtemplate
	t	= fget(strPathTemplate);
else
	strTemplate	= fget(strPathTemplate);
	
	reDelim	= '[\r\n]*<![-]*(?<name>[A-Za-z0-9_]+)[-]*>[\r\n]*';
	
	cTemplate	= split(strTemplate,reDelim,'withdelim',true);
	
	%template name is in the last line of the 1:end-1 elements
		cTemplateName	= cellfun(@(s) GetFieldPath(regexp(s,reDelim,'names'),'name'),cTemplate(1:end-1),'UniformOutput',false);
	%remove the template delimiters
		cTemplateContent	= [cellfun(@(s) regexprep(s,reDelim,''),cTemplate(2:end-1),'UniformOutput',false); cTemplate(end)];
	
	%construct the mapping
		t	= mapping(cTemplateName,cTemplateContent);
end
