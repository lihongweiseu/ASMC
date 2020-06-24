%% System information
clc, clear, close all
alpha_hat0=3; b_hat0=2;
alpha_bar=alpha_hat0*0.2; b_bar=b_hat0*0.2;
dt=1/4096;
t=(0:dt:40)';
Nt=length(t);
w=pi/2;
Psi=zeros(Nt,2);

Psi(:,1)=alpha_hat0+alpha_bar*sin(w*t+pi/6);
Psi(:,2)=b_hat0+b_bar*sin(w*t-pi/6);
Psi_hat0=[alpha_hat0;b_hat0];

SW=2;
if SW==1 % Chirp
    fmin=0; fmax=5; %minimum and maximum frequencies
    x0d=chirp(t,fmin,t(end),fmax,'linear',-90);
elseif SW==2 % BLWN
    WNPower = 10*dt; % PSD=10
    FPass = 5; %HZ
    FStop = 2*FPass; %HZ
    sim BLWN_filter;
else % Sine
    x0d=sin(pi/2*t);
end

x1d=zeros(Nt,1);
x2d=zeros(Nt,1);

if SW==2
    for i=1:Nt-1
        x1d(i+1)=(x0d(i+1)-x0d(i))/dt;
        x2d(i+1)=(x1d(i+1)-x1d(i))/dt;
    end
    sim lowpass_filter_x2d
    x2d(1)=0; x1d(1)=0;
    for i=1:1:Nt-1
        x1d(i+1)=x2d(i)*dt+x1d(i);
        x0d(i+1)=x1d(i)*dt+x0d(i);
    end
else
    for i=1:Nt-1
        x1d(i)=(x0d(i+1)-x0d(i))/dt;
    end
    x1d(Nt)=x1d(Nt-1);
    for i=1:Nt-1
        x2d(i)=(x1d(i+1)-x1d(i))/dt;
    end
    x2d(Nt)=x2d(Nt-1);
end

lambda=100; lambda1=lambda; eta=0.1;
sw=1; % 0 means without boundary layer; 1 means with.
Para=[alpha_hat0 b_hat0 alpha_bar b_bar lambda lambda1 eta sw];

