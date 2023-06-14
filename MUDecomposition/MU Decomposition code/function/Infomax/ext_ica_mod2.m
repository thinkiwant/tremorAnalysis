% ==========================================================================
%
% This function performs ICA on mixtures
% of super Gaussian and sub Gaussian distributions.
%
% EXTENDED ICA
% 
% [u,w,wz] = ext_ica(x);
%
% where x has the following form [no of sensors,time points]
%       u are the independent components
%       w is the weight matrix
%       wz is the whitening matrix 
%
%       u = w*wz*x or since W=w*wz ->  u=W*x;
%
% the control displays are:
%       it             number of epochs (number of passes through the data)
%       L              learning rate
%       wchange        change in w-w_old
%       angle change   of delta
%       KD  Kullback-Distance of w, how far is w away from orthogonality
%           after sphering (=0 for perfect separation)
%
%
% Due to the switching moment estimation a reliable analysis is given
% for time points greater than 2000. 
% This code does not provide with some fancy gadgets as in runica.m and 
% also, convergence is slower than runica.m
% Therefore, you may want to change some parameters like 
% learning rate, number of epochs, blocksize etc
% to optimize the code to your data.
%
% see paper in http://www.cnl.salk.edu/~tewon/ for details:
% T. Lee, M. Girolami and T. Sejnowski 
% "Independent component analysis using an extended infomax algorithm 
% for mixed sub-Gaussian and super-Gaussian sources
% Neural Computation, MIT Press.
%
%
% tewon@salk.edu
% 1-20-98
%
% Jan 10, 2005
%Neil Gadhok Mod: 
%    - Commented out whitening.
%    - replaced wz with wz = eye(2);
%    - mod1 only works with 2 sources
%
% Jan 31, 2005
%    -Changed block size from 500 to 50
%    -Changed kurtosis block size from 1000 to 100

% ==========================================================================

function [u,w,wz] = ext_ica_mod1(x);

% ------- important parameters to play with
B=50;            % --blocksize
L=0.001;          % --learning rate
LF=0.985;         % --learning factor
alpha=0.1;        % --momentum constant
iter=100;         % --number of iterations
step=5;           % --display after steps
ksize=100;       % --blocksize for kurtosis estimation

% ------ permutate (not necessary but improves convergence)
data=x;
[N,P]=size(x);                    
permute=randperm(P);                
x=x(:,permute);                   

% ------ sphering (whitening)
%fprintf('\n sphering ... ');
%x=x-mean(x')'*ones(1,P);               % subtract means from mixtures
%wz=2*inv(sqrtm(cov(x')));              % get decorrelating matrix
%x=wz*x;                                % decorrelate mixtures
%fprintf(' done \n');
wz = eye(2);


% ------- initialize parameters ----
w=eye(N);  wold=w;                  
dw_old=w;
olddelta=zeros(1,N*N);
oldchange=1;
degconst = 180./pi;

K=diag(ones(1,N));
if (P>ksize),
  ksize=ksize;
else
  kzise=P;
end;

Id=eye(N);
noblocks=fix(P/B);
BI=B*Id;
tt=1;

% ------- start learning ----------------------------------------
ii=1;
sweep=1;

for it=1:iter, 		% --- begin iterations

  t=1;

  for t=t:B:t-1+noblocks*B,   % --- begin epoche
    u=w*x(:,t:t+B-1);

    % ------ Extension to sub- and super-Gaussians
    tmp1=mean((sech(u').^2)).*mean(u'.^2);
    tmp2=mean(tanh(u').*u');
    K=diag(sign(tmp1-tmp2));

    % ------ learning rule
    dw=L*(BI-K*tanh(u)*u'-u*u')*w;
    d_w=dw+alpha*dw_old;
    dw_old=d_w;
    w=w+d_w;
    
    sweep=sweep+1; 

    % ----------------------------- DISPLAY CONTROL
    if (rem(sweep,step)==0),
    
      if (abs(w(1,1))>10000),
	L=L*.9;
	fprintf('\n weights blow up ... lowering learning rate %5f \n',L);
	w=0.1*eye(N);  wold=w;        
	dw_old=w; 
	olddelta=zeros(1,N*N); oldchange=1;
      end;
      
      d=w*w';
      for k=1:N					% -- how far is w*w' from I
        tt=tt*d(k,k);
      end
      KD=log((tt)/det(d));			% -- Kullback distance measure
      tt=1;

      delta=reshape(wold-w,1,N*N);
      change=delta*delta';
      angledelta=acos((delta*olddelta')/sqrt(change*oldchange));
      olddelta=delta;
      oldchange=change;
      
  %    fprintf('Epoche %d - lrate %5f, wchange %6.5f, angledelta %4.1f, deg K-distance %4.3f \n',it,L,change,degconst*angledelta,KD);
		
    end              
    % ------------------------------------ end of control display

    wold=w;
    
  end;                
  % -------------------------------------- end of epoch

  L=LF*L;

end;  		      
% ---------------------------------------- end of iterations

% --- find independent components u
data=data-mean(data')'*ones(1,P);     
u=w*wz*data;


