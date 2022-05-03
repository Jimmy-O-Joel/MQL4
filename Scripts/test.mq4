//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

    double accBal = AccountBalance();
    Alert(accBal); 
    Alert(Digits);
    Alert(_Digits);
    Alert(Point);
    Alert("The stop Level is: " + MarketInfo(Symbol(), MODE_STOPLEVEL));
   
  }
//+------------------------------------------------------------------+
