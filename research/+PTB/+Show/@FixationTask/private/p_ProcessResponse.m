function [bResponse,bAbort,tResponse] = p_ProcessResponse(ft)
% p_ProcessResponse
% 
% Description:	process the fixation task response.  only allow one "response"
%				per period during which the response is actually true.
% 
% Syntax:	[bResponse,bAbort,tResponse] = p_ProcessResponse(ft)
%
% In:
%	ft	- the FixationTask object
%
% Out:
%	bResponse	- true if a new response was registered
%	bAbort		- true if the fixation task should abort
%	tReponse	- the time of the response
% 
% Updated: 2012-01-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%get the actual response state
	[bResponse,bAbort,tResponse]	= PTBIFO.fixation_task.fRespond();
	tResponse						= PTB.Now;%weird RTs otherwise
%do we need to make sure we don't have multiple responses?
	if PTBIFO.fixation_task.response_state
		if ~bResponse
			PTBIFO.fixation_task.response_state	= false;
		else
			bResponse	= false;
		end
	elseif bResponse
		PTBIFO.fixation_task.response_state	= true;
	end

if bResponse
	PTBIFO.fixation_task.tResponse	= [PTBIFO.fixation_task.tResponse; tResponse];
	
	if PTBIFO.fixation_task.stage~=0
		tReaction	= tResponse - PTBIFO.fixation_task.tStart;
		strReaction	= [' (' num2str(round(tReaction)) 'ms)'];
	else
		strReaction	= '';
	end
	
	ft.AddLog(['response' strReaction],tResponse);
end
