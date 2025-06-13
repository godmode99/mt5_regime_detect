#ifndef SESSION_TOOLS_MQH
#define SESSION_TOOLS_MQH

//+------------------------------------------------------------------+
//| Determine current market session from time                       |
//| input:  time - timestamp to evaluate                              |
//| output: MarketSession enumeration                                 |
//+------------------------------------------------------------------+
MarketSession GetMarketSession(const datetime time)
  {
   int hour=TimeHour(time);
   if(hour<8)
      return(SESSION_ASIA);
   if(hour<16)
      return(SESSION_EUROPE);
   return(SESSION_US);
  }

//+------------------------------------------------------------------+
//| Flag if major news event is occurring                             |
//| input:  time - timestamp to check                                 |
//| output: true if news flag is active                               |
//+------------------------------------------------------------------+
bool IsNewsEvent(const datetime time)
  {
   // Placeholder implementation - always false
   return(false);
  }

#endif // SESSION_TOOLS_MQH
