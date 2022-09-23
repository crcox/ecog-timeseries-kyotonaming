% SESSION_RANGE
% Input
%  tags     Cell array of ticks indicating when experiment events happen
%  baseline The size of the desired baseline epoch in ticks
%  trial    The size of the trial epoch in ticks
%  boxcar   The size of the boxcar for downsampling in ticks
%
% Returns
%  ranges The beginning and end of each session in ticks
%  ticks  The number of ticks per session after processing
%  ix     The ticks that belong to sessions
%
% A tick is a discrete time-step, indexing from an initial measurement.
% Ticks are integer values, and index directly into values in the
% timeseries.
function [ranges, ticks, ix] = session_range(tags, baseline, trial, boxcar)
    ranges = [
        tags{1}(1) - baseline, tags{1}(end) + (2 * trial)
        tags{2}(1) - baseline, tags{2}(end) + (2 * trial)
        tags{3}(1) - baseline, tags{3}(end) + (2 * trial)
        tags{4}(1) - baseline, tags{4}(end) + (2 * trial)
    ];
    
    % Small differences in session length may appear (+/- a few ms).
    % Sessions will be further truncated so that session length is a multiple
    % of boxcar window (for downsampling).
    ticks_0 = diff(ranges');
    ranges(:, 2) = ranges(:, 2) - (ticks_0 - min(ticks_0))';
    ticks_1 = diff(ranges');
    ticks_trunc = mod(ticks_1, boxcar);
    ranges(:, 2) = ranges(:, 2) - ticks_trunc(:);
    ticks = diff(ranges');
    ticks = ticks(1);
    
    ix = zeros(sum(ticks), 1);
    cur = 0;
    for i = 1:size(ranges, 1)
        a = cur + 1;
        b = cur + ticks;
        tmp = ranges(i, 1):(ranges(i, 2) - 1);
        ix(a:b) = tmp;
        cur = b;
    end
end