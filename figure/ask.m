function res = ask(strPrompt,varargin)
% ask
% 
% Description:	present either an input or a multiple choice dialog box or
%				command window prompt and return the user's answer
% 
% Syntax:	res = ask(strPrompt,<options>)
% 
% In:
% 	strPrompt	- the prompt to present the user
%	<options>:
%		dialog:		(true) true to present prompts in a dialog box, false to
%					present them in the command window
%		title:		(<none>) the dialog box title
%		nline:		(1) the number of lines if a text input prompt should be
%					shown.  can only be > 1 if 'dialog'==true
%		choice:		(<none>) a cell of up to three choices for the user to
%					choose between
%		default:	(<'' if text input, first choice if multiple choice>) the
%					default choice
% 
% Out:
% 	res	- the user's response, or [] if the user canceled.  If a text input
%		  prompt is shown, and nline is specified, lines are grouped in a cell
% 
% Notes:	if the 'choice' option is unspecified, a text input prompt will be
%			presented.
%			
%			if the default answer for the input variant is not a char array, the
%			responses are eval'ed. otherwise answers are trimmed
% 
% Updated: 2011-09-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'dialog'	, true	, ...
		'title'		, ''	, ... 
		'nline'		, []	, ...
		'choice'	, {}	, ...
		'default'	, {}	  ...
		);
bMulti		= ~isempty(opt.choice);
if isempty(opt.nline)
	opt.nline	= 1;
	bCell		= false;
else
	bCell		= true;
end

if isempty(opt.default)
	if bMulti
		opt.default	= opt.choice{1};
	else
		opt.default	= '';
	end
end

if bMulti		%multiple choice
	opt.choice	= ForceCell(opt.choice);
	nChoice		= numel(opt.choice);
	
	if opt.dialog && nChoice>3
		error('No more than three choices can be specified.');
	elseif ~ismember(opt.default,opt.choice)
		error('Default choice is not included in choice list.');
	end
	
	if opt.dialog
		res	= questdlg(strPrompt,opt.title,opt.choice{:},opt.default);
	else
		cChoice				= opt.choice;
		cMatch				= [cellfun(@lower,cChoice,'UniformOutput',false) {''}];
		kDefault			= find(ismember(opt.choice,opt.default));
		cChoice{kDefault}	= ['[' cChoice{kDefault} ']'];
		
		res	= lower(inputfix([strPrompt ' (' join(cChoice,',') '): '],'s'));
		while ~ismember(res,cMatch)
			res	= inputfix([strPrompt ' (CHOOSE FROM: ' join(opt.choice,',') '): '],'s');
		end
		if isempty(res)
			res	= opt.default;
		end
		res	= opt.choice{ismember(cellfun(@lower,opt.choice,'UniformOutput',false),lower(res))};
	end
	
	if isempty(res)
		res	= [];
	end
else	%text input
	bChar	= ischar(opt.default);
	
	if opt.dialog
		strRes	= inputdlg(strPrompt,opt.title,opt.nline,{num2str(opt.default)});
		
		if ~isempty(strRes)
			strRes	= cellstr(strRes{1});
			nLine	= numel(strRes);
			res		= cell(nLine,1);
			
			if bChar
				res	= cellfun(@strtrim,strRes,'UniformOutput',false);
			else
				res	= cellfun(@eval,strRes,'UniformOutput',false);
			end
			
			if ~bCell
				res	= res{1};
			end
		else
			res	= {};
		end
    else
        strDefault = conditional(isempty(opt.default),'',[' (default=' tostring(opt.default) ')']);
        
		if bChar
			res	= inputfix([strPrompt strDefault ': '],'s');
		else
			res	= inputfix([strPrompt strDefault ': ']);
        end
        
        if isempty(res)
            res = opt.default;
        end
	end
end

%------------------------------------------------------------------------------%
function res = inputfix(str,varargin)
	res = input(strrep(str,'\','\\'),varargin{:});
%------------------------------------------------------------------------------%
