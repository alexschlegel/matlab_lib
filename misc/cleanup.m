function cleanup(varargin)
% CLEANUP
% 
% Description:	clean up the variables in the calling workspace
% 
% Syntax:	cleanup([opt]='')
% 
% In:
% 	[opt]	- optional:
%				'store':	further calls to cleanup will clear all but the
%							current set of variables
%				'default':	sets the current set of variables as the default
%							cleanup state
%				'reset':	reset the cleanup state to its default
% 
% Updated: 2014-02-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global storeUser;
global storeDefault;

opt	= ParseArgs(varargin,'');

if isempty(storeDefault)
	storeDefault	= {};
end

switch lower(opt)
	case 'store'
		vars	= evalin('base','who');
		for k=1:numel(vars)
			vars{k}	= ['^' vars{k} '$'];
		end
		storeUser	= vars;
	case 'default'
		vars	= evalin('base','who');
		for k=1:numel(vars)
			vars{k}	= ['^' vars{k} '$'];
		end
		storeDefault	= vars;
	case 'reset'
		storeUser	= storeDefault;
	otherwise
		if isempty(storeUser)
			storeUser = storeDefault;
		end
		keep(storeUser{:});
end
