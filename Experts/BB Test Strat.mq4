//+------------------------------------------------------------------+
//|                                                BB Test Strat.mq4 |
//|                                           jimmyjoel177@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jimmyjoel177@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <CustomFunction.mqh>

int magicNumber = 12120;  
int bbPeriod = 20;
int band1Std = 1;
int band2Std = 4;
double riskPerTrade = 0.02;
int ticket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    Alert("");
    Alert("The EA has started");
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Alert("The EA has has closed");
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
    
    
    Alert("");
    
    Alert(MarketInfo(NULL, MODE_STOPLEVEL));

   double bbLower1 = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpper1 = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_UPPER,0);
   double bbMid = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,0,0);
   
   double bbLower2 = iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpper2 = iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_UPPER,0);
   
   if (!CheckIfOpenOrdersByMagicNumber(magicNumber)) {
       if(Ask < bbLower1)//buying
       {
          Alert("Price is bellow bbLower1, Sending buy order");
          double stopLossPrice = NormalizeDouble(bbLower2,Digits);
          double takeProfitPrice = NormalizeDouble(bbMid,Digits);
          Alert("Entry Price = " + Ask);
          Alert("Stop Loss Price = " + stopLossPrice);
          Alert("Take Profit Price = " + takeProfitPrice);
          
          double lotSize = OptimalLotSize(riskPerTrade, Ask, stopLossPrice);
          
          //Send buy order
          
          ticket = OrderSend(NULL, OP_BUYLIMIT, lotSize, Ask, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
          
          if (ticket > 0) {
            Print("OrderSend placed successfully");
          }else {
            Print("OrderSend failed with error #" + GetLastError());
          }
       }
       else if(Bid > bbUpper1)//shorting
       {
          Alert("Price is above bbUpper1, Sending short order");
          double stopLossPrice = NormalizeDouble(bbUpper2,Digits);
          double takeProfitPrice = NormalizeDouble(bbMid,Digits);
          Alert("Entry Price = " + Bid);
          Alert("Stop Loss Price = " + stopLossPrice);
          Alert("Take Profit Price = " + takeProfitPrice);
          
          double lotSize = OptimalLotSize(riskPerTrade, Bid, stopLossPrice);
    	  
    	  //Send short order
    	  
    	  ticket = OrderSend(NULL, OP_SELLLIMIT, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
          
          if (ticket > 0) {
            Print("OrderSend placed successfully");
          }else {
            Print("OrderSend failed because " + ErrorDescription(GetLastError()));
          }
       } else { // j already in a position, update orders if required
           if (OrderSelect(ticket, SELECT_BY_TICKET)) {
               int orderType = OrderType(); // 0 - Long, 1 - short
               double currExitPoint;
               
               double currMidLine = NormalizeDouble(bbMid, Digits);
               
               double TP = OrderTakeProfit();
               double SL = OrderStopLoss();
               
               if (TP != currMidLine) { //modify order
                   bool ans = OrderModify(ticket, OrderOpenPrice(), SL, currMidLine, 0);
                   
                   if (ans) Alert("Order #" + ticket + " modified successfully");
               }
           }
       
       }
            
       }
   
   
}
//+------------------------------------------------------------------+

