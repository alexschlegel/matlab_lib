function Close(ab)
% AutoBahx.Close
% 
% Description:	close the AutoBahx serial port
% 
% Syntax:	ab.Close()
% 
% Updated: 2012-03-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~isempty(ab.serial)
	if isvalid(ab.serial)
		p_Flush(ab);
		
		try
			fclose(ab.serial);
		catch me
		
		end
		
		try
			delete(ab.serial);
		catch me
		
		end
	end
	
	ab.serial	= [];
end
