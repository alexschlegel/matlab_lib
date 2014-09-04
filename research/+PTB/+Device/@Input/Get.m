function [kGood,kBad] = Get(inp,strButton)
% PTB.Device.Input.Get
% 
% Description:	get the state indices of a named button
% 
% Syntax:	[kGood,kBad] = inp.Get(strButton)
% 
% In:
%	strButton	- the name of the button or a state index
%
% Out:
%	kGood	- a 1xN cell of []x1 arrays of button combinations defining the set.
%			  all state indices of any one of the arrays must be true for the
%			  button to be considered "down"
%	kBad	- the same as kGood but for bad state indices. all of any one of
%			  the arrays must be down for an error to be indicated by a test
%			  function
%
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if ischar(strButton)
	if isfield(PTBIFO.input.(inp.type).button,strButton)
		kGood	= PTBIFO.input.(inp.type).button.(strButton).good;
		kBad	= PTBIFO.input.(inp.type).button.(strButton).bad;
	else
		kGood	= {};
		kBad	= {};
	end
elseif ~isempty(strButton) && all(isnumeric(strButton)) && all(isint(strButton))
	kGood	= num2cell(strButton);
	kBad	= {};
else
	kGood	= {};
	kBad	= {};
end
