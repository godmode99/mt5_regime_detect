#ifndef SESSION_TOOLS_MQH
#define SESSION_TOOLS_MQH

//+------------------------------------------------------------------+
//| Determine current market session from time                       |
//| input:  time - timestamp to evaluate                              |
//| output: MarketSession enumeration                                 |
//+------------------------------------------------------------------+
MarketSession GetMarketSession(const datetime time);

//+------------------------------------------------------------------+
//| Flag if major news event is occurring                             |
//| input:  time - timestamp to check                                 |
//| output: true if news flag is active                               |
//+------------------------------------------------------------------+
bool IsNewsEvent(const datetime time);

#endif // SESSION_TOOLS_MQH
