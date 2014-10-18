function [str,aux] = StringWrap(str,n,varargin)
% StringWrap
% 
% Description:	word wrap a string
% 
% Syntax:	[str,[aux]] = StringWrap(str,n,<options>)
% 
% In:
% 	str	- the string
%	n	- the maximum number of characters in each line
%	<options>:
%		linebreak:	(<lf>) the line break string
%		aux:		(<none>) an auxillary array to wrap using the breaks from
%					str
%		auxfill:	(NaN) what to assign aux elements corresponding to the line
%					breaks in the string.  can also be one of the following
%					strings:
%						'pre':	fill with the last aux element before the line
%								break
%						'post':	fill with the first aux element after the line
%								break
% 
% Out:
% 	str		- the word wrapped string
%	[aux]	- the wrapped auxillary array
% 
% Updated: 2011-09-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'linebreak'	, char(10)	, ...
		'aux'		, []		, ...
		'auxfill'	, NaN		  ...
		);

bAux	= ~isempty(opt.aux);
aux		= [];

reLineBreak	= StringForRegExp(opt.linebreak);
reWordBreak	= ['\>(([ ])|(' reLineBreak '))+'];

nLB	= numel(opt.linebreak);

if ~isempty(regexp(str,reLineBreak))
%wrap each non-broken substring
	if bAux
		cOpt	= opt2cell(rmfield(opt,'aux'));
		
		[cStr,cAux]	= split(str,reLineBreak,'withdelim',true,'aux',opt.aux);
		bLastDelim	= ~isempty(cStr) && numel(cStr{end})>=nLB && ~isempty(regexp(cStr{end}(end-nLB+1:end),reLineBreak));
		cAuxEnd		= cellfun(@(a) a(end-nLB+1:end),cAux,'UniformOutput',false);
		[cStr,cAux]	= split(str,reLineBreak,'aux',opt.aux);
		[cStr,cAux]	= cellfun(@(s,a) StringWrap(s,n,cOpt{:},'aux',a),cStr,cAux,'UniformOutput',false);
		
		str	= join(cStr,opt.linebreak);
		
		if bLastDelim
			cAux			= cellfun(@(a,ae) append(a,ae),cAux,cAuxEnd,'UniformOutput',false);
		else
			cAux(1:end-1)	= cellfun(@(a,ae) append(a,ae),cAux(1:end-1),cAuxEnd(1:end-1),'UniformOutput',false);
		end
		aux		= append(cAux{:});
	else
		cOpt	= opt2cell(opt);
		cStr	= split(str,reLineBreak);
		cStr	= cellfun(@(s) StringWrap(s,n,cOpt{:}),cStr,'UniformOutput',false);
		str		= join(cStr,opt.linebreak);
	end
else
	%split by words
		if bAux
			[cWord,cAux]	= split(str,reWordBreak,'withdelim',true,'aux',opt.aux);
		else
			cWord	= split(str,reWordBreak,'withdelim',true);
		end
		nWord			= numel(cWord);
	%get the length of each word block
		lWord	= cellfun(@numel,cWord);
	%split into groups no more than n characters wide
		lLine	= 0;
		str		= '';
		for kW=1:nWord
			if lLine~=0 && lLine+lWord(kW)>n
				str		= [str opt.linebreak cWord{kW}];
				
				if bAux
					aux	= [aux AuxFill cAux{kW}];
				end
				
				lLine	= lWord(kW);
			else
				str		= [str cWord{kW}];
				
				if bAux
					aux	= [aux cAux{kW}];
				end
				
				kLB	= regexp(cWord{kW},reLineBreak);
				if ~isempty(kLB)
					lLine	= kLB(end)+nLB-1;
				else
					lLine	= lLine + lWord(kW);
				end
			end
		end
end

%------------------------------------------------------------------------------%
function strFill = AuxFill()
% fill the aux array with entries corresponding to the line breaks in the string
	if isequal(opt.auxfill,'pre')
		strFill	= repmat(aux(end),[1 nLB]);
	elseif isequal(opt.auxfill,'post')
		strFill	= repmat(cAux{kW}(1),[1 nLB]);
	else
		strFill	= repmat(opt.auxfill,[1 nLB]);
	end
end
%------------------------------------------------------------------------------%

end
