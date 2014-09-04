function [str,s] = textgen(x,n,varargin)
% textgen
% 
% Description:	generate random text in which substrings occur with the same
%				frequency as substrings in a corpus
% 
% Syntax:	[str,s] = textgen(x,n,[nPerBlock]=3,[strStart]=<beginning>)
% 
% In:
% 	x			- either a corpus string or the s struct returned from a
%				  previous call to textgen
%	n			- the length of the text to generate
%	[nPerBlock]	- the length of blocks to use in the frequency calculations
% 
% Out:
% 	str	- the generated text
%	s	- a struct of information that can be used to speed up subsequent calls
%		  to textgen
% 
% Updated: 2012-10-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nPerBlock,strStart]	= ParseArgs(varargin,3,[]);

%generate s
	if ischar(x)
		%add the beginning to the end
			x(end+1:end+nPerBlock-1)	= x(1:nPerBlock-1);
			
		nX	= numel(x);
		
		%get the (nBlock-1)-length substrings
			%status('constructing substrings');
			
			strBlock	= [];
			
			for kStart=1:nPerBlock
				kEnd	= nPerBlock*floor((nX-kStart+1)/nPerBlock) + kStart - 1;
				
				strBlock	= [strBlock; reshape(x(kStart:kEnd),nPerBlock,[])'];
			end
			
			nBlock	= size(strBlock,1);
			
		%get the unique strings and their frequency
			%status('finding unique substrings');
			[strBlockU,kFrom,kTo]	= unique(strBlock,'rows');
			nBlockU					= size(strBlockU,1);
			cBlockU					= mat2cell(strBlockU,ones(nBlockU,1),nPerBlock);
		%get the frequency of each unique block
			%status('calculating substring frequencies');
			
			fBlockU	= hist(kTo,1:nBlockU);
		
		s.block	= cBlockU;
		s.freq	= fBlockU;
		
		%order from frequent to infrequent
			[s.freq,kSort]	= sort(s.freq,'descend');
			s.block			= s.block(kSort);
		
		s.sub	= cell2mat(s.block);
		s.sub	= s.sub(:,1:end-1);
		
		s.start	= x(1:nPerBlock);
	else
		s	= x;
		
		if isempty(s.block)
			str	= '';
			return;
		else
			nPerBlock	= size(s.block{1},2);
		end
	end

%generate the string
	%status('generating the string');
	
	str	= char(zeros(1,n));
	
	%get the start of the string
		if isempty(strStart)
			%strStart	= distpick(s.block,s.freq);
			strStart	= s.start;
		end
		nStart	= numel(strStart);
		
		str(1:nStart)	= strStart;
	%now pick the rest
		nJoin	= nPerBlock-1;
		nBlock	= size(s.sub,1);
		
		for kAdd=nStart+1:n
			%find all blocks that begin with the end of the string
				strEnd	= str(kAdd-nJoin:kAdd-1);
				
				b	= all(s.sub==repmat(strEnd,[nBlock 1]),2);
			%pick randomly from one of these blocks
				strAdd	= distpick(s.block(b),s.freq(b));
			%add it
				str(kAdd)	= strAdd(end);
		end
