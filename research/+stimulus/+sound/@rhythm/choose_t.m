function t = choose_t(obj,n,dur,strPattern)
% stimulus.sound.rhythm.choose_t
% 
% Description:	choose the beat times, given the specified pattern
% 
% Syntax: t = obj.choose_t(n,dur,strPattern)
% 
% In:
%	n			- the number of beats
%	dur			- the stimulus duration, in seconds
%	strPattern	- the pattern type (see constructor)
%
% Out:
%	t	- an array of beat times
% 
% Updated:	2015-11-18
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch strPattern
	case 'random'
		tChoose	= GetInterval(0,dur-dur/n,2*n)';
		tChoose	= tChoose(2:end);
		
		t	= [0; randFrom(tChoose,[n-1 1],'seed',false)];
	case 'uniform'
		t	= (0:dur/n:dur-dur/n)';
	otherwise
		error('invalid pattern');
end
