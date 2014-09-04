classdef Pmat < double
    %PMAT manage partitioned matrices, and pages of matrices
    %Let A be a p x q x n matrix, with  r groups of rows and the
    %s groups of columns so that A(i,j), for i in 1..r and j in 1..s,
    % returns a submatrix of size p(i) x q(j)
    %
    %Pmat isA double and supports most of ops that the class
    %double supports
    %
    %Usage
    %   A = Pmat( A, p, q );
    %       partion a numeric matrix, A, into sizes given by p and q
    %   A = Pmat( A, p, q, rn, cn );
    %       partion a numeric matrix,A, into sizes given by p and q and give the
    %       rows and/or columns names
    %       rn and cn are cellstrs for each row and column of double(A).
    %       These will be partititioned into cells of cellstrs
    %       so the ith cellstr of rn is p(i), and the ith of cn is q(i); 
    %       If A is not paritioned then rn (cn) are cellstrs
    %   A = Pmat( C, ... );
    %       C is a sum(q)-cell array of sum(p)x n matrices. Returns A, a
    %       Pmat with n pages of Pmats accessed by P(:,:,k), where k is a
    %       page in 1..n
    % 
    % NOTES on accessing partitions
    %       Pages by default are carried along in subsref operations
    %       if A has multiple pages then A(1,1) is the same as A(1,1,:);
    %       to access specified pages the 3rd argument must be supplied
    %       A shortcut to get just the kth page(s) is A(k). This behavior
    %       may change because it causes some standard numeric operations
    %       to fail because they assume A(k) is the kth element of A
    %
    %
    %Examples
    % % given a set of matrices ...
    %  a11 = ones(2,2);         % submatrix A(1,1)
    %  a12 = 3*ones(2,3);       % ...
    %  a21 = 2*ones(4,2);
    %  a22 = 4*ones(4,3);
    %  % create a sumatrix from existing matrices and specify arbitrary
    %  % partitioning.
    %  A = Pmat( [ a11  a12; a21 a22 ], [2 4], [2 3] );
    %
    %  % access the 4x3 matrix at A{2,2}
    %  A{2,2}

    % Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
    
    %TODO: 
    %      Define squeeze(). Don't implicily squeeze (and transpsoe) when
    %      extracting a sub-matrix that is a vector
    properties(GetAccess='public', SetAccess='public')
        p   = 0;               % rows in A(i,:)
        q   = 0;               % cols in A(:,j)
        rnames   = cell(0);  % cellstrs to name rows (stored as column)
        cnames   = cell(0);  % cellstr to name cols (stored as row)
        version = 0.9;        
    end
    
    methods
        function a = Pmat(A, u, v, rn, cn)
            if nargin == 0
                A = []; % empty pmat
            end
            if iscell(A)
                A = cat( 3, A{:} );
                A = permute( A, [1 3 2] );
            end
            a = a@double(A);
            if isa(A,'Pmat')
                a.p = A.p;
                a.q = A.q;
                a.rnames = A.rnames;
                a.cnames = A.cnames;
                return;
            else
                 if nargin == 0
                    return;
                end
                
