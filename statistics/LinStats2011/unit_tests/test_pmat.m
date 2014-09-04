function test_pmat

a11 = ones(2,2);         % submatrix A(1,1)
a12 = 3*ones(2,3);       % ...
a21 = 2*ones(4,2);
a22 = 4*ones(4,3);

p = Pmat(a11,2,2);       % p is a 1 x 1 partioned matrix
q = Pmat(a12, 2,3);
r = Pmat( a21, 4,2);
s = Pmat( a22, 4, 3 );
A = [p q; r s];
test( A.p - [2; 4] );
test( A.q - [2 3] );

% test that the unpartitioned matrices (ie. p and/or q == 0 )
% are properly concatenated with partitioned matrices. The 0s of the 
% p's and q's should be expanded to 1s
A = [Pmat(a11,2,0) q];  % submatrices of size (2,1), (2,1), (2,3) 
test( A.q - [1 1 3] );
test( A.p - 2 );

A = [a11 q];  % no row partitions, [1 1 3] column partitions
test( A.q - [1 1 3] );

A = [Pmat( a12, 0, 3 ); q ]; % A.p = [1 1 2]
test( A.p - [1 1 2]' );

A = [a12; q ]; % A.p = [1 1 2]
test( A.p - [1 1 2]' );

rn = cellstr( ( 'a':'f')' );
cn = cellstr( num2str( (1:5)'));
% create a sumatrix from existing matrices and specify arbitrary
% partitioning.
X = [ a11 a12; a21 a22];
A = Pmat( X, [2 4], [2 3], rn, cn );

test( A{1,1}-a11 );
test( A{1,2}-a12 );
test( A{2,1}-a21 );
test( A{2,2}-a22 );
test( A{:,:} - X );

B = [A A A];
C = [B;B];

test( C.q - [ 2 3 2 3 2 3] );
test( C.p - [2 4 2 4]' );

B = A';
test( double(A)' - double(B) );
test( size(A) - fliplr(size(B)) );
test( size(A) - fliplr(size(B)));

D = Pmat( X);
test(D(:,:) - X );

% test copy constructor 
D = Pmat(D);

% test null constructor
D = Pmat();
D = Pmat( X, [], [], rn, cn );

% test error of incompatible size
try
    Pmat( X, [2 4], [3 3], rn, cn );
    disp('failed: Pmat error detection');
catch
end

try
    Pmat( X, [2 4], [3 3], rn, cn );
    disp('faild: Pmat error detection');
catch
end

%% test assignments
A{1,1} = [2 2; 2 2];
test( A(1:2, 1:2) - [2 2; 2 2] );
test( A{1,2} - a12 );
test( A{2,1} - a21 );
test( A{2,2} - a22 );

A(1:2,1:2) = [1 1 ; 1 1];
test( A(1:2, 1:2) - a11 );
test( A{1,2} - a12 );
test( A{2,1} - a21 );
test( A{2,2} - a22 );

%% test Pmat as vector
try
A = Pmat( X(:,1), [2 4], [], rn );
test(A(1) - a11(:,1) );
test(A(2) - a21(:,1));

A = Pmat( X(1,:), [], [2 3], [], cn );
test(A(1) - a11(1,:) );
test(A(2) - a12(1,:) );
catch
end

disp('passed: Pmat standard ops');

function test(A)

if norm(A) > eps(max(A(:)))
    error( 'failed: test');
end
