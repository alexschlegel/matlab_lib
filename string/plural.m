function str = plural(n,varargin)
% plural
% 
% Description:	choose between a singular and a plural string depending on
%				whether n represents a singular or plural value
% 
% Syntax:	str = plural(n,[strSingular]='',[strPlural]='s') OR
%			str = plural(n,str)
% 
% In:
% 	n				- a number
%	strSingular		- the string to return if n==1
%	strPlural		- the string to return otherwise
%	str				- a string containing substrings of the form "{<s>,<p>}",
%					  where <s> is the string to use if n==1 and <p> is the
%					  string to use otherwise
% 
% Out:
% 	str	- the singular/plural string
% 
% Example:
%	n=randi(3);disp(sprintf('There %s %d bunn%s.',plural(n,'is','are'),n,plural(n,'y','ies')));
%	n=randi(3);disp(plural(n,sprintf('There {is,are} %d bunn{y,ies}.',n)));
%  
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= numel(varargin);

switch n
	case {0,2}
		if n==2
			strSingular	= varargin{1};
			strPlural	= varargin{2};
		else
			strSingular	= '';
			strPlural	= 's';
		end
		
		str	= conditional(n==1,strSingular,strPlural);
	case 1
		str	= varargin{1};
		
		reExp	= '\{([^,]*),([^\}]*)\}';
		reRep	= conditional(n==1,'$1','$2');
		
		str	= regexprep(str,reExp,reRep);
end
