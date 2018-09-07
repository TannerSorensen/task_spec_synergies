timescale=1;
ms_frm = 10;
t_final = 2;
t_scaled_pos_init = 0;

height=1;
start_time=22; rise_dur=0; hold_dur=16; fall_dur=0;

stif_gate = .6;

cos_height=height;
cos_start_time=start_time*ms_frm/1000;
cos_rise_dur=rise_dur*ms_frm/1000;
cos_hold_dur=hold_dur*ms_frm/1000;
cos_hold_dur=cos_hold_dur*timescale;
cos_fall_dur=fall_dur*ms_frm/1000;
cos_fall_dur=cos_fall_dur*timescale;

options = odeset('AbsTol', [], 'RelTol', [], 'MaxStep', .001, 'InitialStep', .001, 'refine', 1);
[t,x] = ode45(@pi_ode,[0 t_final],[pos_init], options, cos_height, cos_start_time, cos_rise_dur, cos_hold_dur, cos_fall_dur, stif_gate);
figure(2)
plot([x t])