%                 a.p = ones(size(A,1),1);
%                 a.q = ones(1, size(A,2));
                
                if nargin > 1
                    if isempty(u)
                        u = a.p;
                    end
                    a.p = u(:);    
                    
                    if nargin > 2
                        if isempty(v)
                            v = a.q;
                        end
                        a.q = v(:)';
                    end
                end
            end
            
            
            [m n ~] = size(double(A));
            % the sum of the partion sizes must equal the size of A
            % or (i.e. unpartitioned)
            if (m ~= sum(a.p) && psize(a,1)~=m ) || (n ~= sum(a.q)  && psize(a,2) ~=n )
                error('linstats:Pmat:IncompatibilePartition', 'size of sub-matrix must add to matrix size');
            end
            
            if nargin < 4 || isempty(rn)
                rn = cell(m,0);
            end
            a.rnames = rn;
            
            if nargin < 5 || isempty(cn)
                cn = cell(0,n);
            end
            a.cnames = cn;
        end
        
        function rn = row_names(a, rj )
            % returns a cell str containing the row names of the rith
            % row partition. if ri is empty (or ':') all row names are
            % returned
            if nargin < 2 || isempty(rj)
                rn = a.rnames;
            else
                ri = row2ind( a, rj );
                rn = a.rnames;
                rn = rn(ri);
            end
        end
        
        function cn = col_names(a, cj )
            % returns a cell str containing the column names of the rith
            % column partition. if cj is empty (or ':') all row names are
            % returned
            if nargin < 2 || isempty(cj)
                cn = a.cnames;
            else
                ci = col2ind( a, cj );
                cn = a.cnames;
                cn = cn(ci);
            end
        end
        
        
        function varargout = subsref( a,s )
            switch s(1).type
                case '()'
                    if  size(a,3) > 1 && length(s(1).subs)==1 % access all elements of a page
                        pi = s(1).subs{1};
                        cj = ':'; ci = ':'; ri = ':'; rj = ':';
                    elseif isvector(a) && length(s(1).subs)==1; % access a when its a vector
                        if size(a,1) == 1          % a is a single row
                            cj = s(1).subs{1};     % index represents col(s)
                            ci = cj;
                            ri = 1;  rj = 1; pi = ':';
                        else                       % a is a single col
                            rj = s(1).subs{1};     % index represents row(s)
                            ri = rj;
                            ci = 1; cj = 1; pi = ':';
                        end
                    else  % access all pages using 2 indices or individual pages using 3 indices 
                        rj = s(1).subs{1};     % index represents row(s)
                        cj = s(1).subs{2};     % index represents row(s)
                        if length(s(1).subs)>2
                            pi = s(1).subs{3};
                        else
                            pi = ':';
                        end
                        ri = rj;
                        ci = cj;
                    end
                    t = double(a);
                    
                    rn = [];
                    cn = [];
                    if ~isempty(a.rnames)
                        rn = a.rnames(ri);
                    end
                    if ~isempty(a.cnames)
                        cn = a.cnames(ci);
                    end
                    
                    % if there are multiple pages being selected
                    t = t(ri,ci,pi);
                    sz = size(t);

                    % remove partitioning if anything except all rows
                    if (ischar(ri) && ri==':') ||  isequal( ri(:), (1:size(a,1))' )
                        p = a.p; %#ok<*PROP>
                    else
                        p = 0; 
                    end
                    
                    if (ischar(ci) && ci==':') ||  isequal( ci(:), (1:size(a,2))' )
                        q = a.q; %#ok<*PROP>
                    else
                        q = 0; 
                    end
                    
                    
                 %% PROPOSAL  
                    varargout{1} = Pmat(t, p, q, rn, cn);
                    % use preceeding line instead of the following section
                    % to avoid squeezing dimensions
%                     if ndims(t)>2 && sz(3) > 1 && sz(2) == 1
%                            % there is one column being selected
%                            t = squeeze(t)';
%                            if isvector(t), t=t(:); end;
%                             varargout{1} = Pmat(t, 0,p, [], rn);
%                     elseif ndims(t)>2 && sz(3) > 1 && sz(1) == 1
%                         % there is one row being selected
%                             varargout{1} = Pmat(squeeze(t)', 0, q, [], cn);
%                     else
%                             varargout{1} = Pmat(t, p, q, rn, cn);
%                     end
                case '{}'
                    if  size(a,3) > 1 && length(s(1).subs)==1 % access all elements of a page
                        pi = s(1).subs{1};
                        cj = ':'; ci = ':'; ri = ':'; rj = ':';
                    elseif isvector(a) && length(s(1).subs)==1; % access a when its a vector
                        if size(a,1) == 1          % a is a single row
                            cj = s(1).subs{1};     % index represents col(s)
                            ci = col2ind( a, cj );
                            ri = 1;  rj = 1; pi = ':';
                        else                       % a is a single col
                            rj = s(1).subs{1};     % index represents row(s)
                            ri = row2ind( a, rj );
                            ci = 1; cj = 1; pi = ':';
                        end
                    else  % access all pages using 2 indices or individual pages using 3 indices 
                        rj = s(1).subs{1};     % index represents row(s)
                        cj = s(1).subs{2};     % index represents row(s)
                        if length(s(1).subs)>2
                            pi = s(1).subs{3};
                        else
                            pi = ':';
                        end
                        ri = row2ind( a, s(1).subs{1} );
                        ci = col2ind( a, s(1).subs{2} );
                    end
                    t = double(a);
                    
                    rn = [];
                    cn = [];
                    if ~isempty(a.rnames)
                        rn = a.rnames(ri);
                    end
                    if ~isempty(a.cnames)
                        cn = a.cnames(ci);
                    end
                    
                    if a.p==0;
                        p = 0; %#ok<*PROP>
                    else
                        p = a.p(rj);
                    end
                    if a.q == 0;
                        q = 0;
                    else
                        q = a.q(cj);
                    end
                    % if there are multiple pages being selected
                    t = t(ri,ci,pi);
                    sz = size(t);
                    
                 %% PROPOSAL  
                    varargout{1} = Pmat(t, p, q, rn, cn);
                    % use preceeding line instead of the following section
                    % to avoid squeezing dimensions
%                     if ndims(t)>2 && sz(3) > 1 && sz(2) == 1
%                            % there is one column being selected
%                            t = squeeze(t)';
%                            if isvector(t), t=t(:); end;
%                             varargout{1} = Pmat(t, 0,p, [], rn);
%                     elseif ndims(t)>2 && sz(3) > 1 && sz(1) == 1
%                         % there is one row being selected
%                             varargout{1} = Pmat(squeeze(t)', 0, q, [], cn);
%                     else
%                             varargout{1} = Pmat(t, p, q, rn, cn);
%                     end
%                     if ndims(t)>2 && sz(3) > 1 && sz(2) == 1
%                            % there is one column being selected
%                            t = squeeze(t)';
%                            if isvector(t), t=t(:); end;
%                             varargout{1} = Pmat(t, 0,p, [], rn);
%                     elseif ndims(t)>2 && sz(3) > 1 && sz(1) == 1
%                         % there is one row being selected
%                             varargout{1} = Pmat(squeeze(t)', 0, q, [], cn);
%                     else
%                             varargout{1} = Pmat(t, p, q, rn, cn);
%                     end
     
                case '.'
                    t = a.(s(1).subs(1,:));
                    if length(s)>1
                       varargout{1} = subsref( t, s(2:end));
                    else
                        varargout{1} = t;
                    end
            end
        end
        
        function varargout = size(a, varargin)
            % size returns the dimensions of the underlying unpartitioned
            % matrix. 
            % See also psize
            [varargout{1:nargout}] = size(double(a),varargin{:});
        end
        
%         function n = numel(a, varargin)
%             n = numel(double(a), varargin{:});
%         end    
        
        function varargout = psize(a, dim)
            [p q r] = size(double(a));
            if a.p~=0
                p = length(a.p);
            end
            if a.q~=0
                q = length(a.q);
            end
            
            if nargin < 2
                if nargout <= 1
                    varargout{1} = [p q r];
                else
                    varargout{1} = p;
                    varargout{2} = q;
                    if nargout > 2
                        varargout{3} = r;
                    end
                end
            elseif dim == 1
                varargout{1} = p;
            elseif dim == 2
                varargout{1} = q;
            elseif dim==3
                varargout{1} = r;
            end
        end
        
        
        function a = setp(a,p)
            if sum(p) ~= size(a,1)
                error('linstats:Pmat:InvalidPartition', 'p must sum to number of rows');
            end
            a.p = p;
        end
        
        function a = setq(a,q)
            if sum(q) ~= size(a,2)
                error('linstats:Pmat:InvalidPartition', 'q must sum to number of cols');
            end
            a.q = q;
        end
        
        function a = subsasgn( a,s,b )
            switch s(1).type
                case '()'
                    x = double(a);
                    x = subsasgn( x, s, b );
                    a = Pmat( x, a.p, a.q, a.rnames, a.cnames );
                case '{}'
                    if isvector(a) && length(s(1).subs)==1;
                        if size(a,1) == 1
                            [ci cj] = col2ind( a, s(1).subs{1} );
                            ri = 1; pi = 1;
                        else
                            [ri rj] = row2ind( a, s(1).subs{1} );
                            ci = 1; pi = 1;
                        end
                    else
                        % Translate variable (column) names into indices (translates ':')
                        [ri rj] = row2ind( a, s(1).subs{1} );
                        [ci cj] = col2ind( a, s(1).subs{2} );
                        if length(s.subs) == 3
                            pi = s.subs{3};
                        else
                            pi = 1;
                        end
                    end
                    t = double(a);
                        
                    if ~isempty(b)
                        if length(s.subs) == 3
                            t(ri,ci,pi) = b;
                        else
                            t(ri,ci,pi) = b;
                        end
                        a = Pmat( t, a.p, a.q, a.rnames, a.cnames );
                    else
                        % if all s(1).subs == ':' then delete everything
                        if all( strcmp(s(1).subs, ':'))
                            a = Pmat;
                            return;
                        end
                        
                        if s(1).subs{1} ~= ':'  % delete rows
                            t(ri,:,:) = [];
                            if rj <= length(a.p);
                                a.p(rj) = [];
                            end
                            rn = a.rnames;
                            rn(ri) = [];
                            a = Pmat(t, a.p, a.q, rn, a.cnames);
                        end
                        
                        if s(1).subs{2} ~= ':' % delete columns
                            t(:,ci,:) = [];
                            if cj <= length(a.q);
                                a.q(cj) = [];
                            end
                            cn = a.cnames;
                            cn(ci) = [];
                            a = Pmat(t, a.p, a.q, a.rnames, cn);
                        end
                        
                        if length(s(1).subs) > 2 && pi ~= ':'
                            t(:,:,pi) = [];
                            a = Pmat(t,a.p, a.q, a.rnames, a.cnames );
                        end
                        
                    end
                case '.'
                    a.(s.subs(1,:)) = b;
            end
        end
        
        function a = set.cnames(a,cn)
            if ~isempty(cn)
                if ischar(cn)
                    cn = cellstr(cn);
                end
                if ~iscellstr( cn)
                    error('linstats:Pmat:InvalidArgument', 'column names must be a cellstr');
                end
                if length(cn) ~= size(a,2) && ~isempty(a)
                    error('linstats:Pmat:InvalidColNameSize', 'must be one name for each column of A');
                end
            end
            a.cnames = cn(:)';
        end
        
        function a = set.rnames(a,rn)
            if ~isempty(rn)
                if ~iscellstr( rn)
                    error('linstats:Pmat:InvalidArgument', 'column names must be a cellstr');
                end
                if length(rn) ~= size(a,1) && ~isempty(a)
                    error('linstats:Pmat:RowNameSize', 'must be one names for each row of A');
                end
            end
            a.rnames = rn(:);
        end
        
        function a = cat(dim, a, b, varargin)
            switch dim
                case 1
                    a = vertcat(a,b, varargin); 
                case 2
                    a = horzcat(a,b, varargin); 
                case 3
                    a = zcat(a,b,varargin);
                otherwise
                    error('linstats:Pmat:Cat', 'first argument, dim, must be 1,2 or 3');
            end
        end
        
        function a = zcat( a, b, varargin )
            if isempty(b)
                return;
            end
            if ~isa( b, 'Pmat')
                b = Pmat( b, 0, a.q );
            end
            if ~isa( a, 'Pmat');
                a = Pmat( a, 0, b.q );
            end
            if isempty(a)
                a = b;
            else
                if ~all( a.q == b.q )
                    error('linstats:Pmat:NonConformantSubmatrices', 'z concatenation requires equal col partitions');
                end
                if ~all( a.p == b.p )
                    error('linstats:Pmat:NonConformantSubmatrices', 'z concatenation requires equal row partitions');
                end        
                x = cat(3,double(a), double(b));
                a = Pmat( x, a.p, a.q, ...
                          a.rnames, a.cnames );
            end
            if nargin > 2
                a = zcat(a,varargin{:}); 
            end
        end
        
        function a = vertcat( a, b, varargin )
            if isempty(b)
                return;
            end
            if ~isa( b, 'Pmat')
                b = Pmat( b, 0, a.q );
            end
            if ~isa( a, 'Pmat');
                a = Pmat( a, 0, b.q );
            end
            if isempty(a)
                a = b;
            else
                if ~all( a.q == b.q )
                    error('linstats:Pmat:NonConformantSubmatrices', 'vertical concatenation requires equal col partitions');
                end
                if a.p(1)==0 && b.p(1) == 0;
                    p = 0;
                else
                    p = a.p;
                    if p(1) == 0
                        p = ones( size(a,1), 1);
                    end
                    if b.p(1)==0
                        p = [p; ones( 1, size(b,1))];
                    else
                        p = [p; b.p];
                    end
                end
                a =  Pmat( [double(a); double(b)], p, a.q, ...
                    [a.rnames;b.rnames], a.cnames );
            end
            if nargin > 2
                a = vertcat(a,varargin{:}); 
            end
        end
        
        function a = horzcat( a, b, varargin )
            if isempty(b)
                return;
            end
            if ~isa( b, 'Pmat')
                if ~isa( a, 'Pmat')  % neither is pmat, can happen with three or more elements in cat list
                    b = Pmat(b, 0, 0);
                else
                    b = Pmat( b, a.p, 0 );
                end
            end
            if ~isa( a, 'Pmat');
                a = Pmat( a, b.p, 0 );
            end
            if isempty( a.cnames) && ~isempty(b.cnames) 
                a.cnames = strenum( 'a', size(a,2) );
            end
            if isempty( b.cnames ) && ~isempty(a.cnames) 
                b.cnames = strenum( 'b', size(b,2) );
            end
            if isempty(a)
                a  = b;
            else
                if ~all( a.p == b.p )
                    error('linstats:Pmat:NonConformantSubmatrices', 'horz concatenation requires equal row partitions');
                end
                if a.q(1) == 0 && b.q(1) == 0;
                    q = 0;
                else
                    q = a.q;
                    if q(1) == 0
                        q = ones( 1, size(a,2));
                    end
                    if b.q(1)==0
                        q = [q ones( 1, size(b,2))];
                    else
                        q = [q b.q];
                    end
                end
                a  = Pmat([double(a) double(b)], a.p, q, ...
                           a.rnames, [a.cnames b.cnames]);
            end
            
            if nargin > 2
                a = horzcat( a, varargin{:}); 
            end
        end
        
        function p = mtimes( a, b)
            if ndims(b)==3
                [p , ~, r] = size(b);
                b.cnames = [];
                x = double(a)*reshape( double(b), [p r]);
            else
                x = double(a)*double(b);
            end
            rn = []; cn = [];
            p = 0; q = 0;
            if isa(a,'Pmat');
                rn = a.rnames;
                p = a.p;
            end
            if isa(b,'Pmat');
                cn = b.cnames;
                q = b.q;
            end
            p = Pmat( x, p, q, rn, cn );
        end
        
        function n = end( a, b, c )
            % c is the number of dimensions included in the expression
            % containing 'end'
            % b is the index of the dimension that contained  'end'
            sz = psize(a);
            fsz = size(a);
            k = sz==0;
            sz(k) = fsz(k);
            if c==1 
                if isvector(a)
                    n = max(fsz);
                else
                 error('linstats:Pmat:IllegalVectorAccess', '2d Pmats cannot be accessed with 1d indices');
                end
            else
                n = fsz(b);
            end
        end
        
        function n = length(a)
            n = length@double(a);
        end
        
        function [ri terms] = row2ind(a, terms )
            % returns a index for A(i,:) a p(i) x q matrix
            p = psize(a,1);
            if strcmp( terms, ':' )
                terms = 1:p;
            end
            if islogical(terms)
                if length(terms) ~= p;
                    error('linstats:PMAT:LogicalIndexOutOfRange', 'logical indices must be the same length as the number of terms in the model');
                end
                terms    = find(terms);
            end
            if a.p==0 % if it is not partitioned, return terms
                ri = terms; 
                return
            end
            en = cumsum(a.p);
            be = [1;1+en(1:end-1)];
            b  = arrayfun( @(i)( be(i):en(i)), terms, 'Uniform', false);
            ri = horzcat(b{:})';
        end
        
        function [ci terms] = col2ind(a, terms )
            % returns a indices to the columns of the underlying full matrix
            % and terms, which is the numeric equivalent of the input
            q = psize(a,2);
            if strcmp( terms , ':' )
%                 terms = 1:q;
                ci = terms;
                return;
            end
            if islogical(terms)
                if length(terms) ~= q;
                    error('linstats:PMAT:LogicalIndexOutOfRange', 'logical indices must be the same length as the number of terms in the model');
                end
                terms    = find(terms);
            end
             if a.q==0 % if it is not partitioned, return terms
                ci = terms; 
                return
            end
            en = cumsum(a.q);
            be = [1 1+en(1:end-1)];
            b  = arrayfun( @(i)( be(i):en(i)), terms, 'Uniform', false); %FIXME: WAYYYYYY SLOW
            ci = horzcat(b{:})';
        end
        
        function a = ctranspose(a)
            a  = Pmat( double(a)', a.q, a.p,a.cnames',a.rnames');
        end
        function a = transpose(a)
            a  = Pmat( double(a)', a.q, a.p, a.cnames', a.rnames');
        end
        
        
        function display(a, varargin )
            % called when semi colon left out at command prompt. Don't spew
            % reams of output.  For that make the user type (disp(pmat))
            % TODO: Handle case with more than one page by giving feedback
            maxrows = 30; maxcols = 8;
            [nr nc np] = size(a);
            nrows = min( maxrows, nr );
            ncols = min( maxcols, nc );
            if nr > maxrows || nc > maxcols
                disp('*** Partial listing. use disp(X) for full listing ***');
            end
                

            rn = a.rnames; cn = a.cnames;
            if ~isempty(rn);
                rn = rn(1:nrows);
            end
            if ~isempty(cn)
                cn = cn(1:ncols);
            end
            
            % prepend ' ' to colnames if rnames not empty
            if ~isempty(rn)
                if isempty(cn)
                    cn = [];
                else
                    cn = [' ' cn];
                end
            end
            
            x = double( a);
            x = x(1:nrows, 1:ncols, 1 );
            if isempty(rn)
                T = table( cn, x);
            else
                T = table( cn, rn, x);
            end

            if nargout > 0
                tbl = T;
            else
                disp(T);
            end
        end
        
        function tbl = disp(a, anno)
            % TODO: Handle case with more than one page by accepting
            % additional annotation to disp. The annotation will be
            % repeated with each page of a
            % a is an m x n x p Pmat  
            % anno is a dataset with p rows and q columns
            % tbl is a m*p x (q+n) table
            
            if nargin > 1
                if ~isa(anno,'dataset')
                   anno = dataset(anno); 
                end
            end
            rn = a.rnames;
            cn = a.cnames;
            
            % prepend ' ' to colnames if rnames not empty
            if ~isempty(rn)
                if isempty(cn)
                    cn = [];
                else
                    cn = ['source' cn];
                end
            end
            
            % if multiple pages (and possible require annotation )
            [m n p] = size(a);
            x = double( a );
            if p > 1
                x = reshape( permute( x, [1 3 2]), [m*p n] );
                rn = repmat( rn, p, 1 );
                % replicate annotation
                if nargin > 1
                    if size(anno,1) ~= p
                        error('Pmat:disp:InvalidArgument', 'anno must me same length as pages in Pmat');
                    end
                    j = blkrepmat( 'c', (1:p)', m );
                    anno = anno(j,:);
                end
            end
            
            if isempty(rn)
                T = table( cn, x);
            else
                T = table( cn, rn, x);
            end
            
            if nargin > 1
                T = [dataset2table(anno) T];
            end
            
            
            % augment T with annotation
            if nargout > 0
                tbl = T;
            else
                disp(T);
            end
    
        end
        
        function a = saveobj(a)
        end
    end
    
    methods (Static) 
        function b = loadobj(a)
            if isstruct(a)
                cn = a.cnames;
                if ~isempty(cn) && ~iscellstr(cn) && iscell(cn)
                    cn = horzcat(cn{:});
                end
                rn = a.rnames;
                if ~isempty(rn) && ~iscellstr(rn) && iscell(rn)
                    rn = vertcat(rn{:});
                end
                b = Pmat( a.Data, a.p, a.q, rn, cn );
            else
                b = a;
            end
            b.version = 0.9;
        end
    end
end % classdef



