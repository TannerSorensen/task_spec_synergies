function mod_pulse = make_mod(srate, f0, frame_dur, AV)

samps_per_frame = floor((frame_dur/1000)*srate);

i = 1;
next_frame = 1;
samples = 1;

nframes = length(f0);
tot_samples = nframes * samps_per_frame;
mod_pulse = ones(1, tot_samples);


while next_frame <= length(f0)
    period(i) = fix((1/f0(next_frame))*srate);
    samples = samples + period(i);
    if AV(next_frame)~=0
        half2nd_zero = samples- ceil(period(i)/2) : samples-1;
        mod_pulse(half2nd_zero) = zeros(1, length(half2nd_zero));
    end
    next_frame = ceil(samples/samps_per_frame);
    i = i+1;
end