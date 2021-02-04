//+------------------------------------------------------------------+
//|                                                  ATR Percent.mq5 |
//|                    Copyright 2019-2021, Trade Like A Machine Ltd |
//|                                 http://www.tradelikeamachine.com |
//+------------------------------------------------------------------+

#property copyright   "2019-2021, Trade Like A Machine Ltd"
#property link        "http://www.tradelikeamachine.com"
#property description "TLAM Average True Range Percent"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "ATR Percent"

input int InpAtrPeriod=14;  // ATR period

double    Ext_ATR_Percent_Buffer[];
double    Ext_TR_Percent_Buffer[];

int       ExtPeriodATR;

void OnInit()
{
   if(InpAtrPeriod <= 0)
   {
      ExtPeriodATR = 14;
      PrintFormat("Incorrect input parameter InpAtrPeriod = %d. Indicator will use value %d for calculations.", InpAtrPeriod, ExtPeriodATR);
   }
   else
      ExtPeriodATR = InpAtrPeriod;

   SetIndexBuffer(0, Ext_ATR_Percent_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, Ext_TR_Percent_Buffer, INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_DIGITS, 5);
   
   //SET FIRAST BAR THAT CAN BE DRAWN
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ExtPeriodATR);
   
   //Name for DataWindow and indicator subwindow label
   string short_name=StringFormat("TLAM ATR Percent (%d)", ExtPeriodATR);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   PlotIndexSetString(0, PLOT_LABEL, short_name);
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
   if(rates_total <= ExtPeriodATR)
      return(0);

   int i,start;
   
   //Preliminary calculations
   if(prev_calculated == 0)
   {
      Ext_TR_Percent_Buffer[0] = 0.0;
      Ext_ATR_Percent_Buffer[0] = 0.0;
      
      //Fill array of True Range values for each period
      for(i = 1; i < rates_total && !IsStopped(); i++)
         Ext_TR_Percent_Buffer[i] = (MathMax(high[i], close[i-1]) - MathMin(low[i], close[i-1])) / close[i-1];
         
      //First AtrPeriod values of the indicator are not calculated
      double firstValue = 0.0;
      for(i = 1; i <= ExtPeriodATR; i++)
      {
         Ext_ATR_Percent_Buffer[i] = 0.0;
         firstValue += Ext_TR_Percent_Buffer[i];
      }
      
      //Calculate the first value of the indicator
      firstValue /= ExtPeriodATR;
      Ext_ATR_Percent_Buffer[ExtPeriodATR] = firstValue;
      start = ExtPeriodATR + 1;
   }
   else
      start = prev_calculated - 1;
   
   //Main loop of calculations
   for(i = start; i < rates_total && !IsStopped(); i++)
   {
      Ext_TR_Percent_Buffer[i] = (MathMax(high[i], close[i-1]) - MathMin(low[i], close[i-1])) / close[i-1];
      Ext_ATR_Percent_Buffer[i] = Ext_ATR_Percent_Buffer[i-1] + (Ext_TR_Percent_Buffer[i] - Ext_TR_Percent_Buffer[i - ExtPeriodATR]) / ExtPeriodATR;
   }
   
   return(rates_total);
  }
