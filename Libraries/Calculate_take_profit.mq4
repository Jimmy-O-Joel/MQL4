//+------------------------------------------------------------------+
//|                                        Calculate_take_profit.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
double CalculateTakeProfit(int argOrderType, double entryPrice, int pips, double argPipPoint)
{
   double takeProfit = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      takeProfit = entryPrice + pips * argPipPoint;
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      takeProfit = entryPrice - pips * argPipPoint;
      
   }
   return NormalizeDouble(takeProfit, Digits);
}
//+------------------------------------------------------------------+

