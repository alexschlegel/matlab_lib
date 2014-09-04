classdef BDmat
    %BDmat block diagnol matrix with named rows and columsn
    %Usage
    %   A = BDmat( A, rnames, cnames)
    %       A is a matrix or a cell array of matrices
    %       rnames and cnames are cellstrs with size(A)
    %
    %Examples
    % % given a set of matrices ...
    %  A(1) returns the first block
    %  full(A) returns a Pmat suitable for doing math
    %  double(A([2 3])) returns double for 2nd and 3rd blocks
    %  double(A) returns block diagnol matrix
    %  A(i) = Pmat(...) sets the ith block to the given Pmat
    
% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
    properties
        data = [];
        rnames = cell(0);  
        cnames = cell(0);
    end
    
    methods
        function a = BDmat(A, rn, cn)
            if nargin == 0
                return;
            end
            if isa(A,'Pmat')
                a.data{1}   = double(A);
                a.rnames{1} = A.rnames;
                a.cnames{1} = A.cnames;
                return;
            end
            
            if isa(A,'BDmat');
                a = A;
                return;
            end
            
            if isnumeric(A)
                a.data{1} = A;
                
                if nargin > 1 || ~isempty(rn)
                    if ischar(rn)
                        rn = cellstr(rn);
                    end
                    a.rnames{1} = rn(:);
                    if length(rn) ~= size(A,1) 
                        error( 'linstats:BDMat:InvalidArgument', 'must be one name for each row of A');
                    end
                else
                    a.rnames{1} = repmat( {''}, size(A,1), 1 );
                end
                
                if nargin > 2 || ~isempty(cn)
                    if ischar(cn)
                        cn = cellstr(cn);
                    end
                    a.cnames{1} = cn(:)';
                    if length(a.cnames{1}) ~= size(A,2)
                        error( 'linstats:BDMat:InvalidArgument', 'must be one name for each column of A');
                    end
                else
                    a.cnames{1} = repmat( {''},  0, size(A,2) ) ;
               end
            else            
                for i = 1:length(A)
                    if ~isa(A{i}, 'Pmat')
                        error('i want a pmat - or fix this');
                    end
                    AA = A{i};
                    a.data{i} = double(AA);
                    a.rnames{i} = AA.rnames;
                    a.cnames{i} = AA.cnames;
                end
                a.cnames = a.cnames(:)';
                a.rnames = a.rnames(:);
            end
        end
        
        
        function varargout = subsref( a,s )
            switch s(1).type
                case '()'
                    if length(s(1).subs)==1; % access a when its a vector
                        i = s(1).subs{1};     %
                        b = a;
                        b.data = b.data(i);
                        b.rnames = b.rnames(i);
                        b.cnames = b.cnames(i);
                        varargout{1} = b;
                    else
                        error( 'linstats:BDmat:InvalidSubscript', 'only one-dimensional subscripting supported');
                    end
                case '.'
                    t = a.(s(1).subs(1,:));
                    if length(s)>1
                        varargout{1} = subsref( t, s(2:end));
                    else
                        varargout{1} = t;
                    end
            end
        end
        
        function p = full( a, i )
            %FULL returns a full blk diagnol matrix as a Pmat use
            %double(full(a)) to get a double
            if nargin < 2
                i = ':';
            end
            rn = vertcat(a.rnames{i}); 
            cn = horzcat(a.cnames{i});
            
            p = Pmat( blkdiag( a.data{i} ), ...
                cellfun(@length, a.rnames(i) ), ...
                cellfun(@length, a.cnames(i) ), ...
                rn,cn );
        end
        
        function varargout = size(a, dim)
            if nargin < 2
                m = sum(cellfun('size', a.data, 1));
                n = sum(cellfun('size', a.data, 2));
                if nargout <= 1
                    varargout{1} = [m n];
                else
                    varargout{1} = m;
                    varargout{2} = n;
                end
            else 
                varargout{1} = sum(cellfun('size', a.data, dim ));
            end
        end
        
        
        function a = cat(a, b)
            a.data = vertcat(a.data,b.data);
            a.cnames = horzcat(a.cnames, b.cnames);
            a.rnames = vertcat(a.rnames, b.rnames);
        end
        
        function a = horzcat(a,b)
            a = cat(a,b);
        end
        
        function b = vertcat(a,b)
            b = cat(a,b);
        end
        
        function n = end( a, b, c )
            if c ~= 1 && ~isvector(a)
                error('linstats:Pmat:IllegalAccess', '1d access only');
            end
            n = size(a,b);
        end
        
        function a = ctranspose(a)
            [a.rnames a.cnames] = deal(cellfun( @transpose, a.cnames, 'uniformoutput', false), ...
                                       cellfun( @transpose, a.rnames, 'uniformoutput', false) );
            a.data = cellfun( @ctranspose, a.data, 'uniformoutput', false);
        end
        function a = transpose(a)
            [a.rnames a.cnames] = deal(cellfun( @transpose, a.cnames, 'uniformoutput', false), ...
                                       cellfun( @transpose, a.rnames, 'uniformoutput', false) );
            a.data = cellfun( @transpose, a.data, 'uniformoutput', false);
        end
        
        function a = double(a)
            a = blkdiag( a.data{:} );
        end
        
        function display(a, varargin )
            n = min(length(a),8);
            b = a(1:n);
            disp(b);
        end
        
        function rn = row_names(a, rj )
            % returns a cell str containing the row names of the rith
            % row partition. if ri is empty (or ':') all row names are
            % returned
            if nargin < 2 || isempty(rj)
                rn = a.rnames;
            else
                rn = a.rnames(rj);
            end
            if ~iscellstr(rn)
                rn = vertcat(rn{:});
            end
        end
        
        function cn = col_names(a, rj )
            % returns a cell str containing the row names of the rith
            % row partition. if ri is empty (or ':') all row names are
            % returned
            if nargin < 2 || isempty(rj)
                cn = a.cnames;
            else
                cn = a.cnames(rj);
            end
            if ~iscellstr(cn)
                cn = horzcat(cn{:});
            end
        end
        
        function disp(a)
            
            a  = a(:);
            rn = a.rnames;
            if ~iscellstr(rn) 
                rn = vertcat(rn{:});
            end
            cn = a.cnames;
            if ~iscellstr(cn)
                cn = horzcat(cn{:});
            end
            
            % prepend ' ' to colnames if rnames not empty
            if ~isempty(rn)
                if isempty(cn)
                    cn = [];
                else
                    cn = [' ' cn];
                end
            end
            
            
            if isempty(rn)
                disp( table( cn, double(a)));
            else
                disp( table( cn, rn, double(a)));
            end
        end
    end
end % classdef



