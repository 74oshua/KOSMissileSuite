function kill_order
{
    parameter targ.
    parameter speed.

    // check if we have a target selected
    if (hasTarget)
    {
        set con to targ:connection.

        // send a brief burn order to get the missile clear of the vessel
        set order to lexicon().
        order:add("orderauth", "password").
        order:add("ordertype", "burn").
        order:add("throttle", 1).
        order:add("time", 2).
        con:sendmessage(order).

        // send the kill order
        set order to lexicon().
        order:add("orderauth", "password").
        order:add("ordertype", "kill").
        order:add("target", target).
        order:add("speed", speed).
        con:sendmessage(order).

        print(targ:name + ": SENT KILL ORDER").
    }
    else
    {
        print(targ:name + ": NO TARGET SELECTED! ABORTING").
    }
}

set missile_name to ship:name + " Probe".
until (false)
{
    set ch to terminal:input:getchar().
    // kill order for selected target
    if (ch = "1")
    {
        list targets in targ_list.
        for targ in targ_list
        {
            if (targ:name = missile_name)
            {
                kill_order(targ, 200).
            }
        }
    }
    else if (ch = "2")
    {
        list targets in targ_list.
        for targ in targ_list
        {
            if (targ:name = missile_name)
            {
                kill_order(targ, 500).
            }
        }
    }
    else if (ch = "3")
    {
        list targets in targ_list.
        for targ in targ_list
        {
            if (targ:name = missile_name)
            {
                kill_order(targ, 1000).
            }
        }
    }
    // halt order
    else if (ch = "0")
    {
        list targets in targ_list.
        for targ in targ_list
        {
            if (targ:name = missile_name)
            {
                set con to targ:connection.
                set order to lexicon().
                order:add("orderauth", True).
                order:add("ordertype", "halt").
                con:sendmessage(order).
                print(targ:name + ": HALTING").
            }
        }
    }
}

