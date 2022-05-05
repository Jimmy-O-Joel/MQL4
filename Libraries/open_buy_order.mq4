//+------------------------------------------------------------------+
//|                                               open_buy_order.mq4 |
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
int     OpenBuyOrder(string argSymbol, double argLotSize, int argSlippage, int argMagicNumber, string argComment = "Buy Order")
        {
            while (IsTradeContextBusy()) Sleep(10);
            
            //Place Buy Order
            
            int Ticket = OrderSend(argSymbol, OP_BUY, argLotSize, MarketInfo(argSymbol, MODE_ASK), argSlippage, 0, 0, argComment, argMagicNumber, 0, clrGreen);
            
            //Error Handling
            
            if  (Ticket == -1)
                {
                    Print("Open buy Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + "Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)) + "Lots: " + DoubleToString(argLotSize));
                }
            return Ticket;
        }
//+------------------------------------------------------------------+
