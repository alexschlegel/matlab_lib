function [b,t] = State(bb,varargin)
% PTB.Device.Input.ButtonBox.State
% 
% Description:	get the state of the button box
% 
% Syntax:	[b,t] = bb.State([kCheck]=<all buttons>)
% 
% In:
%	[kCheck]	- an array of bytes to check for
% 
% Out:
%	b	- a 255x1 logical array indicating which buttons are down
%	t	- the time associated with the query
%
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License
global PTBIFO;

persistent kCheckDefault kKey;

if isempty(kCheckDefault)
	kCheckDefault	=	[
							bb.parent.Scanner.SCANNER_BB_BLUE
							bb.parent.Scanner.SCANNER_BB_YELLOW
							bb.parent.Scanner.SCANNER_BB_GREEN
							bb.parent.Scanner.SCANNER_BB_RED
						];
	
	if PTBIFO.input.(bb.type).alt
		kKey	=	cell2mat([
						bb.Key.Get('bb_blue')
						bb.Key.Get('bb_yellow')
						bb.Key.Get('bb_green')
						bb.Key.Get('bb_red')
					]);
	end
end

%buttons to check for
	kCheck	= ParseArgs(varargin,kCheckDefault);
%check the serial buffer
	[d,t]	= bb.parent.Serial.Check(kCheck);
%check the simulated keyboard keys
	if PTBIFO.input.(bb.type).alt && (~isfield(PTBIFO,'scanner') || ~PTBIFO.scanner.simulate)
		[b,err,t,kDown]	= bb.Key.Down('bb_any',false);
		
		bKey	= ismember(kKey,kDown);
		
		d		= [d; kCheckDefault(bKey)];
	end

b		= false(255,1);
b(d)	= true;
t		= min(t);
