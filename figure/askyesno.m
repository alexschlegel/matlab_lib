function b = askyesno(strPrompt,varargin)
% askyesno
% 
% Description:	present a prompt asking the user a yes or no question and return
%				a boolean representing the response
% 
% Syntax:	b = askyesno(strPrompt,<options>)
% 
% In:
% 	strPrompt	- the prompt to present the user
%	<options>:
%		dialog:		(true) true to present the prompt in a dialog box, false to
%					present it in the command window
%		title:		(<none>) the dialog box title
%		default:	(true) a boolean specifying the default choice
% 
% Out:
% 	b	- true if the user answered yes, false otherwise
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'dialog'	, true	, ...
		'title'		, []	, ...
		'default'	, true	  ...
		);

strDefault	= conditional(opt.default,'yes','no');

res	= ask(strPrompt,...
		'dialog'	, opt.dialog	, ...
		'title'		, opt.title		, ...
		'choice'	, {'yes','no'}	, ...
		'default'	, strDefault	  ...
		);

b	= isequal(res,'yes');
