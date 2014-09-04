function Set(inp,strButton,butGood,varargin)
% PTB.Device.Input.Set
% 
% Description:	set the state indices associated with a named button
% 
% Syntax:	inp.Set(strButton,butGood,[butBad]=<none>,[bReplace]=true)
% 
% In:
%	strButton	- the name of the button, must be field name compatible
%	butGood		- an button name/state index or nested cell of such defining the
%				  button.  Nx1 cells indicate buttons combinations all of whom
%				  must be down/pressed for a test function to return true (i.e.
%				  AND). 1xN cells indicate buttons any of whom may be
%				  down/pressed for a test function to return true (i.e. OR).  see
%				  examples for clarification.
%	[butBad]	- the same as butGood, but indicating button combinations that
%				  will result in an error indication if down when strButton is
%				  tested.  bad button combinations that are subsets of
%				  good button combinations will be ignored.
%	[bReplace]	- true to replace existing buttons
%
% Examples:
%	'response' becomes another name for the button 'left':
%		inp.Set('response','left');
%	'LandR' is down only if both 'left' and 'right' are down:
%		inp.Set('LandR',{'left';'right'});
%	'LorR' is down if either 'left' or 'right' are down:
%		inp.Set('LorR',{'left','right'});
%	'LnotRU' returns true if 'left' is down, unless 'right' or 'up' are also
%	down in which case it indicates an error:
%		inp.Set('LnotR','left',{'right','up'});
%	'continue' is down if either 'left' and 'right' or 'enter' are down:
%		inp.Set('continue',{{'left';'right'},{'enter'}}
%	'silly' is down if one of 'LorR' or 'up' is down along with either 'down'
%	or both 'A' and 'B':
%		inp.Set('silly',{{'LorR','up'};{'down',{'A';'B'}}});
%	'leftx' is down only if 'left' is down and no others:
%		inp.Set('leftx','left','all');
%
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

[butBad,bReplace]	= ParseArgs(varargin,{},true);

if bReplace || ~isfield(PTBIFO.input.(inp.type).button,strButton)
	p_Map(inp,strButton,butGood,butBad);
end
