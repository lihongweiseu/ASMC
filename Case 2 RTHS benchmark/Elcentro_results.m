clc, clear, close all

real_time = 'n';
eq_intensity = .4;           % EQ Intensity 
                             %   1: El centro, 2: Kobe, 3: Morgan,  4: Chirp input
f_ini = 0;                   % Chirp initial freq. [Hz] 
f_end = 10;                  % Chirp end freq. [Hz]

fs = 4096;              % Sampling frequency [Hz]
dt_rths = 1/fs;         % Sampling period [sec]
num_add = 0;
num_t = 1+num_add;
E_sw=1; Building_c=4;
ii=1; F1_input_file
ii=2; F1_input_file

load_system('vRTHS_PI.slx')
load_system('vRTHS_NSMC.slx')
load_system('vRTHS_ASMC.slx')
switch lower(real_time)
    case 'y'
        set_param('vRTHS_PI/Real-Time Synchronization','Commented','off')
        set_param('vRTHS_PI/Missed Ticks','Commented','off')
        set_param('vRTHS_NSMC/Real-Time Synchronization','Commented','off')
        set_param('vRTHS_NSMC/Missed Ticks','Commented','off')
        set_param('vRTHS_ASMC/Real-Time Synchronization','Commented','off')
        set_param('vRTHS_ASMC/Missed Ticks','Commented','off')
    case 'n'
        set_param('vRTHS_PI/Real-Time Synchronization','Commented','on')
        set_param('vRTHS_PI/Missed Ticks','Commented','on')
        set_param('vRTHS_NSMC/Real-Time Synchronization','Commented','on')
        set_param('vRTHS_NSMC/Missed Ticks','Commented','on')
        set_param('vRTHS_ASMC/Real-Time Synchronization','Commented','on')
        set_param('vRTHS_ASMC/Missed Ticks','Commented','on')
end
F2_controller_PI

set_param(bdroot,'SolverType','Fixed-step','Solver','ode4','StopTime','tend','FixedStep','dt_rths')
sim ('vRTHS_PI')
RTHS_PI=Num_resp.Data;

sw=1; % 0 means without boundary layer; 1 means with.
F2_controller
set_param(bdroot,'SolverType','Fixed-step','Solver','ode4','StopTime','tend','FixedStep','dt_rths')
sim ('vRTHS_NSMC')
RTHS_NSMC=Num_resp.Data;

z1=1600; z2=2;
Psi_hat0=(alpha_hat0-[z1,z2])';
theta0=0.1; k0=1000000;
set_param(bdroot,'SolverType','Fixed-step','Solver','ode4','StopTime','tend','FixedStep','dt_rths')
sim ('vRTHS_ASMC')
RTHS_ASMC=Num_resp.Data;
Ref_Resp = lsim(sys_r,EQ_input,t);

%%
figure; set(gcf,'Position',[0 0 800 240]);
plot(t,Ref_Resp(:,3)*1000,'k','linewidth',1); hold on;
plot(t,RTHS_NSMC(:,3)*1000,'--c','linewidth',1); grid on;
plot(t,RTHS_ASMC(:,3)*1000,'-.r','linewidth',1);
xlim([0,40]);
axesH = gca;
set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
% set(axesH,'fontsize',13,'TickLabelInterpreter','latex');axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
ylabel('Displacement (mm)','fontsize',13,'interpreter','latex');
xlabel('Time (s)','fontsize',13,'interpreter','latex');
legend({'Reference model','NSMC','ASMC'},...
    'fontsize',13,'interpreter','latex','location','Northeast','orientation','horizontal');

axes('position',[.135 .7 .11 .2]);
box on;
plot(t,Ref_Resp(:,3)*1000,'k','linewidth',1); hold on;
plot(t,RTHS_NSMC(:,3)*1000,'--c','linewidth',1); grid on;
plot(t,RTHS_ASMC(:,3)*1000,'-.r','linewidth',1);
xlim([7.4,7.42]); %set(gca,'XTick',3.08:0.01:3.10);
% ylim([0.54,0.561]); %set(gca,'YTick',0.54:0.02:0.56);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.245 0.27],[0.82 0.82]);

axes('position',[.655 .19 .11 .2]);
box on;
plot(t,Ref_Resp(:,3)*1000,'k','linewidth',1); hold on;
plot(t,RTHS_NSMC(:,3)*1000,'--c','linewidth',1); grid on;
plot(t,RTHS_ASMC(:,3)*1000,'-.r','linewidth',1);
xlim([28.4,28.7]); %set(gca,'XTick',3.08:0.01:3.10);
% ylim([0.54,0.561]); %set(gca,'YTick',0.54:0.02:0.56);
set(gca,'ytick',[]);
set(gca,'xtick',[]);
annotation('arrow',[0.685 0.685],[0.39 0.53]);

% print -depsc F_ELcentro_case4;
%%
% Estimated parameters
alpha_hat=squeeze(alpha_hat);
figure; set(gcf,'Position',[0 0 800 220]);

subplot(1,2,1);
plot(t',alpha_hat(1,:),'k','linewidth',1); grid on;
% ylim([5.42e4,5.5e4]); set(gca,'YTick',5.42e4:200:5.5e4);
ylabel('$\hat{\alpha}_1$ ($\rm s^{-2}$)','interpreter','latex');

subplot(1,2,2);
plot(t',alpha_hat(2,:),'k','linewidth',1); grid on;
% ylim([160,320]); set(gca,'YTick',160:40:320);
ylabel('$\hat{\alpha}_2$ ($\rm s^{-1}$)','interpreter','latex');

for i=1:2
    subplot(1,2,i);
    xlim([0,40]);
    axesH = gca;
    set(axesH,'fontsize',13,'TickLabelInterpreter','latex');
%     axesH.XAxis.TickLabelFormat ='\\textbf{%g}';axesH.YAxis.TickLabelFormat ='\\textbf{%g}';
    xlabel('Time (s)','interpreter','latex');
end
% print -depsc F_alpha12;