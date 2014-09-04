function [sNew,tNew,sHold,nHold] = SignalStep(sCur,tCur,nMax,sOld,tOld,sHold,nHold)
% SignalStep
% 
% Description:	keep a running record of a signal, limiting the signal length
% 
% Syntax:	[sNew,tNew,sHold,nHold] = SignalStep(sCur,tCur,nMax,sOld,tOld,sHold,nHold)
% 
% In:
%	sCur	- the current signal measurement
%	tCur	- the time at which the current signal measurement was made
%	nMax	- the maximum length of the signal
% 	sOld	- the sNew from the last call to SignalStep. pass an empty array if
%			  this is the first call.
%	tOld	- the tNew from the last call to SignalStep
%	sHold	- the sHold from the last call to SignalStep
%	nHold	- the nHold from the last call to SignalStep
% 
% Out:
% 	sNew	- an Nx1 array of the recorded signal
%	tNew	- an Nx1 array of the time associated with each signal measurement
%	sHold	- the current running sum of signal values
%	nHold	- the current number of measurement in the running sum
% 
% Updated: 2011-03-08
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if numel(sOld)<nMax
%just add data points until we reach the maximum signal length
	sNew	= [sOld; sCur];
	tNew	= [tOld; tCur];
	sHold	= 0;
	nHold	= 0;
else
%interpolate the old signal
	%add the current value to the running sum
		sHold	= sHold + sCur;
		nHold	= nHold + 1;
	
	%time range of the current signal
		tRange	= tOld(end) - tOld(1);
	%time allotted to each sample
		tPer	= tRange/nMax;
	%time at which the next sample should be incorporated
		tNext	= tOld(end) + tPer;
	
	if tCur>=tNext
	%incorporate the running sample
		kNew	= GetInterval(1,nMax+1,nMax)';
		sNew	= interp1([sOld; sHold/nHold],kNew,'linear');
		tNew	= GetInterval(tOld(1),tCur,nMax)';
		
		sNew(1)	= ((nMax-1)*sNew(1) + sNew(2))/nMax;
		
		sHold	= 0;
		nHold	= 0;
	else
	%don't incorporate yet
		sNew	= sOld;
		tNew	= tOld;
	end
end
