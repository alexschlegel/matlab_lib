function x = ApplyWindow(x,funcWin)
% ApplyWindow
% 
% Description:	apply a window function to data
% 
% Syntax:	x = ApplyWindow(x,funcWin)
% 
% In:
% 	x		- an M x N array of N M-length samples
%	funcWin	- a handle to the window function.  see window.
% 
% Out:
% 	x	- x with the window applied to each sample
% 
% Updated:	2009-04-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

[m,n]	= size(x);

%get the window values
	wf	= repmat(funcWin(m),[1 n]);
%apply
	x	= x .* wf;
