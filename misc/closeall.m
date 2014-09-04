function closeall()
% CLOSEALL
%
% Description:	close all figures
%
% Syntax:	closeall
%
% Updated:	2005-04-27
% Copyright 2005 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	set(0,'ShowHiddenHandles','on');
	delete(get(0,'Children'));
