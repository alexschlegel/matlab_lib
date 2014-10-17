function [ip,strInterface] = getip(varargin)
% getip
% 
% Description:	get this computer's IP address
% 
% Syntax:	[ip,strInterface] = getip(<options>)
% 
% In:
% 	<options>:
%		interface:	('defaul't) the interface whose IP address should be
%					retrieved (hint: see ifconfig). if 'external', queries the
%					computer's IP address from ipecho.net. this can also be a
%					cell of strings to try multiple interfaces, returning the IP
%					address of the first one that works.  can also be one of the
%					following presets:
%						'default':	{'external', 'eth0', 'wlan0', 'lo'}
%						'inbound':	{'wlan0', 'eth0', 'external', 'lo'}
%		timeout:	(10) the number of seconds to wait for a response from
%					ipecho.net before timing out
% 
% Out:
% 	ip				- a string representing the requested IP address
%	strInterface	- the interface associated with the returned address
% 
% Updated: 2014-01-19
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'interface'	, 'default'	, ...
		'timeout'	, 10		  ...
		);

if isa(opt.interface,'char')
	switch opt.interface
		case 'default'
			opt.interface	= {'external', 'eth0', 'wlan0', 'lo'};
		case 'inbound'
			opt.interface	= {'wlan0', 'eth0', 'external', 'lo'};
		otherwise
			%do nothing to it
	end
end

cInterface	= ForceCell(opt.interface);
nInterface	= numel(cInterface);

reIP	= '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$';

ip	= [];
for kI=1:nInterface
	strInterface	= cInterface{kI};
	
	me	= [];
	try
		switch strInterface
			case 'external'
				ip	= urlread('http://ipecho.net/plain', 'Timeout', opt.timeout);
				
				if isempty(regexp(ip, reIP))
					ip	= [];
					error('ipecho.net returned garbage.');
				end
			otherwise
				if isunix
					%parse the address from ifconfig
					strCommand	= ['ifconfig ' strInterface ' | grep ''inet addr:'' | cut -d: -f2 | awk ''{ print $1 }'''];
					[ec,out]	= system(strCommand);
					out			= StringTrim(out);
					
					if ~ec && ~isempty(regexp(out, reIP))
						ip	= out;
					else
						error('The specified interface has no IP address.');
					end
				else
					error('This is only implemented on unix systems.');
				end
		end
	catch me
		%oh well
	end
	
	if ~isempty(ip)
		%it worked!
		return;
	end
end

%nothing worked!
	if ~isempty(me)
		rethrow(me);
	else
		error('Could not determine the requested IP address.');
	end
