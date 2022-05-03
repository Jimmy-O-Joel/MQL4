//+------------------------------------------------------------------+
//|                                                 BBandReentry.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//inputs
//
//Bands
//

input int InpBandsPeriods = 20; // Bands periods
input double InpBandDeviations = 2.0; // bands deviations
input ENUM_APPLIED_PRICE InpBandsAppliedPrice = PRICE_CLOSE; // bands applied price

//
//TPSL
//
input double InpTPDeviations = 1.0;  //Take profit deviations
input double InpSLDeviations = 1.0;  // Stop Loss deviations

//
//Standard inputs
//
input double InpVolume = 0.01;   //lot size
input int InpMagicNumber = 202020;  // Magic number
input string InpTradeComment = __FILE__;  //Trade comment



int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (!IsNewBar()) return;
   
   double close1 = iClose(Symbol(), Period(), 1);
   double high1 = iHigh(Symbol(), Period(), 1);
   double low1 = iLow(Symbol(), Period(), 1);
   
   double upper1 = iBands(Symbol(), Period(), InpBandsPeriods, InpBandDeviations, 0, InpBandsAppliedPrice, MODE_UPPER, 1);
   
   double lower1 = iBands(Symbol(), Period(), InpBandsPeriods, InpBandDeviations, 0, InpBandsAppliedPrice, MODE_LOWER, 1);
   
   double close2 = iClose(Symbol(), Period(), 2);
   
   double upper2 = iBands(Symbol(), Period(), InpBandsPeriods, InpBandDeviations, 0, InpBandsAppliedPrice, MODE_UPPER, 2);
   
   double lower2 = iBands(Symbol(), Period(), InpBandsPeriods, InpBandDeviations, 0, InpBandsAppliedPrice, MODE_LOWER, 2);
   
   
   if (close2 > upper2 && close1<upper1) { //reentry from above = sell
   
        OpenOrder(ORDER_TYPE_SELL_STOP, low1, (upper1-lower1));
   
   }
   
   if (close2<lower2 && close1>lower1) {  //reentry from below = buy
   
        OpenOrder(ORDER_TYPE_BUY_STOP, high1, (upper1-lower1));
   
   }
   return;
}
   
   
   bool IsNewBar() {
   
        //Open time for current bar
        datetime currentBarTime = iTime(Symbol(), Period(), 0);
        static datetime prevBarTime = currentBarTime;  //static - initialization only happens the first time this function is called after the
                                                        // EA is started
        
        if (prevBarTime<currentBarTime){  //new bar opened
            
            prevBarTime = currentBarTime; //Update prev time before exit
            
            return true;
        }
        return false;
   }
   
int OpenOrder(ENUM_ORDER_TYPE orderType, double entryPrice, double channelWidth) {

    //size of one deviation
    double deviation = channelWidth/(2*InpBandDeviations);
    double tp = deviation * InpTPDeviations;
    double sl = deviation * InpSLDeviations;
    datetime expiration = iTime(Symbol(), Period(), 0) + PeriodSeconds() -1;
    
    entryPrice = NormalizeDouble(entryPrice, Digits());
    double tpPrice = 0.0;
    double slPrice = 0.0;
    double price = 0.0;
    
    double stopsLevel = Point() * SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
    
    
    if (orderType%2 == ORDER_TYPE_BUY) { //Buy, buystop
    
        price = Ask;
        if (price >=(entryPrice-stopsLevel)) {
            entryPrice = price;
            orderType = ORDER_TYPE_BUY;
            
        }
        tpPrice = NormalizeDouble(entryPrice+tp, Digits());
        slPrice = NormalizeDouble(entryPrice - sl, Digits());
    
    }else if (orderType%2==ORDER_TYPE_SELL){ //sell, sellstop
        price = Bid;
        if (price<=(entryPrice+stopsLevel)) {
            entryPrice = price;
            orderType = ORDER_TYPE_SELL;
            
        }
        tpPrice = NormalizeDouble(entryPrice-tp, Digits());
        slPrice = NormalizeDouble(entryPrice+sl, Digits());
    
    }else {
        return 0;
    
    }
    
    return OrderSend(Symbol(), orderType, InpVolume, entryPrice, 0, slPrice, tpPrice, InpTradeComment, InpMagicNumber, expiration);

}

//+------------------------------------------------------------------+
