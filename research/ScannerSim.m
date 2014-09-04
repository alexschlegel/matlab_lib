function ScannerSim(TR,varargin)
% ScannerSim
% 
% Description:	simulate scanner trigger pulses and button box responses.  For
%				this to work a pair of COM ports must be set up to loop back
%				onto each other (e.g. see com0com)
% 
% Syntax:	ScannerSim(TR,[kPortOut]=3,[cKey]={'F9','F10','F11','F12'})
% 
% In:
%	TR			- the length of each TR, in seconds
% 	[kPortOut]	- the COM port to which to send signals
%	[cKey]		- the keyboard keys to associate with buttons 1, 2, 3, and 4 on
%				  the scanner button box
% 
% Updated: 2012-04-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kPortOut,cKey]	= ParseArgs(varargin,3,{'F9','F10','F11','F12'});
nKey			= numel(cKey);

kBB			= 49 + (0:nKey-1);
kTrigger	= 53;

if nargin==0
	error('First argument must be TR length, in seconds');
end

%keys to start/stop/end simulation
	strKeyGo	= 'F8';
	strKeyEnd	= 'F7';
%object to check for keyboard presses
	kb	= Gamepad('keyboard');
%open the output port
	strPort	= ['COM' num2str(kPortOut)];
	hPort	= IOPort('OpenSerialPort',strPort,'BaudRate=115200');
	IOPort('Purge',hPort);
%disable MATLAB keyboard output
	ListenChar(2);

%display some info
	strKey2BB	= join(arrayfun(@(k) [num2str(k) ':' upper(cKey{k})],1:nKey,'UniformOutput',false),', ');
	
	disp('SCANNER SIMULATION STARTED');
	disp(['---Key to button box mapping: ' strKey2BB]);
	disp(['---Press ' strKeyGo ' to start/stop sending scanner triggers.']);
	disp(['---Press ' strKeyEnd ' to end the stimulation.']);
	
%loop until we get an abort signal
	bAbort	= false;
	bGo		= false;
	while ~bAbort
		CheckTrigger;
		CheckKeys;
		
		WaitSecs(0.005);
	end

%enable MATLAB keyboard output
	ListenChar(1);
%close the output port
	IOPort('Close',hPort);

disp('SCANNER SIMULATION ENDED');

%------------------------------------------------------------------------------%
function CheckKeys
	if kb.Pressed(strKeyEnd)
		bAbort	= true;
		return;
	end
	if kb.Pressed(strKeyGo)
		bGo	= ~bGo;
	end
	
	for kK=1:nKey
		if kb.Pressed(cKey{kK})
		%send a serial signal
			SendSerial(kBB(kK));
		end
	end
end
%------------------------------------------------------------------------------%
function CheckTrigger
	persistent bGoLast tNext;
	
	tNow	= GetSecs;
	
	if isempty(bGoLast)
		bGoLast	= false;
	end
	
	if ~bGoLast & bGo
		status('scanner triggers started');
		tNext	= tNow;
	elseif bGoLast & ~bGo
		status('scanner triggers stopped.');
	end
	
	if bGo && tNow>=tNext
		SendSerial(kTrigger);
		
		tNext	= tNext + TR;
	end
	
	bGoLast	= bGo;
end
%------------------------------------------------------------------------------%
function SendSerial(k)
	IOPort('Write',hPort,uint8(k),0);
	
	status(['sent ' num2str(k) ' to ' strPort]);
end
%------------------------------------------------------------------------------%

end