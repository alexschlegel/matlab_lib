function STLWrite(stl,strPathSTL,varargin)
% STLWrite
% 
% Description:	write the STL struct stl to file strPathSTL
% 
% Syntax:	STLWrite(stl,strPathSTL,[strType]='binary')
% 
% In:
% 	stl			- an STL struct loaded with STLRead
%	strPathSTL	- the output STL path
%	[strType]	- the type of the output file, either 'binary' or 'ascii'
% 
% Updated:	2009-04-08
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strType]	= ParseArgs(varargin,'binary');

switch lower(strType)
	case 'binary'
		%open the file
			fid	= fopen(strPathSTL,'w');
			
		%write the header
			fwrite(fid,stl.Header,'uchar');
		
		%write the number of facets
			nFacet	= size(stl.Normal,1);
			fwrite(fid,nFacet,'uint32');
				
		%write the rest of the file as 12 32-bit floats (3 for normal, 9 for vertices)
		%followed by two unnused bytes
			%permute so we count along vectors first
				stl.Vertex	= permute(stl.Vertex,[1 3 2]);
			%write each facet
				for kF=1:nFacet
					fwrite(fid,stl.Normal(kF,:),'float32');
					fwrite(fid,stl.Vertex(kF,:,:),'float32');
					fwrite(fid,0,'uint16');
				end
			
		%close the file
			fclose(fid);
	case 'ascii'
		nPrec	= 16;
		strRet	= [13 10];
		
		%get the name of the stl
			reHeader	= 'solid\s+(?<name>\S+)';
			sHeader		= regexp(stl.Header,reHeader,'names');
		
		%header
			if ~isempty(sHeader)
				strName	= sHeader.name;
			else
				strName	= stl.Header;
			end
			strOut	= ['solid ' strName strRet];
			
		%facets
			nFacet	= size(stl.Normal,1);
			for kF=1:nFacet
				strOut	= [strOut 'facet normal ' num2str(stl.Normal(kF,1),nPrec) ' ' num2str(stl.Normal(kF,2),nPrec) ' ' num2str(stl.Normal(kF,3),nPrec) strRet];
				strOut	= [strOut '   outer loop' strRet];
				
				for kV=1:3
					strOut	= [strOut '      vertex ' num2str(stl.Vertex(kF,kV,1),nPrec) ' ' num2str(stl.Vertex(kF,kV,2),nPrec) ' ' num2str(stl.Vertex(kF,kV,3),nPrec) strRet];
				end
				
				strOut	= [strOut '   endloop' strRet];
				strOut	= [strOut 'endfacet' strRet];
			end
			
		%footer
			strOut	= [strOut 'endsolid ' strName strRet];
			
		%write the file
			%open for writing
				fid	= fopen(strPathSTL,'w');
				
			%write
				fwrite(fid,strOut,'uchar');
			
			%close the file
				fclose(fid);
end

