function PrepEmail(strEmail,varargin)
% PrepEmail
% 
% Description:	prepare the MATLAB environment to send email via Google's SMTP
%				server
% 
% Syntax:	PrepEmail(strEmail,[strPassword]=<prompt>)
% 
% In:
% 	strEmail		- the from email address
%	[strPassword]	- the SMTP password
% 
% Updated: 2011-10-03
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPassword	= ParseArgs(varargin,[]);
if isempty(strPassword)
	strPassword	= passcode;
end


setpref('Internet','E_mail',strEmail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',strEmail);
setpref('Internet','SMTP_Password',strPassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
