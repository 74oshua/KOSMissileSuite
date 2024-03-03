// searches for any objects on a collision course and burns perpendicualr to the incoming threat

set active_threat to false.
set main_engine to 0.

function set_engine
{
    list engines in engine_list.
    for engine in engine_list
    {
        set main_engine to engine.
        break.
    }
}

until (false)
{
    set active_threat to false.
    list targets in targ_list.
    for targ in targ_list
    {
        set rel_vel to targ:velocity:orbit - ship:velocity:orbit.
        set rel_pos to ship:position - targ:position.
        set speed to rel_vel:mag.
        set alignment to vDot(rel_vel:normalized, (ship:position - targ:position):normalized).
        set distance to rel_pos:mag.
        set accel to vDot(targ:facing:forevector, rel_pos:normalized) * (targ:thrust / targ:mass).
        if (alignment > 0.9 and distance / speed < 3600)
        {
            set active_threat to true.
            if (accel > 0)
            {
                set t to (-speed + sqrt(2 * accel * distance + speed * speed)) / accel.
            }
            else
            {
                set t to distance / speed.
            }
            print(targ:name + " ON APPROACH! (~" + round(t, 2) + " seconds, " + round(accel, 2) + " m/s^2)").

            // prepare to burn perpendicular to incoming threat
            lock steering to vCrs(rel_pos:normalized, ship:prograde:forevector).

            if (t < 3)
            {
                set_engine().
                main_engine:activate().
                print("FULL BURN!").
                lock throttle to 1.
            }
        }
    }

    if (active_threat)
    {
        wait 0.2.
    }
    else
    {
        unlock throttle.
        unlock steering.
        wait 1.
    }
}