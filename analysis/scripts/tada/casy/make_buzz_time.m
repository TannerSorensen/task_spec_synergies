function [buzz, t] = make_buzz_time (srate, f0, dur)
%  make_buzz_time
%  Louis Goldstein
%  5 Feb 2003
%
%  make a 500 ms pulse train
%
%  input argument
%       srate   sampling rate in Hz
%       f0      fundamental frequency in Hz
%       dur     duratin in seconds

totsamps = dur*srate;
samps_per_cycle = fix((1/f0) * srate);
buzz = (rem([0:totsamps], samps_per_cycle) == 0);
t = 0:1/srate:dur;
