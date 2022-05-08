//+------------------------------------------------------------------+
//|                                            buy_trailing_stop.mq4 |
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
void    BuyTrailingStop(string argSymbol, int argTrailingStop, int argMinProfit, int argMagicNumber, double argPipPoint)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    //Calculate Max Stop and Min Profit
                    
                    double MaxStopLoss = MarketInfo(argSymbol, MODE_BID) - (argTrailingStop * argPipPoint);
                    
                    MaxStopLoss = NormalizeDouble(MaxStopLoss, (int)MarketInfo(argSymbol, MODE_DIGITS));
                    
                    double CurrStop = NormalizeDouble(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
                    
                    double PipsProfit = MarketInfo(argSymbol, MODE_BID) - OrderOpenPrice();
                    double MinProfit = argMinProfit * argPipPoint;
                    
                    //Modify Stop
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY && CurrStop < MaxStopLoss && PipsProfit >= MinProfit)
                        {
                            bool Trailed = OrderModify(OrderTicket(), OrderOpenPrice(), MaxStopLoss, OrderTakeProfit(), 0);
                            
                            if  (!Trailed)
                                {
                                    Print("Buy Trailing Stop - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(OrderTicket()) + " Stop: " + DoubleToString(OrderStopLoss()) + " Trail: " + DoubleToString(MaxStopLoss));
                                }
                        }
                }
        }
//+------------------------------------------------------------------+
