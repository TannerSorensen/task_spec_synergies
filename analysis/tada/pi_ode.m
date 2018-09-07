function dx = pi_ode(t,x, cos_height, cos_start_time, cos_rise_dur, cos_hold_dur, cos_fall_dur, stif_gate)

if x >= cos_start_time & x <= cos_start_time+cos_rise_dur+cos_hold_dur+cos_fall_dur
    if x < cos_start_time + cos_rise_dur
        pi_act = cos_height*(cos(pi*(x-cos_start_time)/cos_rise_dur+pi)+1)/2;
    elseif x < cos_start_time+cos_rise_dur+cos_hold_dur
        pi_act = cos_height*1;
    else
        pi_act = cos_height*(cos(pi*(x-cos_start_time-cos_rise_dur-cos_hold_dur)/cos_fall_dur)+1)/2;
    end
else
    pi_act = 0;
end

dx = -stif_gate*pi_act + 1;