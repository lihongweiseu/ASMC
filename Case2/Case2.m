%% System information
clc, clear, close all
c1=4; c2=2; c3=2;
coe=[c1 c2 c3]; % ture model parameters
dt=1/4096;
t=(0:dt:40)';

alpha_hat0=1; b_hat0=1;
alpha_bar=alpha_hat0*0.5; b_bar=b_hat0*0.5;

Nt=length(t);
Psi_hat0=[alpha_hat0;b_hat0];

SW=2;
if SW==1 % Chirp
    fmin=0; fmax=5; %minimum and maximum frequencies
    x0d=chirp(t,fmin,t(end),fmax,'linear',-90);
elseif SW==2 % BLWN
    WNPower = 200*dt; % PSD=10
    FPass = 5; %HZ
    FStop = 2*FPass; %HZ
    sim Case2_BLWN_filter;
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
    sim Case2_lowpass_filter_x2d
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

%% Aaptive sliding mode control
theta0=10; k0=20;
sim Case2_ASMC
ASMC_x0=x0; ASMC_x1=x1; ASMC_x2=x2; ASMC_u=u; ASMC_E=E; ASMC_Phi=Phi;
%% Plots
% x0 and x1 trackings
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,1,1);
plot(t,x0d,'k','linewidth',1); hold on;
plot(t,ASMC_x0,'-.r','linewidth',1); grid on;
ylim([-4,4]);set(gca,'YTick',-4:2:4);
ylabel('$x$ tracking','fontsize',13,'interpreter','latex');
legend({'Designated','ASMC'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

hAxis=subplot(2,1,2);
plot(t,x1d,'k','linewidth',1); hold on;
plot(t,ASMC_x1,'-.r','linewidth',1); grid on;
ylim([-60,60]);set(gca,'YTick',-60:30:60);
ylabel('$\dot{x}$ tracking','fontsize',13,'interpreter','latex');
xlabel('Time (s)','fontsize',13,'interpreter','latex');

for i=1:2
    subplot(2,1,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
end

axes('position',[.24 .85 .2 .07]);
box on;
plot(t,x0d,'k','linewidth',1); hold on;
plot(t,ASMC_x0,'-.r','linewidth',1);
xlim([3.08,3.10]); %set(gca,'XTick',3.08:0.01:3.10);
% ylim([0.54,0.561]); %set(gca,'YTick',0.54:0.02:0.56);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.24 0.19],[0.89 0.86]);

axes('position',[.24 .435 .2 .07]);
box on;
plot(t,x1d,'k','linewidth',1); hold on;
plot(t,ASMC_x1,'-.r','linewidth',1);
xlim([3.01,3.03]); set(gca,'XTick',3.01:0.01:3.03);
% ylim([8.3,8.7]); set(gca,'YTick',8.3:0.4:8.7);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.24 0.19],[.47 .45]);

pos = get( hAxis, 'Position' );
yposition=pos(2)+0.06;
pos(2)=yposition;
set(hAxis,'Position', pos);
% print -depsc F_x_dx_trackings2;
%%
% Compact trackings
% x0 and x1 trackings
figure; set(gcf,'Position',[0 0 800 200]);

plot(t,ASMC_E,'b','linewidth',1); hold on;
plot(t,ASMC_Phi,':m','linewidth',1.5); grid on;
plot(t,-ASMC_Phi,':m','linewidth',1.5);
ylim([-8,8]);set(gca,'YTick',-8:4:8);
legend({'ASMC {\it E}-trajectory','ASMC boundary layer'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');


axesH = gca;
set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
xlabel('Time (s)','interpreter','latex');
ylabel('Compact error','interpreter','latex');

% max(abs(ASMC_E)) % 3.437
% print -depsc F_E_trackings2;
%%
% Estimated parameters % -13.0 64.6
figure; set(gcf,'Position',[0 0 800 450]);
subplot(2,1,1);
% plot(t,Psi(:,1),'k','linewidth',1); hold on;
plot(t,Psi_hat(:,1),'k','linewidth',1); grid on;
% ylim([1.8,4.2]); set(gca,'YTick',1.8:0.6:4.2);
ylabel('Estimation of $\alpha_v$','interpreter','latex');
% legend({'True value $\alpha$','Estimated value $\hat{\alpha}$'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

hAxis=subplot(2,1,2);
% plot(t,Psi(:,2),'k','linewidth',1); hold on;
plot(t,Psi_hat(:,2),'k','linewidth',1); grid on;
ylim([1,2.2]); set(gca,'YTick',1:0.4:2.2);
ylabel('Estimation of $b_v$','interpreter','latex');
xlabel('Time (s)','interpreter','latex');
% legend({'True value $b$','Estimated value $\hat{b}$'},'fontsize',13,'interpreter','latex','location','NorthEast','orientation','horizontal');

for i=1:2
    subplot(2,1,i);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
end

pos = get( hAxis, 'Position' );
yposition=pos(2)+0.06;
pos(2)=yposition;
set(hAxis,'Position', pos);
% print -depsc F_alpha_b2;
