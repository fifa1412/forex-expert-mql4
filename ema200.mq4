//+------------------------------------------------------------------+
//|                                                       ema200.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input double lots =0.01; // Lots
string symbol = Symbol(); //Symbol
bool is_cross_up = false;
bool is_cross_down = false;
int ma_period = 200;
int ma_shift = 0;
int ma_method = MODE_EMA;
int applied_price = PRICE_MEDIAN;
int shift = 1;
int order_ticket = 0;
bool is_ordered = false;
input int slippage = 3; // Slippage
string comment = "ema200"; //Formula
bool is_buy = false;
bool is_sell = false;

void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+

// 1. check cross ema200 (how? morethan lessthan not enought)
// 2. open order when cross
void OnTick()
{
 string close_order_list = "";
 // double candle_close = iClose(symbol,PERIOD_H1,1);
 double open_price_bar = iOpen(symbol,PERIOD_H1,1); // get open price last bar
 double close_price_bar = iClose(symbol,PERIOD_H1,1); // get close price last bar
 
 double ema = iMA(symbol,PERIOD_H1,ma_period,ma_shift,ma_method,applied_price,shift);
 if (!is_ordered) {
    if (open_price_bar < ema && close_price_bar > ema) {
       // buy
       order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
       if(order_ticket > 0){
          printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
          is_ordered = true;
       }else{
          printf("Open Order FAILED " + (string)GetLastError());
       }
    }
    
    if (open_price_bar > ema && close_price_bar < ema) {
      // sell
      order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
       if(order_ticket > 0){
          printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
          is_ordered = true;
       }else{
          printf("Open Order FAILED " + (string)GetLastError());
       }
    }
 }
 //check close order
 for(int i = 0; i < OrdersTotal(); i++){
  if(OrderSelect(i, SELECT_BY_POS)==true){
   if(OrderSymbol() == symbol && OrderComment() == comment){
      if (OrderType() == OP_BUY) {
         if (open_price_bar > ema && close_price_bar < ema) {
            close_order_list += (string)OrderTicket()+",";
         }
      }
      
      if (OrderType() == OP_SELL) {
         if (open_price_bar < ema && close_price_bar > ema) {
            close_order_list += (string)OrderTicket()+",";
         }
      }
   }
  }
 }
 if(close_order_list != ""){
    string order_list_result[];
    ushort u_sep = StringGetCharacter(",",0);
    int total_order_list = StringSplit(close_order_list,u_sep,order_list_result);
    
    for(int i=0;i<total_order_list-1;i++){
      if(OrderSelect((int)order_list_result[i],SELECT_BY_TICKET)){
        if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
          printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
          is_ordered = false;
        }else{
          printf("Close Order FAILED " + (string)GetLastError());
        }
      }        
    }
 }

}