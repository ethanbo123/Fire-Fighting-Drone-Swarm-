function fireEnviroCopy = spreadFire(fireEnviro)
    % spreadFire simulates one step of fire spreading in a grid.
    % fireEnviro is a matrix where 1 = fire, 0 = no fire.
    % fireEnviroCopy is the updated matrix after spreading.

    [rows, cols] = size(fireEnviro);
    fireEnviroCopy = fireEnviro; % copy input

    % Directions: up, right, down, left
    directions = [-1, 0; 0, 1; 1, 0; 0, -1];

    for i = 1:rows
        for j = 1:cols

            % Skip already burning cells
            if fireEnviro(i, j) == 1
                continue
            end

            fireCount = 0;

            % Check all 4 directions
            for d = 1:4
                ni = i + directions(d, 1);
                nj = j + directions(d, 2);

                % Check within grid bounds
                if ni >= 1 && ni <= rows && nj >= 1 && nj <= cols
                    if fireEnviro(ni, nj) == 1
                        fireCount = fireCount + 1;
                    end
                end
            end

            % Determine fire spread chance
            spread = fireCount * 0.15;

            if rand() < spread
                fireEnviroCopy(i, j) = 1;
            end
        end
    end
end
