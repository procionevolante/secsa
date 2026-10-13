#!/usr/bin/env octave-cli
% vim: filetype=matlab

%% history of gifts (i.e. past)

% row = gift giver
% column = gift receiver
%
% example for 1 year and 3 people (A, B and C):
%   A B C
% A 0 1 0 % A gifted a present to B
% B 0 0 1 % B gifted a present to C
% C 1 0 0 % C gifted a present to A

% TODO: read from a separate file
% 2024
% DEBUG: if things go as expected the script should return this combination, because even if it already happened in the past it's the one that minimizes recent repetitions.
% with more people the number of possible combinations grows
past(:,:,1) = [
    0, 1, 0;
    0, 0, 1;
    1, 0, 0;
];

% 2025
past(:,:,2) = [
    0, 0, 1;
    1, 0, 0;
    0, 1, 0;
];
names = [
    'A',
    'B',
    'C',
];

%% generate all possible giver - taker combinations
n_presents = size(past)(1);
possible = perms(1:n_presents);

% remove cases where (selfish) people give presents to themselves
for gifter = 1:n_presents
    possible = possible(possible(:,gifter) != gifter, :);
end

%% effort for each giver-taker-year combination

% num. of past years in history
n_years = size(past)(3);

% how much more difficult is for a gifter to give the same present to the
% giftee of x years in the past?
% NOTE: you may want to change this
weights = 1:n_years;

% repeat weights for each possible giver-taker-year
weights_m_full = zeros(n_presents, n_presents, n_years);
for y = 1:n_years
    weights_m_full(:,:,y) = ones(n_presents) .* weights(y);
end
% how much weight does it take to choose a particular giver-taker combination
weights_m = sum(weights_m_full .* past(:,:,:), 3);

%% calc effort for each possibility generated

n_possibilities = size(possible)(1);
poss_gift = zeros(n_presents, n_presents, n_possibilities);
effort = zeros(1, n_possibilities);

% if A,B,C should gift to x,y,z: effort = 
% A to x in 2026 ? * 3 + A to x in 2025? * 2 + A to x in 2024? * 1 +
% B to y in 2026 ? * 3 + B to y in 2025? * 2 + B to y in 2024? * 1 +
% C to z in 2026 ? * 3 + C to z in 2025? * 2 + C to z in 2024? * 1
for p = 1:n_possibilities
    poss_gift(:, :, p) = eye(n_presents)(:, possible(p, :));
    effort(p) = sum(sum(weights_m .* poss_gift(:, :, p)));
end

%% calc optimal possibilities (one or more)

best_possibilities = poss_gift(:, :, effort == min(effort));

if length(size(best_possibilities)) == 3
    chosen_possibility = best_possibilities(:, :, randi(size(best_possibilities)(3)));
else
    chosen_possibility = best_possibilities;
end

%% calculate output string

givers = names;
arrows = repmat(' --[should gift a present to]--> ', n_presents, 1);
% with one output, the indices are column-first: since we want them to be
% row-first, transpose the matrix
i_takers = mod(find(chosen_possibility') - 1, n_presents) + 1;
takers = names(i_takers, :);

disp([givers, arrows, takers]);
