clc, clear, close all

real_time = 'n';
plot_on = 'n';
eq_intensity = .4;           % EQ Intensity 
                             %   1: El centro, 2: Kobe, 3: Morgan,  4: Chirp input
f_ini = 0;                   % Chirp initial freq. [Hz] 
f_end = 10;                  % Chirp end freq. [Hz]

fs = 4096;              % Sampling frequency [Hz]
dt_rths = 1/fs;         % Sampling period [sec]
load_system('vRTHS_NSMC.slx')
load_system('vRTHS_ASMC.slx')  
switch lower(real_time)
    case 'y'
        set_param('vRTHS_NSMC/Real-Time Synchronization','Commented','off')
        set_param('vRTHS_NSMC/Missed Ticks','Commented','off') 
        set_param('vRTHS_ASMC/Real-Time Synchronization','Commented','off')
        set_param('vRTHS_ASMC/Missed Ticks','Commented','off')      
    case 'n'
        set_param('vRTHS_NSMC/Real-Time Synchronization','Commented','on')
        set_param('vRTHS_NSMC/Missed Ticks','Commented','on')
        set_param('vRTHS_ASMC/Real-Time Synchronization','Commented','on')
        set_param('vRTHS_ASMC/Missed Ticks','Commented','on')
end

num_add = 0; %num_add = 5;
num_t = 1+num_add;
E_swN=1; Building_cN=1; %E_swN=4; Building_cN=4;
J=cell(1,E_swN);
caseN=2*E_swN*Building_cN*num_t;
disp([num2str(caseN),' cases totally.'])
disp('Processing ...')
for E_sw=1:E_swN
    J{E_sw}=zeros(2*num_t,9,Building_cN);
    for Building_c=1:Building_cN
        for ii = 1:num_t
            F1_input_file
            sw=1; % 0 means without boundary layer; 1 means with.
            F2_controller
            F3_simulation_NSMC
            F4_evaluation
            J{E_sw}(2*ii-1,:,Building_c)=eval_crit;
            casei=((E_sw-1)*Building_cN+Building_c-1)*num_t*2+2*ii-1;
            caseratio=casei/caseN*100;
            disp(['Case ',num2str(casei),' is done (',num2str(caseratio),'%).'])
            
            z1=1600; z2=2;
            Psi_hat0=(alpha_hat0-[z1,z2])';
            theta0=0.1; k0=1000000;
            F3_simulation_ASMC
            F4_evaluation
            J{E_sw}(2*ii,:,Building_c)=eval_crit;
            casei=casei+1;
            caseratio=casei/caseN*100;
            disp(['Case ',num2str(casei),' is done (',num2str(caseratio),'%).'])
        end
    end
end