function sendtrigger(address, valueTrigger)

    outp(address,valueTrigger);
    WaitSecs(0.001);
    outp(address,0);