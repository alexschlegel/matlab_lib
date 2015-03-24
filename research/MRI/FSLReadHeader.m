function hdr = FSLReadHeader(strPathNII)
% FSLReadHeader
% 
% Description:	read a NIfTI header using FSL
% 
% Syntax:	hdr = FSLReadHeader(strPathNII)
% 
% In:
% 	strPathNII	- the path to a NIfTI file
% 
% Out:
% 	hdr	- a struct of header info
% 
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

persistent strScript;

if isempty(strScript)
	cScript		=	{
						sprintf('source %s > /dev/null',FSLPathConfig)
						'fslhd '
					};
	strScript	= join(cScript,10);
end

hdr	= struct;

nTry	= 4;
kTry	= 0;

while kTry<nTry
	try
		%call fslhd
			[ec,str]	= system([strScript strPathNII]);
		%parse the result
			%keep only the header
				kStart	= strfind(str,'filename');
				
				if isempty(kStart)
					kTry	= kTry + 1;
					continue;
				end
				
				str	= str(kStart:end);
			%parse the entries
				s	= regexp(str,'(?<label>[^\s]+)[ ]*(?<value>[^\n]*)','names');
				
				cLabel	= cellfun(@str2fieldname,{s.label}','UniformOutput',false);
				cValue	= {s.value}';
				
				cValueNum		= cellfun(@str2array,cValue,'uni',false);
				bNum			= ~cellfun(@isempty,cValueNum);
				cValue(bNum)	= cValueNum(bNum);
		%construct the header
			hdr	= cell2struct(cValue,cLabel,1);
			
			%special fields
				hdr.qto_xyz	= [hdr.qto_xyz_1; hdr.qto_xyz_2; hdr.qto_xyz_3; hdr.qto_xyz_4];
				hdr.sto_xyz	= [hdr.sto_xyz_1; hdr.sto_xyz_2; hdr.sto_xyz_3; hdr.sto_xyz_4];
		
		%success!
			kTry	= nTry;
	catch me
		kTry	= kTry + 1;
	end
end
