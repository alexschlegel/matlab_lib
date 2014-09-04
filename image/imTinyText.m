function im = imTinyText(str,w)
% IMTINYTEXT
%
% Description:	creates a bitmap of a string using 5px X 5px characters.  Valid
%				characters are:
%				ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?!"':;@#$%^&*()-_+=~/\<>{}[] 1234567890
%
% Syntax:	im = imTinyText(str,[w]=infinite)
%
% In:
%	str	- a string consisting of valid charactes
%	[w]	- optional, the width in characters of the image to return
%
% Out:
%	im	- the small letter image
%
% Note: if called without arguments, returns a string of the valid characters
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPathLetters	= 'tinytext.bmp';
strValid		= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?!"'':;@#$%^&*()-_+=~/\<>{}[] 1234567890';

if nargin==0
	im	= strValid;
	return;
end

imChar			= imread(strPathLetters);
imChar			= imChar(:,:,1);

str	= upper(str);
n	= numel(str);
im	= zeros(6,n*6);
for k=1:n
	kChar	= find(strValid==str(k));
	if isempty(kChar)
		error(['''' str(k) ''' is an invalid character at position ' num2str(k) '.']);
	else
		im(:,(k-1)*6+(1:6))	= imChar(:,(kChar-1)*6+(1:6));
	end
end

if exist('w','var') && ~isempty(w)
	h		= ceil(n/w);
	imold	= im;
	im		= ones(h*6,w*6);
	
	for k=1:h-1
		im((k-1)*6+(1:6),:)	= imold(:,(k-1)*w*6+(1:w*6));
	end
	if h~=(n/w)
		im((h-1)*6+(1:6),1:(n - (h-1)*w)*6)	= imold(:,(h-1)*w*6+1:end);
	end
end
