//+------------------------------------------------------------------+
//|                                              add_stop_profit.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
bool    AddStopProfit(int argTicket, double argStopLoss, double argTakeProfit)
        {
            if  (argStopLoss == 0 && argTakeProfit == 0) return false;
            
            
            if  (OrderSelect(argTicket, SELECT_BY_TICKET) == false)
                {
                    Print("Order select returned the error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
            
            double OpenPrice = OrderOpenPrice();
            
            while   (IsTradeContextBusy()) Sleep(10);
            
            //Modify Order
            
            bool TicketMod = OrderModify(argTicket, OpenPrice, argStopLoss, argTakeProfit, 0);
            
            //Error handling 
            
            if  (TicketMod == false)
                {
                    Print("Add Stop/Profit Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
                
             return TicketMod;   
        }
//+------------------------------------------------------------------+