%% Non-daptive sliding mode controller
sim NSMC
NSMC_x0=x0; NSMC_x1=x1; NSMC_x2=x2; NSMC_u=u; NSMC_E=E; NSMC_Phi=Phi;
%% Adaptive slding mode controller
theta0=20; k0=20;
sim ASMC
ASMC_x0=x0; ASMC_x1=x1; ASMC_x2=x2; ASMC_u=u; ASMC_E=E; ASMC_Phi=Phi;
Para(8)=0;
sim ASMC
ASMC_u0=u;
%% Plots
% x0 and x1 trackings
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,1,1);
plot(t,x0d,'k','linewidth',1); hold on;
plot(t,NSMC_x0,'--c','linewidth',1); grid on;
plot(t,ASMC_x0,'-.r','linewidth',1);
ylim([-0.8,0.8]);set(gca,'YTick',-0.8:0.4:0.8);
ylabel('$x$ tracking','fontsize',13,'interpreter','latex');
legend({'Designated','NSMC','ASMC'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

subplot(2,1,2);
plot(t,x1d,'k','linewidth',1); hold on;
plot(t,NSMC_x1,'--c','linewidth',1); grid on;
plot(t,ASMC_x1,'-.r','linewidth',1);
ylim([-15,15]);set(gca,'YTick',-15:5:15);
ylabel('$\dot{x}$ tracking','fontsize',13,'interpreter','latex');

for i=1:2
    subplot(2,1,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
    xlabel('Time (s)','interpreter','latex');
end

axes('position',[.24 .85 .2 .07]);
box on;
plot(t,x0d,'k','linewidth',1); hold on;
plot(t,NSMC_x0,'--c','linewidth',1); grid on;
plot(t,ASMC_x0,'-.r','linewidth',1);
xlim([3.08,3.10]); %set(gca,'XTick',3.08:0.01:3.10);
ylim([0.54,0.561]); %set(gca,'YTick',0.54:0.02:0.56);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.24 0.19],[0.87 0.87]);

axes('position',[.24 .375 .2 .07]);
box on;
plot(t,x1d,'k','linewidth',1); hold on;
plot(t,NSMC_x1,'--c','linewidth',1); grid on;
plot(t,ASMC_x1,'-.r','linewidth',1);
xlim([3.01,3.03]); set(gca,'XTick',3.01:0.01:3.03);
ylim([8.3,8.7]); set(gca,'YTick',8.3:0.4:8.7);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.24 0.19],[.41 .38]);
% print -depsc F_x_dx_trackings;
%%
% Compact trackings
% x0 and x1 trackings
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,1,1);
plot(t,NSMC_E,'b','linewidth',1); hold on;
plot(t,NSMC_Phi,':m','linewidth',1.5); grid on;
plot(t,-NSMC_Phi,':m','linewidth',1.5);
% ylim([-0.8,0.8]);set(gca,'YTick',-0.8:0.4:0.8);
legend({'NSMC {\it E}-trajectory','NSMC boundary layer'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

subplot(2,1,2);
plot(t,ASMC_E,'b','linewidth',1); hold on;
plot(t,ASMC_Phi,':m','linewidth',1.5); grid on;
plot(t,-ASMC_Phi,':m','linewidth',1.5);
% ylim([-15,15]);set(gca,'YTick',-15:5:15);
legend({'ASMC {\it E}-trajectory','ASMC boundary layer'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

for i=1:2
    subplot(2,1,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
    xlabel('Time (s)','interpreter','latex');
    ylabel('Compact error','interpreter','latex');
end
% print -depsc F_E_trackings;
%%
% Estimated parameters
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,1,1);
plot(t,Psi(:,1),'k','linewidth',1); hold on;
plot(t,Psi_hat(:,1),'--r','linewidth',1); grid on;
ylim([1.8,4.2]); set(gca,'YTick',1.8:0.6:4.2);
ylabel('Estimation of $\alpha$','interpreter','latex');
legend({'True value $\alpha$','Estimated value $\hat{\alpha}$'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

subplot(2,1,2);
plot(t,Psi(:,2),'k','linewidth',1); hold on;
plot(t,Psi_hat(:,2),'--r','linewidth',1); grid on;
ylim([1.2,2.8]); set(gca,'YTick',1.2:0.4:2.8);
ylabel('Estimation of $b$','interpreter','latex');
legend({'True value $b$','Estimated value $\hat{b}$'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

for i=1:2
    subplot(2,1,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
    xlabel('Time (s)','interpreter','latex');
end
% print -depsc F_alpha_b;

%%
% Command signal
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,2,1:2);
plot(t,ASMC_u0,'b','linewidth',1); hold on;
plot(t,ASMC_u,'--r','linewidth',1); grid on;
axesH = gca;
set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
% axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
ylabel('Command signal','interpreter','latex');
xlabel('Time (s)','interpreter','latex');
% xlim([0,40]);
% ylim([-240,240]); set(gca,'YTick',-240:120:240);
legend({'Without boundary layer','With boundary layer'},'interpreter','latex','location','NorthEast');
subplot(2,2,3);
plot(t,ASMC_u0,'b','linewidth',1); hold on;
plot(t,ASMC_u,'--r','linewidth',1); grid on;
xlim([7,8]);
subplot(2,2,4);
plot(t,ASMC_u0,'b','linewidth',1); hold on;
plot(t,ASMC_u,'--r','linewidth',1); grid on;
xlim([31,32]);

for i=3:4
    subplot(2,2,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
    ylabel('Command signal','interpreter','latex');
    xlabel('Time (s)','interpreter','latex');
end
% ylim([-100,100]); set(gca,'YTick',-100:50:100);
% subplot(2,2,3);
% ylim([-180,180]); set(gca,'YTick',-180:90:180);
