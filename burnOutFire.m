function fireEnviroCopy = burnOutFire(fireEnviro)
    % burnOutFire simulates some burning cells going out each timestep
    % fireEnviro: matrix where 1 = fire, 0 = no fire
    % fireEnviroCopy: updated grid after burnout

    [rows, cols] = size(fireEnviro);
    fireEnviroCopy = fireEnviro;  % make a copy

    for i = 1:rows
        for j = 1:cols
            if fireEnviro(i, j) == 1
                burnOut = 0.1 + rand() * 0.08;  % 0.1–0.18 chance
                if rand() < burnOut
                    fireEnviroCopy(i, j) = 0;   % fire burns out
                end
            end
        end
    end
end


