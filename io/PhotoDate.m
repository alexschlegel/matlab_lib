function t = PhotoDate(strPathPhoto)
% PhotoDate
% 
% Description:	attempt to get the date a photo was taken
% 
% Syntax:	t = PhotoDate(strPathPhoto)
% 
% Updated: 2014-10-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
warning('off','MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero');
ifo	= imfinfo(strPathPhoto);

%try the DateTime field of the image info
	if isfield(ifo,'DateTime')
		t	= FormatTime(ifo.DateTime);
		return;
	end

%try the GPS info
	if isfield(ifo,'GPSInfo') && isfield(ifo.GPSInfo,'GPSDateStamp')
		ifo.GPSInfo.GPSDateStamp
		t	= FormatTime(ifo.GPSInfo.GPSDateStamp);
		return;
	end

%try the file name
	t	= FormatTime(PathGetFilePre(strPathPhoto));
	if ~isnan(t)
		return;
	end

%nothin'
	t	= NaN;
