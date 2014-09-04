classdef Dmat < Pmat
    %DMAT a partitioned matrix for working with linear models
    %   It creates design matrices for categorical or continuous 
    %   fixed, crossed and nested variabless. 
    %
    %usage
    %  DMAT(Vars, mmat)
    %  DMAT( x1,x2,x3,.....,mmat);
    %          x1,x2,... are vectors or matrices with the same number of
    %          rows. If x is numberic it is considered continuous otherwise
    %
    %          mmat, is optional and must be empty, a scalar, or be a mmat
    %          descriptor. a matrix must have the same number of columns as x's
    %
    %  DMAT(Pmat, type, term_names, expansion_matrix ) % used internally
    %examples
    %       load fertilizer
    %       d = Dmat( Vars(block, fertilizer, 'type', 1), 'model', 2);
    %       d{:,1}  % intercept term (is a double)
    %       d{:,2}; % block (5 column incidence matrix)
    %       d{:,3}; % fertilizer (4 column incidence matrx)
    %       d{:,4}; % block*fertilizer
    %
    %      % alternate calling form (used internally to copy a Dmat)
    %      %  d = Dmat( A, type, tnames, emat );

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%    
    properties
        type       = []; % type of each term (including intercept)
        tnames     = {}; % name each term in the mmat (nterms x nparams)
        %        pnames     = {}; % name for each parameter (col of dmat )
        %        qnames     = {}; % name of the expanded parameter names
        emat       = BDmat; % BDmat of matrices to expand parameter estimates (includes entry for intercept if present
    end
    properties (Dependent = true, SetAccess = private)
        X;         % fixed effects design matrix
        Z;         % random effects design matrix
        Le;        % Coefficient matrix to expand estimates for all parameters
        fi;        % index to fixed terms in design matrix (random terms are ~fi)
        hasIntercept; % whether the first term is named 'intercept'
    end
    
    methods
        function a = Dmat(varargin)
            pmat = [];
            if nargin == 4 && isa(varargin{1},'Pmat')
                pmat = varargin{1};
            end
            a = a@Pmat(pmat);
            
            if nargin == 4 && isa(varargin{1},'Pmat')
                a.type   = varargin{2};
                a.tnames = varargin{3};
                a.emat = varargin{4};
            elseif nargin > 0
                args = ArgParser(varargin{:});
                mmat = value(args, 'model', 1 );
                V = args.value(1);
                if ~isa(V,'Vars')
                    V = Vars(args.args{:});  
                end
                
                [m n] = size(V);
                if isscalar(mmat) || isempty(mmat)
                    mmat = Dmat.lmodel(n,mmat);
                end
                for i = 1:size(mmat,1)
                    t = mmat(i,:);
                    k = find(t);    %index of variables in this term
                    if isempty(k)
                        % add intercept
                        x = Vars(ones(m,1),'type',1);
                        x.anno{1,1} = 'intercept';
                    else
                        t = t(k);       %how to interpret variables
                        x = V(:,k);     %copy of variables (may be altered)
                    end
                    if any(t>1)
                        %power(x,m)
                        j = t>1 & x.type<=0; % must be continuous
                        if any(j)
                            x.x(:,j) = bsxfun( @power, x.x(:,j), t(j));
                            vn = x.anno.(x.anno.Properties.VarNames{1});
                            x.anno{1,1} = sprintf( '%s^%d', vn{1}, t(j));
                        end
                    end
                    if any(t<0)
                        % nest
                        a = addNestedTerm(a,x(:,t<0), x(:,t>0));
                    elseif sum( t ~= 0) > 1;
                        a = addCrossedTerm(a,x);
                    else
                        a = addTerm(a,x);
                    end
                end
            end
        end
        %TODO: subsasgn
        
        function varargout = subsref( a,s )
            switch s(1).type
                case { '()', '{}' }  % all dmat references are sub-matrices
                    s(1).type = '{}';
                    
                    if isvector(a) && length(s(1).subs)==1; % access a when its a vector
                        if size(a,1) == 1          % a is a single row
                            cj = s(1).subs{1};     % index represents col(s)
                        else                       % a is a single col
                            cj = 1;
                        end
                    else
                        cj = s(1).subs{2};     % index represents row(s)
                    end
                    t = subsref@Pmat(a,s);
                    varargout{1} = Dmat( ...
                        t,a.type(cj), a.tnames(cj), a.emat(cj) );
                case '.'
                    t = a.(s(1).subs(1,:));
                    if length(s)>1
                        varargout{1} = subsref( t, s(2:end));
                    else
                        varargout{1} = t;
                    end
            end
        end
        function L = get.Le(a)
            L = full(a.emat);
        end
        function x = get.X(a)
            k = abs(a.type) == 3; % find random
            x = subsref( a, substruct( '{}', {':', ~k} ));
        end
        function z = get.Z(a)
            k = abs(a.type) == 3; % find random
            z = subsref( a, substruct( '{}', {':', k} ));
        end
        function i = get.fi(a)
            %returns vector of boolean indices to the fixed effects in Dmat
            i = abs(a.type)~=3;
        end
        function i = get.hasIntercept(a)
            i = strcmp( a.tnames{1}, 'intercept' );
        end
        function q = ismixed(a)
            %ismixed returns non-zeros for mixed model (0 for fixed model)
            %The value returned is the number of random terms
            q = sum(abs(a.type)==3);
        end
        function a = removeTerm( a, t )
            %removeTerm - removes a term, t from the model
            % t may be a scalar/vector or a name(s) of a term  (char or
            % cellstr)
            if ischar(t) || iscellstr(t)
                ti = ~ismember( a.tnames, t );  % terms to keep
            else
                ti = ~ind2logical( t(:), psize(a,2) );
            end
            ci = col2ind(a,ti);  % columns to keep
            x = double(a);
            x = Pmat(x(:,ci), a.p, a.q(ti), a.rnames, a.cnames(ci) );
            a = Dmat( x, a.type(ti), a.tnames(ti), a.emat(ti) );
        end
        function a = addTerm(a, v)
            % add a new term
            [x D] = Dmat.dummy(v.x, v.type, v.nlevels);
            [tn pn qn] = a.makeNames( v );
            D = BDmat(D,qn,pn);
            b = Dmat( Pmat(x, [], size(x,2), [], pn), v.type, tn, D );
            a = horzcat( a, b   );
        end
    
        function a = addCrossedTerm(a, v  )
            % creates a new term containign the interaction of variables in v.
            % usage
            %    d = Dmat( Vars(g1) );
            %    addTerm( d, Vars(g2) );
            %    addCrossedTerm( d, Vars(g1,g2 ) );
            
            
            % the number of new parameters created is prod( p(v) )
            % L is a logical vector indicating which main effects are crossed
            if any(v.israndom)
                % if any random variables, then the new term will be random
                % and all categorical will be encoded as overdetermined
                type = 3;
                v.type(v.type>0) = 3;
            else
                % set variable type for the new term
                % if any variable in term is randoclm, the term is random
                % if any is continuos they are all continous (uncentered
                % unscaled).
                if any(v.type<=0)
                    type  = 0; %#ok<*PROP>
                else
                    type = max(v.type);
                end
            end
            
            nvars = size(v,2);
            E    = cell(nvars,1);
            dmat = cell(nvars,1);
            
            q = nlevels(v);
            qind   = ffact(q); % all possible combinations of factor levels
            for i = 1:nvars
                D = Dmat.design(q(i), v.type(i) );
                E{i} = D(qind(:,i),:);
                if v.type(i) <= 0
                    % always at least center and possible scale continous variables
                    dmat{i} = Dmat.dummy( v.x(:,i), min(v.type(i),-1) );
                else
                    x = v.x(:,i);
                    k = x>0 & isfinite(x);
                    xx = nan(size(x,1),size(D,2));
                    xx(k,:) = D(x(k,:),:);
                    dmat{i} = xx;
                end
            end
            
            p = cellfun( 'size', E, 2 );
            E = horzcat(E{:});
            
            pind   = ffact(p);              % unique combinations of all parameters
            oset = [0 cumsum(p(1:end-1))']; % offset from first parameters
            rind = bsxfun( @plus, pind, oset )';
            
            % reshape so that each combination of crossed parameters are on dim 2
            % and each page is a separate set of crossed parameters
            emat  = reshape( E(:,rind(:)), size(E,1), nvars, prod(p) );
            emat  = squeeze(prod(emat,2));
            
            dmat = horzcat( dmat{:} );
            dmat = reshape( dmat(:,rind(:)), size(dmat,1), nvars, prod(p));
            dmat = squeeze(prod(dmat,2));
            
            %             a = setCrossNames( v );
            vn = getVarName(v);
            ln = getLevelNames(v);
            if v.type(1) > 0
                qn = strcat( vn{1}, '_', ln{1}(qind(:,1)));
                pn = strcat( vn{1}, '_', ln{1}(pind(:,1)));
            else
                qn =  ln{1}(qind(:,1));
                pn =  ln{1}(pind(:,1));
            end
            
            tn = vn(1);
            for i = 2:length(vn)
                tn = strcat( tn, '*', vn{i});
                if v.type(i) > 0
                    qn = strcat( qn, '*', vn{i},'_', ln{i}(qind(:,i)));
                    pn = strcat( pn, '*', vn{i},'_', ln{i}(pind(:,i)));
                else
                    qn = strcat( qn, '*', ln{i}(qind(:,i)));
                    pn = strcat( pn, '*', ln{i}(pind(:,i)));
                end
            end
            
            D = BDmat(emat,qn,pn);
            b = Dmat( Pmat(dmat, [],size(dmat,2),[],pn), type, tn, D );
            a = horzcat( a, b );
        end
        function a = addNestedTerm(a, inner, outer)
            %addNestedTerm creates a new nested term with inner nested within the outer
            % This means that the inner term always takes on distinctive
            % levels within each level of outer. For example if an
            % experiment is conducted at two sites and each site has two
            % operators, then operators is nested within site, or site
            % contains operator. 
            %usage
            %   load nested
            %   d = Dmat( outer );
            %   d = addTerm( d, other );
            %   d = addNestedTerm( d, inner, outer);
            %   d\y; % solve or ...
            %   Lstats(y,d).anova  % ... run an anova 

            
            % case I. both fixed effect categorical factors
            it = inner.type;
            if outer.type > 0 && it > 0
                [u , ~, j] = unique( [outer.x inner.x], 'rows');
                q  = histc( u(:,1), 1:u(end,1));
                ln = [strcat( '[', getVarName(outer), '_', getLevelNames(outer), ']');
                    strcat( getVarName(inner), '_', getLevelNames(inner));];
                
                tn = strcat( getVarName(inner), '[', getVarName(outer), ']' );
                
                qn = strcat( ln(u(:,2)+nlevels(outer)), ln( u(:,1)));
                if it == 3
                    d = blkrepmat( 'I', 1, q );
                    v  = u;
                    v(:,2) = v(:,2) + nlevels(outer);
                    pn = strcat( ln(v(:,2)), ln(v(:,1)));
                else
                    d  =  arrayfun( @(x)mdummy(1:x,1,x), q, 'uniformoutput', false );
                    d  = blkdiag(d{:});
                    r  = cumsum( q );
                    v  = u(~ind2logical(r,size(u,1)),:);
                    v(:,2) = v(:,2) + nlevels(outer);
                    pn = strcat( ln(v(:,2)), ln(v(:,1)));
                end
                dmat  = d(j,:);
            else
                error('linstats:Dmat:InvalidNesting', 'Can not nest continuous variables');
            end
            
            if it == 3 || outer.type == 3
                type = 3;
            else
                type = max(min(outer.type, inner.type),0);
            end
            
            D = BDmat(d,qn,pn);
            b = Dmat( Pmat(dmat, [],size(dmat,2),[],pn), type, tn, D );
            a = horzcat( a, b );
        end
        function a = cat(a, b)
            a = horzcat(a,b);
        end
        function a = vertcat( a, b )
            a = Dmat( vertcat@Pmat(a, b), ...
                a.type, a.tnames,  a.emat);
        end
        function a = horzcat( a, varargin )
            % concatentate two models 
            % horzcat( [], a ); %returns a
            % horzcat( a, b  ); %returns [a b], 
            % horzcat( a, b, ..., z); % returns [a b ... z]
            b = varargin{1};
            if isempty(a)
                a  = b;
            else
                if ~isa(b,'Dmat')
                    b = Dmat(b,0);
                end
                t  = horzcat@Pmat(a,b);
%                 t  = Pmat([double(a) double(b)], a.p, [a.q b.q], ...
%                     a.rnames, [a.cnames b.cnames]);
                a = Dmat(t, ...
                    vertcat( a.type, b.type ), ...
                    vertcat( a.tnames, b.tnames ), ...
                    vertcat( a.emat,b.emat));
            end
            if length(varargin) > 1
                a = horzcat( a, varargin{2:end} );
            end
        end
        
        function  classname = superiorfloat(varargin)
            %SUPERIORFLOAT returns 'double' if superior input has class double.
            classname = 'double';
        end
    end
    methods(Static)
          function [tn pn qn]  = makeNames( v ) 
            tn = getVarName(v,1);
            if v.type(1)>0
                qn = getLevelNames(v,1);
                if length(qn) > 1
                    qn = strcat( tn, '_', qn);
                    pn = qn;
                    if  v.type(1) == 1 || v.type(1) == 2
                        pn = qn(1:end-1);
                    elseif v.type(1) == 4;
                        pn = qn(2:end);
                    end
                else
                    qn = tn;
                    pn = tn;
                end
            else
                pn = tn;
                qn = tn;
            end
        end
        function [d, D] = dummy(x,method, p)
            % DUMMY enodes integer index (grouping) variables into a design matrix
            % [d, D] = mdummy(x, method, nlevels)
            % X is a vector of integer grouping variables in 1:p, p is assumed to be max(x)
            % METHOD specifies an encoding method
            %
            % d is encoded design matrix
            % D is the unique listing of the design matrix. Each row represents the
            % encoding of the corresponding integer index
            %
            % [d, D] = dummy(x, method, p)
            % X is a vector of integer grouping variables in 1:p.
            % See also Dmat.design
            
            
            if nargin < 3 && method > 0
                p = max(x);
            end
            
            if method <= 0      % continuous
                D = 1;
                d = x;
                if method <= -1
                    mu = nanmean(d);
                    d = d - mu;
                    if method <= -2
                        d = scale( d, range(d)/2 );
                    end
                end
                return;
            end
            
%             n = size(x,1);
            if nargin < 3
                g = max(x);
            else
                g = p;
            end;
            
            if g==1; % single group
                d = ones(size(x,1),1);
                d(~isfinite(x)) = nan;
                D = 1;
                return;
            end
            
            D = Dmat.design( g, method);
            i = x>0 & isfinite(x);
            d = nan(size(x,1),size(D,2));
            d(i,:) = D(x(i),:);
        end
        
        function D = design( g, method)
            % returns a design matrix for a g-level categorical variable
            %   for full rank methods g-1 variables are created
            %   for overdetermiend p variables are created.
            %   method = 1:   0/-1/1 coding, full rank  (aka nominal)
            %   method = 2:   0/1 coding, full rank     (aka ordinal)
            %   method = 3:   0/1 coding, random term
            %   method = 4:   0/1 conding, full rank (aka reference cell).
            %                 level 1 is the reference and is effectively droped
            %                 the p-1 variables correspond to the remaining levels
            
            ncols = g - double( (method ~= 3 & method ~=5) );
            
            switch method
                case 1
                    D = eye( [g ncols] );
                    D(end,:) = -1;
                case 2
                    D = tril(ones([g ncols]), -1);
                case 4
                    D = [zeros(1,g-1);eye(g-1)];
                case {3, 5}
                    D = eye( [g ncols] );
                otherwise
                    if method <= 0
                        D = 1;
                    else
                        error('LinStats:Dmat:Design:InvalidDesignMethod', 'valid design methdos must be < 5');
                    end
            end
        end
        function b = loadobj( a )
            if isstruct(a)
                cn = a.cnames;
                if ~isempty(cn) && ~iscellstr(cn) && iscell(cn)
                    cn = horzcat(cn{:});
                end
                rn = a.rnames;
                if ~isempty(rn) && ~iscellstr(rn) && iscell(rn)
                    rn = horzcat(rn{:});
                end
                a.cnames = cn;
                a.rnames = rn;
                b = Pmat.loadobj(a);
                b = Dmat( b, a.type, a.tnames, a.emat );
            else
                b = a;
            end
            b.version = 1.0;
        end
        function model = lmodel(nterms,order)
            %LMODEL returns common linear design matrices
            %
            %Example
            % model = lmodel(nterms,order)
            % returns a standard matrix representation of a model
            % with the given number of predictor variables (terms)
            % and of the given order of interactions
            %
            % the model is either a scalar or a matrix of terms. If it is a scalar it
            % refers to the order of the model. 1 indicates a 1st order model which
            % contains only main effects. A 2nd order model contains main effects and
            % all pairwise interactions. For more complex models a matrix of terms can
            % be used. Each row of the matrix represents one term a factor effects
            % model. Each column represents a predictor variable. A column containing a
            % non-zero value will be included in the given term of the model
            % mean of "order"
            %   0 = linear with no intercept (eye(nterms))
            %   1 = linear without interaction
            %   2 or more = up to "order-1"th level interactions are models
            %               or fewer if there aren't enough variables

            if nargin < 2 
                order = 1;
            end;
            if ( order > nterms )
                order = nterms;
            end;

            model = cell(order,1);
            
            % intercept term
            if (order == 0)
                model{1} = eye(nterms);
            elseif isempty(order)
                model{1} = zeros( 1, nterms );
            else
                model{1} = [zeros( 1, nterms ); eye(nterms)];
            end;
            
            % build model
            for i = 2:order
                cind = nchoosek(1:nterms,i);
                rows = size(cind,1);
                rind = repmat(1:rows,1,i);
                ind  = sub2ind([rows nterms], rind(:), cind(:));
                t    = zeros( rows, nterms);
                t(ind) = 1;
                model{i} = t;
            end
            model = vertcat(model{:});
        end
    end
    
    
end % classdef



