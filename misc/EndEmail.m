function EndEmail
% EndEmail
% 
% Description:	clear the settings set by PrepEmail
% 
% Syntax:	EndEmail
% 
% Updated: 2011-10-03
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
setpref('Internet','E_mail','');
setpref('Internet','SMTP_Server','');
setpref('Internet','SMTP_Username','');
setpref('Internet','SMTP_Password','');
