%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Controller algorithm design                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sliding control parameters
d1 = 53354;
d2 = 0.00010595;
d3 = 0.021072;

alpha_hat0=[54290,221.64];
alpha_bar=[0.1*54290,0.36*221.64];
lambda=188; lambda1=lambda; eta=0.1;
Para=[alpha_hat0 alpha_bar lambda lambda1 eta sw];

Rx=rms_noise_DT/dt_rths;
Ax=[0 1;-alpha_hat0]; Bx=[0;1]; Cx=[1,0]; Dx=0;
xinitial=zeros(2,1);

% Phase lead design
compn=[2*dt_rths 1];
compd=[dt_rths 1];