function t = XIDTestLatency(s,varargin)
% XIDTestLatency
% 
% Description:	test the back and forth communcation latency of an XID serial
%				connection
% 
% Syntax:	t = XIDTestLatency(s,<options>)
% 
% In:
% 	s	- a serial port opened with XIDOpen
%	<options>:
%		n	: (100) the number of times to test the latency
% 
% Out:
% 	t	- the average latency, in milliseconds
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'n'	, 100	  ...
		);

%initialize an array to store the latencies
	t	= zeros(opt.n,1);
%test the latency n times
	progress(opt.n);
	for k=1:opt.n
		fprintf(s,['e4' 13]);
		while s.BytesAvailable==0
		end
		dummy	= fread(s,1);
		
		fprintf(s,'X');
		while s.BytesAvailable==0
		end
		res		= fread(s,4);
		
		t(k)	= res(3) + bitshift(res(4),8);
		
		progress;
		pause(0.1)
	end

t	= mean(t);
