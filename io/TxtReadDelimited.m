function str = TxtReadDelimited(strPath,chr,chrRemove)
% TxtReadDelimited
% 
% Description:	reads a string from a text file into a cell, separating
%				by delimiting character and line breaks
% 
% Syntax:	str = TxtReadDelimited([strPath]=<prompts>,chr,[chrRemove]='')
%
% In:
%	[strPath]	- the path from which to read
%	chr			- the delimiting character
%	[chrRemove]	- removes the specified character if it occurs at the beginning
%				  or end of the string
% 
% Out:
%	str	- an MxN cell of strings, one row per line, one column per field
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ~exist('strPath','var') || isempty(strPath)
	strPath	= PromptFileGet;
	if isequal(strPath,0)
		str	= '';
		return;
	end
end

strR	= TxtRead(strPath);
nL		= numel(strR);

str	= cell(nL,1);
for k=1:nL
	kD	= findstr(strR{k},chr);
	nD	= numel(kD)+1;
	
	kD	= [0 kD numel(strR{k})+1];
	
	str{k,nD}	= [];
	for k1=1:nD
		str{k,k1}	= strR{k}(kD(k1)+1:kD(k1+1)-1);
	end
end

if exist('chrRemove','var') && ~isempty(chrRemove)
	for k=1:nL
		for k1=1:nD
			if numel(str{k,k1})>0
				if str{k,k1}(1)==chrRemove
					str{k,k1}	= str{k,k1}(2:end);
				end
				if str{k,k1}(end)==chrRemove
					str{k,k1}		= str{k,k1}(1:end-1);
				end
			end
		end
	end
end
