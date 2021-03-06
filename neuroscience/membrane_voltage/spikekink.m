function [ kink_vm, max_dvdt, kink_index] = spikekink(spike_trace, t_vec, spike_indexes)
% SPIKEKINK - find the "kink" inflection point in spike waveforms, and maximum dv/dt after Azouz and Gray 1999
%
% [KINK_VM, MAX_DVDT, KINK_INDEX_] = SPIKEKINK(SPIKE_TRACE, T, SPIKE_INDEXES, ...)
%
% Inputs:        
% SPIKE_TRACE     | 1D vector containing values for voltage at every
%                      timestep in spike_trace (units V)
% T_VEC           | 1D vector containing timestamps in seconds
% SPIKE_INDEXES   | Index values of approximate spike peaks in SPIKE_TRACE
%
% Calculates the "kink" in spike waveforms where spike begins to take off.
% See Azouz and Gray, J. Neurosci 1999.
%
% SPIKE_LOCATIONS that are greater than 
%
% Outputs:
% KINK_VM         | Vector of voltage at each spike kink
% MAX_DVDT        | Vector of maximum DV/DT for each spike
% KINK_INDEX      | Vector of sample number of each spike kink
% 
% This function also takes additional parameters in the form of name/value
% pairs.
%
% Parameter (default)     | Description
% ---------------------------------------------------------------
% slope_criterion (0.033) | Fraction of peak dV/dt, calibrated by visual
%                         |    inspection to match threshold
% search_interval (0.004) | How much before each spike_location to begin
%                         |    the search for the kink
%
% Jason Osik 2016-2017, slight mods by SDV
%

slope_criterion = 0.033;
use_detrend = 1;
restore_DC = 1;
search_samples  = 0.004;

assign(varargin{:});

%*******Assess biophysical spike threshold using Azouz & Gray, 1999
    %*******methods****************************************************
    %******************************************************************

sample_interval = t_vec(2)-t_vec(1);

vt_slope = gradient(spike_trace,sample_interval); 

  % create outputs
kink_index = [];
max_dvdt = [];

search_samples = max(1,ceil(search_interval/sample_interval));

for q=1:length(spike_indexes),
	% only examine this spike if we have the ability to search backward
	if spike_indexes(q)>search_samples, 
		% find the max slope and index value where the kink occurs

		search_pad = (spike_indexes(q)-search_samples):spike_indexes(q)-1;
		[max_slope,peak_ind] = max(vt_slope(search_pad)); 
		max_dvdt(end+1,1) = max_slope(1);

		% now look for the best match for the kink, but only search from peak_slope backward
		search_pad(peak_ind+1:end) = [];
			% find point closest to target slope value
		[~,th_ind] = min(abs(   (slope_criterion*max_slope)-vt_slope(search_pad,1)    ));
		kink_index(end+1,1) = search_pad(1,1)+th_ind-1;
	end
end

kink_vm = spike_trace(kink_index);


