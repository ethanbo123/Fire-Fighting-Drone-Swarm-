function [fireEnviroCopy, drones] = droneFireControl(fireEnviro, drones)
% droneFireControl moves drones toward nearest fires and extinguishes them.
%
% Inputs:
%   fireEnviro - matrix (1 = fire, 0 = no fire)
%   drones - struct array with fields:
%       id, speed, position = [row, col]
%
% Outputs:
%   fireEnviroCopy - updated fire grid
%   drones - updated drone positions

    [rows, cols] = size(fireEnviro);
    fireEnviroCopy = fireEnviro;

    numDrones = numel(drones);

    % Keep track of new drone positions to avoid overlaps
    newPositions = zeros(numDrones, 2);

    for k = 1:numDrones
        pos = drones(k).position;
        r = pos(1);
        c = pos(2);

        % Find all fires
        [fireRows, fireCols] = find(fireEnviroCopy == 1);

        if isempty(fireRows)
            % No fires left
            newPositions(k, :) = [r, c];
            continue
        end

        % Compute distances to all fires
        distances = sqrt((fireRows - r).^2 + (fireCols - c).^2);

        % Find nearest fire
        [~, idx] = min(distances);
        target = [fireRows(idx), fireCols(idx)];

        % Move one step toward the target fire
        stepR = sign(target(1) - r);
        stepC = sign(target(2) - c);

        newR = r + stepR;
        newC = c + stepC;

        % Keep within grid bounds
        newR = max(1, min(rows, newR));
        newC = max(1, min(cols, newC));

        % Avoid collisions: if another drone is already taking that spot, stay put
        occupied = ismember(newPositions(1:k-1, :), [newR, newC], 'rows');
        if any(occupied)
            newR = r;
            newC = c;
        end

        % Update position
        newPositions(k, :) = [newR, newC];

        % If the drone is on a fire, extinguish it
        if fireEnviroCopy(newR, newC) == 1
            fireEnviroCopy(newR, newC) = 0;
        end
    end

    % Update drone positions in struct
    for k = 1:numDrones
        drones(k).position = newPositions(k, :);
    end
end