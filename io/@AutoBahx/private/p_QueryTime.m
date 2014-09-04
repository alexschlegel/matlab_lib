function [nOverflow,tMicros] = p_QueryTime(ab,cmd,varargin)
% p_QueryTime
% 
% Description:	query times from the AutoBahx
% 
% Syntax:	[nOverflow,tMicros] = p_QueryTime(ab,cmd,[bMulti]=false,[bTimeout]=false)
% 
% In:
% 	ab			- the AutoBahx object
%	cmd			- the query command
%	[bMulti]	- true to receive multiple times
%	[bTimeout]	- true to timeout while waiting for the query system to open up
% 
% Out:
% 	nOverflow	- an nTime x 1 array of micros overflow counts
%	tMicros		- an nTime x 1 array of micros values
% 
% Updated: 2012-03-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[bMulti,bTimeout]	= ParseArgs(varargin,false,false);

[nOverflow,tMicros]	= deal([]);

%wait until we can query
	if ~p_WaitQuery(ab,bTimeout)
		return;
	end
	
	ab.serial_busy	= true;
try
	%send the request
		fwrite(ab.serial,cmd,'uchar');
	if bMulti
	%receive multiple times
		%get the number of times
			nTime	= fread(ab.serial,1,'uchar');
		%get the times
			if nTime>0
				nOverflow	= fread(ab.serial,[nTime 1],'uint16');
				
				if ~isempty(nOverflow)
					tMicros	= fread(ab.serial,[nTime 1],'uint32');
				end
			end
	else
	%receive one time
		nOverflow	= fread(ab.serial,1,'uint16');
		
		if ~isempty(nOverflow)
			tMicros	= fread(ab.serial,1,'uint32');
		end
	end
catch me
	
end
%release the serial object
	ab.serial_busy	= false;
