// awaits an order from a mothership running missile-manager.ks

set main_engine to 0.

// fixed loop
until (0 > 1)
{
    wait until (not ship:messages:empty).

    set message to ship:messages:pop.

    // check if message is an order
    if (message:content:istype("Lexicon"))
    {
        // carry out instructions in order
        local order to message:content.
        if (order:haskey("orderauth") and order:orderauth = "password" and order:haskey("ordertype"))
        {
            execute_order(order).
        }
    }
}

function set_engine
{
    list engines in engine_list.
    for engine in engine_list
    {
        set main_engine to engine.
        break.
    }
}

function thresh
{
    parameter a.
    parameter b.
    parameter val.
    parameter t.

    if (val >= t)
    {
        return a.
    }
    return b.
}

function execute_order
{
    parameter order.

    if (order:ordertype = "kill" and order:haskey("target"))
    {
        print("KILL ORDER RECEIVED FOR " + order:target:name).
        set kill_target to order:target.

        set_engine().
        sas off.

        main_engine:activate().
        lock rel_pos to kill_target:position - ship:position.
        lock rel_vel to kill_target:velocity:orbit - ship:velocity:orbit.
        lock lat_vel to vXcl(rel_pos, rel_vel).
        lock vel_err to ((kill_target:velocity:orbit + rel_pos:normalized * order:speed + lat_vel) - ship:velocity:orbit) / sqrt(rel_pos:mag) * 2.
        lock target_steering to vel_err.
        lock steering to target_steering.
        lock throttle to max(vDot(ship:facing:forevector, vel_err), 0) ^ 2. // * (vel_err:mag / (main_engine:availablethrust / ship:mass)).

        rcs on.
        SET steeringmanager:rolltorquefactor TO 0.01.
    }
    else if (order:ordertype = "halt")
    {
        if (order:halt = true)
        {
            print("HALT ORDER RECEIVED").
            set kill_target to "".
            lock throttle to 0.
            lock steering to ship:facing.
        }
    }
    // burns in a specified direction at a given throttle value for a given length of time
    // direction: vector or direction to burn (optional, defaults to forevector)
    // throttle: what value the throttle should be set to for the burn (optional, defaults to full)
    // time: duration of the burn (optional, if not given burn will continue until another command is given)
    else if (order:ordertype = "burn")
    {
        set_engine().
        main_engine:activate().

        if (order:haskey("direction"))
        {
            lock target_steering to order:direction.
        }
        else
        {
            lock target_steering to ship:facing:forevector.
        }
        lock steering to target_steering.

        lock alignment to vDot(ship:facing:forevector, target_steering).

        if (order:haskey("throttle"))
        {
            lock throttle to order:throttle * alignment.
        }
        else
        {
            lock throttle to alignment.
        }

        if (order:haskey("time"))
        {
            wait order:time.
        }
    }
}
