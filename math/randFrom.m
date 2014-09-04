function [r,k] = randFrom(x,varargin)
% randFrom
% 
% Description:	choose random elements of an array
% 
% Syntax:	[r,k] = randFrom(x,[s]=1,<options>)
% 
% In:
% 	x	- an array
%	[s]	- the number of elements in or size of the return array
%	<options>:
%		unique:		(true) true to include each element of x no more than once
%		exclude:	(<none>) an array of values to exclude from x
%		repeat:		(true) true to allow consecutive repeats
% 
% Out:
% 	r	- an array of random elements from x
%	k	- the indices of the elements of r in x
% 
% Updated:	2010-10-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[s,opt]	= ParseArgsOpt(varargin,1,...
			'unique'	, true	, ...
			'exclude'	, []	, ...
			'repeat'	, true	  ...
			);

if numel(s)==1
	s	= [s 1];
end

if ~isempty(opt.exclude)
	if iscell(x)
		[x,kInclude]	= SetDiffCell(x,opt.exclude);
	else
		[x,kInclude]	= setdiff(x,opt.exclude);
	end
else
	kInclude	= reshape(1:numel(x),size(x));
end

nX	= numel(x);
nR	= prod(s);

%get the indices of the elements to return
	if opt.unique
		if nX<nR
			error('No unique matrices are possible with the given values.'); 
		end
		
		k	= randomize(1:nX);
		k	= k(1:nR);
		k	= reshape(k,s);
	elseif opt.repeat
		k	= round(randBetween(0.5,nX+0.5,s));
	else
		if nX<2 && nR>1
			error('No non-repeat matrices are possible with the given values.');
		end
		
		k	= [];
		while numel(k)<nR
			k		= [k; round(randBetween(1,nX,[2*nR 1]))];
			d		= diff(k);
			k(d==0)	= [];
		end
		
		k	= reshape(k(1:nR),s);
	end
%return the elements
	r	= reshape(x(k),s);
	k	= kInclude(k);
