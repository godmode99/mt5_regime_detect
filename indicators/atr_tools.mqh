#ifndef ATR_TOOLS_MQH
#define ATR_TOOLS_MQH

//+------------------------------------------------------------------+
//| Calculate Average True Range (ATR)                               |
//| input:  rates[] - price series                                   |
//|         period  - number of bars for ATR calculation             |
//| output: ATR value                                                |
//+------------------------------------------------------------------+
double CalcATR(const MqlRates &rates[], const int period)
  {
   if(ArraySize(rates)<=period)
      return(0.0);
   double sum = 0.0;
   for(int i=0;i<period;i++)
     {
      double tr = rates[i].high - rates[i].low;
      if(i+1 < ArraySize(rates))
        {
         double diff1 = MathAbs(rates[i].high - rates[i+1].close);
         double diff2 = MathAbs(rates[i].low  - rates[i+1].close);
         tr = MathMax(tr, MathMax(diff1,diff2));
        }
      sum += tr;
     }
   return(sum/period);
  }

//+------------------------------------------------------------------+
//| Calculate standard deviation of closing prices                   |
//| input:  rates[] - price series                                   |
//|         period  - bars for calculation                            |
//| output: standard deviation                                       |
//+------------------------------------------------------------------+
double CalcStdDev(const MqlRates &rates[], const int period)
  {
   if(ArraySize(rates)<=period)
      return(0.0);
   double sum = 0.0;
   for(int i=0;i<period;i++)
      sum += rates[i].close;
   double mean = sum/period;
   double var = 0.0;
   for(int i=0;i<period;i++)
     {
      double diff = rates[i].close - mean;
      var += diff*diff;
     }
  return(MathSqrt(var/period));
  }

#ifdef ATR_STDDEV_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_label1  "ATR"
#property indicator_label2  "StdDev"

input int   InpATRPeriod    = 14;            // period for ATR
input int   InpStdPeriod    = 14;            // period for StdDev
input color InpATRColor     = clrDodgerBlue; // color for ATR line
input color InpStdColor     = clrOrange;     // color for StdDev line

double      g_atr_buffer[];
double      g_std_buffer[];
int         g_atr_handle = INVALID_HANDLE;
int         g_std_handle = INVALID_HANDLE;

int OnInit()
  {
   SetIndexBuffer(0,g_atr_buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"ATR");
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpATRColor);

   SetIndexBuffer(1,g_std_buffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"StdDev");
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpStdColor);

   g_atr_handle=iATR(_Symbol,_Period,InpATRPeriod);
   g_std_handle=iStdDev(_Symbol,_Period,InpStdPeriod,0,MODE_SMA,PRICE_CLOSE);
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
   int start=prev_calculated==0 ? 0 : prev_calculated-1;
   if(CopyBuffer(g_atr_handle,0,start,rates_total-start,g_atr_buffer)<=0)
      return(0);
   if(CopyBuffer(g_std_handle,0,start,rates_total-start,g_std_buffer)<=0)
      return(0);
   return(rates_total);
  }

#endif // ATR_STDDEV_OVERLAY_INDICATOR

#endif // ATR_TOOLS_MQH
