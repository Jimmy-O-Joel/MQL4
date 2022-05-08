//+------------------------------------------------------------------+
//|                                         open_sell_stop_order.mq4 |
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
int     OpenSellStopOrder(string argSymbol, double argLotSize, double argPendingPrice, double argStopLoss, double argTakeProfit, int argSlippage, int argMagicNumber, datetime argExpiration = 0, string argComment = "Sell Stop Order")
        {
            while   (IsTradeContextBusy()) Sleep(10);
            
            //Place Sell Stop Order
            int Ticket = OrderSend(argSymbol, OP_SELLSTOP, argLotSize, argPendingPrice, argSlippage, argStopLoss, argTakeProfit, argComment, argMagicNumber, argExpiration, clrRed);
            
            //Error handling
            
            if  (Ticket == -1)
                {
                    Print("Open Sell Stop Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Lots: " + DoubleToString(argLotSize) + " Price: " + DoubleToString(argPendingPrice) + " Stop: " + DoubleToString(argStopLoss) + " Profit: " + DoubleToString(argTakeProfit) + " Expiration: " + TimeToString(argExpiration));
                }
            return Ticket;        
        }
//+------------------------------------------------------------------+
