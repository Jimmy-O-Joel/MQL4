//+------------------------------------------------------------------+
//|                                        close_all_sell_orders.mq4 |
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
void    CloseAllSellOrders(string argSymbol, int argMagicNumber, int argSlippage)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                        {
                            //Close Order
                            int CloseTicket = OrderTicket();
                            double CloseLots = OrderLots();
                            
                            while   (IsTradeContextBusy()) Sleep(10);
                            
                            double ClosePrice = MarketInfo(argSymbol, MODE_ASK);
                            
                            bool Closed = OrderClose(CloseTicket, CloseLots, ClosePrice, argSlippage, clrRed);
                            
                            //Error handling
                            
                            if  (!Closed)
                                {
                                    Print("Close All Sell Orders - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(CloseTicket) + " Price: " + DoubleToString(ClosePrice));
                                }
                            else i--;
                        }
                }
        }
//+------------------------------------------------------------------+
