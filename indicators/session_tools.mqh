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
   /*
      Check the built‑in economic calendar for high impact events
      scheduled around the provided timestamp.  news_flag in the
      feature struct is set to true when at least one high importance
      release occurs within the specified window.  RegimeMasterEA.mq5
      simply calls this helper for each bar time.
   */

   const int window_minutes = 30;          // \u00b1 30 minute range
   datetime from = time - window_minutes*60;
   datetime to   = time + window_minutes*60;

   //--- request calendar values for the symbol base currency
   string base = StringSubstr(_Symbol,0,3);        // e.g. "EURUSD" -> "EUR"
   MqlCalendarValue values[];
   ArraySetAsSeries(values,true);

   int total = CalendarValueHistory(base,from,to,values);
   if(total<=0)
      return(false);

   //--- check each event's importance via CalendarEventById
   for(int i=0;i<total;i++)
     {
      MqlCalendarEvent ev;
      if(CalendarEventById((int)values[i].event_id,ev)==0)
         continue;
      if(ev.importance==CALENDAR_IMPORTANCE_HIGH)
         return(true);           // high impact news found
     }

   return(false);
  }

#endif // SESSION_TOOLS_MQH
