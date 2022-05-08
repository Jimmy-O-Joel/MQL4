//+------------------------------------------------------------------+
//|                                         open_buy_limit_order.mq4 |
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
int     OpenBuyLimitOrder(string argSymbol, double argLotSize, double argPendingPrice, double argStopLoss, double argTakeProfit, int argSlippage, int argMagicNumber, datetime argExpiration = 0, string argComment = "Buy Limit Order")
        {
            while   (IsTradeContextBusy()) Sleep(10);
            
            //Place Buy Stop Order
            int Ticket = OrderSend(argSymbol, OP_BUYLIMIT, argLotSize, argPendingPrice, argSlippage, argStopLoss, argTakeProfit, argComment, argMagicNumber, argExpiration, clrGreen);
            
            //Error handling
            
            if  (Ticket == -1)
                {
                    Print("Open Buy Limit Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)) + " Lots: " + DoubleToString(argLotSize) + " Price: " + DoubleToString(argPendingPrice) + " Stop: " + DoubleToString(argStopLoss) + " Profit: " + DoubleToString(argTakeProfit) + " Expiration: " + TimeToString(argExpiration));
                }
            return Ticket;        
        }
//+------------------------------------------------------------------+
