# ASMC
Matlab code for the paper "An adaptive sliding mode control system and its application in real-time hybrid simulation"

Case 1:
Run main_fun.m

Case 2 RTHS benchmark
1. Run Actuator_id.m to plot the frequency response of the orignal and reduced models of the control plant.
2. Run main_ANSMC.m to get Evaluation criteria for the control systems: NSMC and ASMC.
3. Run main_PI.m to get Evaluation criteria for the control system: PI.
4. Run Elcentro_results.m to plot the responses under El Centro earthquake.

Notes in case 2:
1. The designated displacement, velocity and acceleration (all relative to the ground) of the physical substructure are required for the sliding mode controller. However the original released code of the benchmark problem only gives designated displacement. Additional operations to obtain designated velocity and acceleration from the numerical substructure are added/modified and marked in F1_input_file.m and vRTHS_MDOF_SimRT.slx.
2. A saturation block is added to make sure the actuator force does not exceed 8900 N.

If you have any problems, please contact hongweili@seu.edu.cn
