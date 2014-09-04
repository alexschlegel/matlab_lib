function evt = eventMap(evt,m)
% eventMap
% 
% Description:	rename and purge a set of events 
% 
% Syntax:	evt = eventMap(evt,m)
% 
% In:
% 	evt	- an nEvent x 3 array of events.  columns are:
%			event number
%			time
%			duration
%	m	- an nMap x 2 array.  the first column specifies events to map from and
%		  second events to map to
% 
% Out:
% 	evt	- the remapped event array
% 
% Updated: 2012-07-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nMap	= size(m,1);
nEvent	= size(evt,1);

kEventNew	= zeros(nEvent,1);
for kM=1:nMap
	kEventNew(evt(:,1)==m(kM,1))	= m(kM,2);
end

evt			= evt(kEventNew~=0,:);
evt(:,1)	= kEventNew(kEventNew~=0);
