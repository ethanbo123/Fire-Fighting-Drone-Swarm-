% driver.m - Entry point for Fire-Fighting Drone Swarm
clear; clc; close all; 
rng(42); 

%% Initialize parameters
% Returns params struct with all simulation settings
params = make_params();

%% Initialize fire environment
% Creates fire struct with intensity matrix [0,1]
fire = init_fire(params);

%% Initialize drones
% Creates array of drone structs with positions, targets, and logs
drones = startup_drones(params);

%% Visualization setup
figure('Name', 'Firefighting Drone Swarm Simulation', 'Position', [100, 100, 800, 600]);

%% Main simulation loop
step_counter = 0;
simulation_running = true;

fprintf('=== Firefighting Drone Swarm Simulation ===\n');
fprintf('Grid size: %dx%d\n', params.grid_rows, params.grid_cols);
fprintf('Number of drones: %d\n', params.num_drones);
fprintf('Time step: %.2f seconds\n', params.dt);
fprintf('Max steps: %d\n', params.max_steps);
fprintf('Fire intensity threshold: %.2f\n\n', params.fire_threshold);

while simulation_running && step_counter < params.max_steps
    step_counter = step_counter + 1;
    current_time = step_counter * params.dt;
    
    % Fire dynamics update 
    % Step 1: Orthogonal spread from burning cells (N,S,E,W)
    % Step 2: Global decay
    % Step 3: Clamp to [0,1]
    fire = fire_step(fire, params);
    
    % Update each drone's target assignment
    % Assign targets before movement to coordinate drone actions
    for i = 1:length(drones)
        % Check if drone needs a new target
        % (no target OR target cell no longer burning)
        if isempty(drones(i).firecell) || ~cell_has_fire(fire, drones(i).firecell, params)
            drones(i).firecell = assign_target(fire, drones(i), drones, params);
        end
    end
    
    %Apply collision avoidance BEFORE movement
    % Ensures no two drones occupy same cell at any time
    drones = detect_avoidance(drones, params);
    
    %Update each drone's position and actions
    for i = 1:length(drones)
        % Move drone toward target and handle water drop
        drones(i) = update_drone(drones(i), fire, params, current_time);
        
        % Check if drone is within water drop distance
        if ~isempty(drones(i).firecell)
            drone_pos = drones(i).location;
            target_pos = drones(i).firecell;
            distance_to_target = norm(drone_pos - target_pos);
            
            if distance_to_target <= params.water_drop_distance
                row = round(target_pos(1));
                col = round(target_pos(2));
                
                % Validate cell bounds
                if row >= 1 && row <= params.grid_rows && col >= 1 && col <= params.grid_cols
                    % Check if cell still has fire
                    if fireEnviro(row, col) > 0
                        % Drop water: set intensity to 0 immediately
                        fire(row, col) = 0;
                        drones(i).cells_extinguished = drones(i).cells_extinguished + 1;
                        drones(i).time_active = current_time;
                        
                        % Log the extinguish event
                        drones(i).log_events{end+1} = sprintf('t=%.2f: Extinguished cell (%d,%d)', ...
                            current_time, row, col);
                    end
                end
                
                % Clear target so drone can find next hotspot
                drones(i).firecell = [];
            end
        end
    end
    
    %% Check stopping condition: all cells below threshold
    max_intensity = max(fireEnviro(:));
    if max_intensity < params.fire_threshold
        fprintf('\nAll fires extinguished at step %d (time = %.2f s)!\n', step_counter, current_time);
        simulation_running = false;
    end
    
    %% Visualization (update periodically for performance)
    if mod(step_counter, params.plot_interval) == 0 || ~simulation_running
        plot_state(fire, drones, params, step_counter, current_time);
        drawnow;
        
        % Display progress to console
        num_burning_cells = sum(fireEnviro(:) >= params.fire_threshold);
        fprintf('Step %4d (t=%6.2f s): Max intensity = %.3f, Burning cells = %3d\n', ...
            step_counter, current_time, max_intensity, num_burning_cells);
    end
end

% Check if Simulation ended 

if step_counter >= params.max_steps && simulation_running
    fprintf('\nSimulation ended: Maximum time steps reached.\n');
end

% Generate and display summary
fprintf('\n=== Simulation Complete ===\n');
fprintf('Total time steps: %d/n', step_counter);
fprintf('Total Simulation time: %2.f seconds\n', step_counter * params.dt);

summary_table = summarize_results(drones, params, step_counter);

%display the Summary table
disp(' ');
disp('\nDrone Performance Summary:');
disp(summary_table);

%% Save results to files
% Create output directory if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end

% Save CSV of summary table (required output)
csv_filename = 'output/drone_summary.csv';
writetable(summary_table, csv_filename);
fprintf('\nSummary CSV saved to: %s\n', csv_filename);

% Save MAT file with core data for reproducibility (required output)
mat_filename = 'output/simulation_data.mat';
save(mat_filename, 'fire', 'drones', 'params', 'step_counter');
fprintf('Simulation MAT file saved to: %s\n', mat_filename);

% Save final visualization
fig_filename = 'output/final_state.png';
saveas(gcf, fig_filename);
fprintf('Final state figure saved to: %s\n', fig_filename);

fprintf('\n=== Driver script completed successfully ===\n');


    

  
