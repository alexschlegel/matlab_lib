function XIDClose(s)
% XIDClose
% 
% Description:	close a serial port previously opened for XID communication
% 
% Syntax:	XIDClose(s)
% 
% In:
% 	s	- a serial port opened with XIDOpen
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
fclose(s);
delete(s);
