function RGBTest(a,pin,varargin)
% Arduino.RGBTest
% 
% Description:	test an RGB LED
% 
% Syntax:	RGBTest(a,pin,[strMode]='step')
% 
% In:
%	a			- the arduino object
% 	pin			- a three element array of the R, G, and B pins
%	[strMode]	- the test mode.  one of the following:
%					'step':			step through each color in sequence
%					'pulse':		pulse through each color in sequence
%					'rainbow':		pulse through a rainbow
%					'steprainbow':	step through a rainbow
% 
% Updated: 2012-01-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strMode	= ParseArgs(varargin,'step');
strMode	= CheckInput(strMode,'mode',{'step','pulse','rainbow','steprainbow'});

rateUpdate	= 60;

speed		= 0.5;
amplitude	= 0.5;

[speedMax,amplitudeMax]	= deal(NaN);

arrayfun(@(p) a.pinMode(p,'output'),pin);

switch strMode
	case 'step'
		RunSequence(@RGBStep);
	case 'pulse'
		RunSequence(@RGBPulse);
	case 'rainbow'
		RunSequence(@RGBRainbow);
	case 'steprainbow'
		RunSequence(@RGBStepRainbow);
end


%------------------------------------------------------------------------------%
function RGBStep(t)
	persistent kRGB tLast;
	
	if isempty(tLast)
		tLast	= t-1000;
		kRGB	= 3;
	end
	
	tNext	= tLast + 1000/(log(1-speed)/log(0.5))^2;
	
	if t>=tNext
		tLast	= tNext;
		
		kRGBLast	= kRGB;
		kRGB		= mod(kRGB,3)+1;
		
		A	= MapValue(amplitude,0,1,0,255);
		
		a.analogWrite(pin(kRGB),round(A));
		a.analogWrite(pin(kRGBLast),0);
	end
end
%------------------------------------------------------------------------------%
function RGBPulse(t)
	persistent tLast tCur;
	
	if isempty(tLast)
		tCur	= 0;
		tLast	= t;
	end
	
	fSpeed	= (log(1-speed)/log(0.5))^2;
	tCur	= tCur + fSpeed*(t-tLast)/1000;
	tLast	= t;
	
	if isinf(tCur)
		tCur	= 0;
	end
	
	A	= MapValue(amplitude,0,1,0,255);
	a.analogWrite(pin(1),round(MapValue(sin(2*pi*tCur),-1,1,0,A)));
	a.analogWrite(pin(2),round(MapValue(sin(2*pi*tCur+2*pi/3),-1,1,0,A)));
	a.analogWrite(pin(3),round(MapValue(sin(2*pi*tCur+4*pi/3),-1,1,0,A)));
end
%------------------------------------------------------------------------------%
function RGBRainbow(t)
	persistent tLast tCur aSequence nSequence;
	
	if isempty(tLast)
		tCur	= 0;
		tLast	= t;
		
		aSequence	=	[%	R	O	Y	S	G	M	C	D	B	V	M	F
							1	1	1	0.5	0	0	0	0	0	0.5	1	1
							0	0.5	1	1	1	1	1	0.5	0	0	0	0
							0	0	0	0	0	0.5	1	1	1	1	1	0.5
						];
		nSequence	= size(aSequence,2);
	end
	
	fSpeed	= (log(1-speed)/log(0.5))^2;
	tCur	= tCur + fSpeed*(t-tLast)/1000;
	tLast	= t;
	
	if isinf(tCur)
		tCur	= 0;
	end
	
	kMode		= floor(mod(tCur,nSequence))+1;
	kModeNext	= mod(kMode,nSequence)+1;
	x			= mod(tCur,1);
	
	A	= MapValue(amplitude,0,1,0,255);
	for k=1:3
		a.analogWrite(pin(k),round(MapValue(x,0,1,A*aSequence(k,kMode),A*aSequence(k,kModeNext))));
	end
end
%------------------------------------------------------------------------------%
function RGBStepRainbow(t)
	persistent aSequence nSequence kSequence tLast;
	
	if isempty(tLast)
		tLast	= t-1000;
		
		aSequence	=	[%	R	O	Y	S	G	M	C	D	B	V	M	F
							1	1	1	0.5	0	0	0	0	0	0.5	1	1
							0	0.5	1	1	1	1	1	0.5	0	0	0	0
							0	0	0	0	0	0.5	1	1	1	1	1	0.5
						];
		nSequence	= size(aSequence,2);
		kSequence	= nSequence;
	end
	
	tNext	= tLast + 1000/(log(1-speed)/log(0.5))^2;
	
	if t>=tNext
		tLast	= tNext;
		
		kSequence	= mod(kSequence,nSequence)+1;
		
		A	= MapValue(amplitude,0,1,0,255);
		
		for k=1:3
			a.analogWrite(pin(k),round(A*aSequence(k,kSequence)));
		end
	end
end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function RunSequence(f)
	InitSequence;
	
	tNext	= nowms;
	while true
		UpdateSequence;
		
		f(nowms);
		
		tNext	= tNext + 1000/rateUpdate;
		
		while nowms<tNext
			WaitSecs(0.001);
		end
	end
end
%------------------------------------------------------------------------------%
function InitSequence
	InitSpeed;
	InitAmplitude;
end
%------------------------------------------------------------------------------%
function UpdateSequence
	UpdateSpeed;
	UpdateAmplitude;
end
%------------------------------------------------------------------------------%
function InitSpeed
	pScreen		= get(0,'ScreenSize');
	speedMax	= pScreen(4);
	
	set(0,'PointerLocation',pScreen(3:4)/2);
end
%------------------------------------------------------------------------------%
function UpdateSpeed
	pMouse	= get(0,'PointerLocation');
	speed	= MapValue(pMouse(2),0,speedMax,0,1);
end
%------------------------------------------------------------------------------%
function InitAmplitude
	pScreen			= get(0,'ScreenSize');
	amplitudeMax	= pScreen(3);
	
	set(0,'PointerLocation',pScreen(3:4)/2);
end
%------------------------------------------------------------------------------%
function UpdateAmplitude
	pMouse		= get(0,'PointerLocation');
	amplitude	= MapValue(pMouse(1),0,amplitudeMax,0,1);
end
%------------------------------------------------------------------------------%

end
