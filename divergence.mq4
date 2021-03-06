//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, NoHopz Software Corp."
#property link      "https://www.nohopz.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
   printf("Hello World");
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

   double lots =0.1; // Lots
   double stop_loss =2; // Stop Loss
   double take_profit =2; // Take Profit
   int slippage = 3; // Slippage
   string comment = "Divergence"; //Formula
   string symbol = Symbol(); //Symbol
   int period = 14; //Period 
   double fix_min_rsi = 23.6;
   double fix_max_rsi = 76.4;
   double close_price_start = 0;
   double close_price_end = 0;
   double rsi_start = 0;
   double rsi_end = 0;
   bool start_is_ok = false;
   bool m5_is_ok = false;
   
void OnTick()
  {
//---
   // get max rsi > 76.4
   double temp_rsi_m5 = iRSI(symbol,PERIOD_M5,period,PRICE_CLOSE,0);
   double temp_close_price_m5 = iClose(symbol,PERIOD_M5,1);
   double temp_rsi_m1_s0 = iRSI(symbol,PERIOD_M1,period,PRICE_CLOSE,0);
   double temp_rsi_m1_s1 = iRSI(symbol,PERIOD_M1,period,PRICE_CLOSE,1);
   
   if(start_is_ok){
      if(m5_is_ok){
         if(temp_rsi_m1_s0 > temp_rsi_m1_s1){
            if(temp_rsi_m5 > rsi_end){
               rsi_end = temp_rsi_m5;
               close_price_end = temp_close_price_m5;
            }
         }else{
            // open order 
            if(rsi_start > rsi_end && close_price_start < close_price_end){
               order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,NormalizeDouble(Bid-stop_loss*Point,Digits),NormalizeDouble(Bid+take_profit*Point,Digits),comment,0,0,clrNONE);
            }else if(rsi_end > rsi_start && close_price_end < close_price_start){
               order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,NormalizeDouble(Bid-stop_loss*Point,Digits),NormalizeDouble(Bid+take_profit*Point,Digits),comment,0,0,clrNONE);
            }
            start_is_ok = false;
            rsi_start = rsi_end;
            close_price_start = close_price_end;
            m5_is_ok = false;
         }
      }else{
         if(temp_rsi_m5 > fix_max_rsi){
           m5_is_ok = true;
           rsi_end = temp_rsi_m5;
           close_price_end = temp_close_price_m5;
         }
      }
   }else{
      //initial
      if(temp_rsi_m5 > fix_max_rsi){
         if(temp_rsi_m5 > rsi_start){
            rsi_start  = temp_rsi_m5;
            close_price_start = temp_close_price_m5;
        }
      }else if(temp_rsi_m5 <= fix_max_rsi){
         start_is_ok = true;
      }
   }
   
   

  }
//+------------------------------------------------------------------+
