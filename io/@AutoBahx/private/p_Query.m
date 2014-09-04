function x = p_Query(ab,s,p,cmd,varargin)
% p_Query
% 
% Description:	query data from the AutoBahx
% 
% Syntax:	x = p_Query(ab,s,p,cmd,[ext]=[],[bTimeout]=false)
% 
% In:
% 	ab			- the AutoBahx object
%	s			- the size of the data to receive
%	p			- the precision of the data to receive
%	cmd			- the command byte
%	[ext]		- extra command info
%	[bTimeout]	- true to timeout while waiting for the query system to open up
% 
% Out:
% 	x	- the data received
% 
% Updated: 2012-03-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[ext,bTimeout]	= ParseArgs(varargin,[],false);
nExtra			= numel(ext);

x	= [];

%wait until we can query
	if ~p_WaitQuery(ab,bTimeout)
		return;
	end
	
	ab.serial_busy	= true;
try
	%send the request
		byteSend	= [cmd reshape(ext,1,nExtra)];
			
		fwrite(ab.serial,byteSend,'uchar');
	%receive the response
		x	= fread(ab.serial,s,p);
catch me
end
%release the serial object
	ab.serial_busy	= false;
