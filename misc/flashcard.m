function flashcard(p,varargin)
% flashcard
% 
% Description:	display a prompt, pause, and then display other prompts
%				associated with the initial prompt
% 
% Syntax:	flashcard(p,<options>) OR
%			flashcard(strPathPrompt,<options>)
% 
% In:
%	p				- a cell of cells of prompts
%	strPathPrompt	- path to a file of prompts and answers, in one of the
%					  following formats:
%						one comma-separated set per line
%						lf/crlf separated entries, with two lf/crlfs separating
%							groups
%	<options>:
%		repeat:	(false) true to repeat prompts
%		prompt:	(0) the index of the prompt to display first.  set to 0 to
%					choose a random prompt index
% 
% Updated:	2011-01-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse arguments
	opt	= ParseArgsOpt(varargin,...
			'repeat'	, false	, ...
			'prompt'	, 0		  ...
			);
	if ischar(p)
		p	= ParsePromptFile(p);
	end

bDo	= true;
while bDo
	kP		= 1:numel(p);
	kIndex	= cellfun(@(x) 1:numel(x),p,'UniformOutput',false);
	
	while ~isempty(kP)
		%choose a set
			kkPCur	= randFrom(1:numel(kP));
			kPCur	= kP(kkPCur);
		%choose the prompt to show
			switch opt.prompt
				case 0
					kkIndexCur	= randFrom(1:numel(kIndex(kkPCur)));
					kIndexCur	= kIndex{kkPCur}(kkIndexCur);
				otherwise
					kIndexCur	= min(numel(kIndex(kkPCur)),opt.prompt);
			end
		%show the prompt
			clc;
			pCur	= p{kPCur}{kIndexCur};
			disp(pCur);
			pause
		%show the rest of the group
			pRest	= p{kPCur}([1:kIndexCur-1 kIndexCur+1:end]);
			disp(join(pRest,10));
			pause;
		%eliminate the set if needed
			switch opt.prompt
				case 0
					kIndex{kkPCur}(kkIndexCur)	= [];
					if isempty(kIndex{kkPCur})
						kP(kkPCur)		= [];
						kIndex(kkPCur)	= [];
					end
				otherwise
					kP(kkPCur)		= [];
					kIndex(kkPCur)	= [];
			end
	end
	
	bDo	= opt.repeat;
end

%------------------------------------------------------------------------------%
function p = ParsePromptFile(strPath)
	str	= StringTrim(fget(strPath));
	
	if regexp(str,'\r\n\r\n|\n\n')
	%grouped by \r\n or \n and then double that
		p	= split(str,'\r\n\r\n|\n\n');
		p	= cellfun(@(x) split(x,'\r\n|\n'),p,'UniformOutput',false);
	else
	%grouped by commas
		p	= split(str,'\r\n|\n');
		p	= cellfun(@(x) split(x,','),p,'UniformOutput',false);
	end
end
%------------------------------------------------------------------------------%

end