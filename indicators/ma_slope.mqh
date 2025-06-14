#ifndef MA_SLOPE_MQH
#define MA_SLOPE_MQH

//+------------------------------------------------------------------+
//| Calculate slope of a simple moving average                        |
//| input:  rates[] - price series                                    |
//|         period  - number of bars for MA calculation               |
//| output: difference between current MA and previous period MA      |
//+------------------------------------------------------------------+
double GetMASlope(const MqlRates &rates[], const int period)
  {
   if(ArraySize(rates) <= period*2)
      return(0.0);
   double sum_recent = 0.0;
   for(int i=0;i<period;i++)
      sum_recent += rates[i].close;
   double sum_prev = 0.0;
   for(int i=period;i<period*2;i++)
      sum_prev += rates[i].close;
   double ma_recent = sum_recent/period;
   double ma_prev   = sum_prev/period;
   return(ma_recent - ma_prev);
  }

#ifdef MA_SLOPE_DISPLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_label1  "MA"

input int   InpMAPeriod      = 20;          // moving average period
input color InpUpColor       = clrLime;     // positive slope color
input color InpDownColor     = clrRed;      // negative slope color

double g_ma_buffer[];
double g_color_buffer[];
double g_slope_buffer[];
int    g_ma_handle = INVALID_HANDLE;

int OnInit()
  {
   SetIndexBuffer(0,g_ma_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,g_color_buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,g_slope_buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"MA");
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpUpColor);

   g_ma_handle = iMA(_Symbol,_Period,InpMAPeriod,0,MODE_SMA,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start = prev_calculated==0 ? 0 : prev_calculated-1;
   if(CopyBuffer(g_ma_handle,0,start,rates_total-start,g_ma_buffer)<=0)
      return(0);

   for(int i=start;i<rates_total;i++)
     {
      if(i+1<rates_total)
         g_slope_buffer[i] = g_ma_buffer[i] - g_ma_buffer[i+1];
      else
         g_slope_buffer[i] = 0.0;
      g_color_buffer[i] = (g_slope_buffer[i]>=0.0) ? InpUpColor : InpDownColor;
     }
   return(rates_total);
  }

#endif // MA_SLOPE_DISPLAY_INDICATOR

#endif // MA_SLOPE_MQH
