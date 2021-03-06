//+------------------------------------------------------------------+
//|                                          calculate_stop_loss.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
double CalculateStopLoss(int argOrderType, double entryPrice, int argStopLoss, double argPipPoint)
{
   double stopLoss = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      stopLoss = entryPrice - argStopLoss * argPipPoint;
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      stopLoss = entryPrice + argStopLoss * argPipPoint;
   }
   return NormalizeDouble(stopLoss, Digits);
}
//+------------------------------------------------------------------+
