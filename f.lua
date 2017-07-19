Account = "SPBFUT00b13"
trans_id = 111
Comm_Fut = 2
Comm_Opt = 3
Year = 365
Fut = "SiM7"
Put = "Si56500BR7"
NFO = 5
Delta = 0
Min_Profit = 0
Max_Profit = 0
FL_Open = 0
FL_Num = 0
FL_Lin = 0
FL_Close = 0
FL_Num_Cl = 0
FL_Lin_Cl = 0
FL_Pr = {}
FL_Op = 0
FL_Cl = 0
P_Open = 0
P_Num = 0
P_Lin = 0
P_Close = 0
P_Num_Cl = 0
P_Lin_Cl = 0
P_Pr = {}
P_Op = 0
P_Cl = 0
Deal = 0
Curr_Hist = 0
Close = 0
Trading = 0
Level = 1
Menu = 0
is_run = true
Timer = os.clock()

function OnInit(scriptname)
  Name = scriptname:match(".+\\(.+).lua")
  local f = io.open(getScriptPath() .. "//" .. Name .. ".txt", "r+")
  if f ~= nil then
    local Count = 0
    for line in f:lines() do
      Count = Count + 1
      if Count == 1 then
        Arr = String(line)
        Account = Arr.s1
        Fut = Arr.s2
        Put = Arr.s3
      elseif Count == 2 then
        Arr = Number(line)
        trans_id = Arr.n1
        Comm_Fut = Arr.n2
        Comm_Opt = Arr.n3
        Year = Arr.n4
        NFO = Arr.n5
        Delta = Arr.n6
        Min_Profit = Arr.n7
        Max_Profit = Arr.n8
      elseif Count == 3 then
        Arr = Number(line)
        Deal = Arr.n1
        Curr_Hist = Arr.n2
        Close = Arr.n3
        Trading = Arr.n4
        Level = Arr.n5
        Menu = Arr.n6
      elseif Count == 4 then
        Arr = Number(line)
        FL_Open = Arr.n1
        FL_Num = Arr.n2
        FL_Lin = Arr.n3
        FL_Close = Arr.n4
        FL_Num_Cl = Arr.n5
        FL_Lin_Cl = Arr.n6
      elseif Count == 5 then
        Arr = Number(line)
        P_Open = Arr.n1
        P_Num = Arr.n2
        P_Lin = Arr.n3
        P_Close = Arr.n4
        P_Num_Cl = Arr.n5
        P_Lin_Cl = Arr.n6
      elseif Count > 5 and Count <= 5 + Level then
        Arr = Number(line)
        FL_Pr[Count - 5] = Arr.n1
        P_Pr[Count - 5] = Arr.n2
      end
    end
    f:close()
  else
    FL_Pr[1] = 0
    P_Pr[1] = 0
  end
  Account_Text = Account .. "|"
  Account_Cursor = #tostring(Account)
  trans_id_Text = trans_id .. "|"
  trans_id_Cursor = #tostring(trans_id)
  Year_Text = Year .. "|"
  Year_Cursor = #tostring(Year)
  Fut_Text = Fut .. "|"
  Fut_Cursor = #tostring(Fut)
  Put_Text = Put .. "|"
  Put_Cursor = #tostring(Put)
  Comm_Fut_Text = Comm_Fut .. "|"
  Comm_Fut_Cursor = #tostring(Comm_Fut)
  Comm_Opt_Text = Comm_Opt .. "|"
  Comm_Opt_Cursor = #tostring(Comm_Opt)
  NFO_Text = NFO .. "|"
  NFO_Cursor = #tostring(NFO)
  if Menu == 0 then
    CreateTableMenu()
  end
  CreateTable()
end
function main()
  while is_run do
    F_Status = tonumber(getParamEx("SPBFUT", Fut, "status").param_value)
    F_Bid = tonumber(getParamEx("SPBFUT", Fut, "bid").param_value)
    F_Offer = tonumber(getParamEx("SPBFUT", Fut, "offer").param_value)
    F_Curr = RoundToStep((F_Bid + F_Offer) / 2)
    P_Theor = tonumber(getParamEx("SPBOPT", Put, "theorprice").param_value)
    Day = tonumber(getParamEx("SPBOPT", Put, "days_to_mat_date").param_value)
    if F_Curr > 0 and P_Theor > 0 and Day > 0 then
      P = Opt(Put)
      if 0 < P_Open and 0 < P_Num then
        PCurr = P_Open
      else
        PCurr = P.Curr
      end
      if Close == 1 then
        if 0 < P_Close and 0 < P_Num_Cl then
          PCurr = P_Close
        else
          PCurr = P.Curr
        end
      end
      FL_Volume = 0
      FL_Price = 0
      FL_Profit = 0
      P_Volume = 0
      P_Price = 0
      P_Profit = 0
      P_Delta = 0
      P_Theta = 0
      for i = 1, Level do
        if 0 < FL_Pr[i] then
          FL_Volume = FL_Volume + 1
          FL_Price = FL_Price + FL_Pr[i]
          FL_Profit = FL_Profit + F_Curr - FL_Pr[i]
        end
        if 0 < P_Pr[i] then
          P_Volume = P_Volume + 1
          P_Price = P_Price + P_Pr[i]
          P_Profit = P_Profit + PCurr - P_Pr[i]
        end
      end
      FL_Price = Round(FL_Price / FL_Volume, 0)
      P_Price = Round(P_Price / P_Volume, 0)
      All_Profit = FL_Profit + P_Profit + Curr_Hist
      D = Round(FL_Volume - P_Volume * P.P_Delta, 2)
      if Level == FL_Volume or Level == P_Volume then
        Level = Level + 1
        FL_Pr[Level] = 0
        P_Pr[Level] = 0
      end
      SetCell(t_id, 1, 0, tostring(P.P_Delta))
      SetCell(t_id, 1, 2, tostring(NFO))
      SetCell(t_id, 1, 3, tostring(Min_Profit))
      SetCell(t_id, 1, 4, tostring(Max_Profit))
      Gray(t_id, 1, 3)
      Gray(t_id, 1, 4)
      Gray(t_id, 1)
      SetCell(t_id, 1, 5, tostring(Delta))
      Position(2, Fut, F_Curr, FL_Volume, FL_Price, FL_Profit)
      SetCell(t_id, 2, 5, tostring(D))
      if FL_Open == -1 or FL_Close == -1 then
        Gray(t_id, 2, 0)
      end
      Position(3, Put, PCurr, P_Volume, P_Price, P_Profit)
      SetCell(t_id, 3, 5, tostring(P_Volume * P.P_Theta))
      if P_Open == -1 or P_Close == -1 then
        Gray(t_id, 3, 0)
      end
      SetCell(t_id, 4, 0, tostring(Day) .. "/" .. os.date("%X"))
      SetCell(t_id, 4, 3, tostring(Curr_Hist))
      Str(4, 4, FL_Profit + P_Profit)
      Str(4, 5, All_Profit)
      if Menu == 1 and F_Status == 1 then
        Green(t_id, 4, 0)
        if Close == 0 and Trading == 0 then
          for i = 1, Level do
            if FL_Open == 0 and FL_Num == 0 and FL_Pr[i] == 0 then
              FL_Op = i
            end
            if P_Open == 0 and P_Num == 0 and P_Pr[i] == 0 then
              P_Op = i
            end
          end
          if 0 < P_Op and P_Open == 0 and P_Num == 0 and (P_Volume < Round(1 / P.P_Delta, 0) or D >= Delta and P_Volume < Round(NFO / P.P_Delta, 0)) then
            TransOpt(Put, "\207\238\234\243\239\234\224", P.Curr, 1)
          end
          if (D < Delta or P_Open < P.Bid) and 0 < P_Open and 0 < P_Num then
            Kill(Put, "LOpen", P_Num)
          end
          if 0 < FL_Op and FL_Open == 0 and FL_Num == 0 and (P_Volume >= Round(1 / P.P_Delta, 0) and FL_Volume == 0 or D < Delta and FL_Volume < NFO) then
            TransFut("Long", "\207\238\234\243\239\234\224", F_Curr, 1)
          end
          if (D >= Delta or FL_Open < F_Bid) and 0 < FL_Open and 0 < FL_Num then
            Kill(Fut, "LOpen", FL_Num)
          end
        end
      else
        Red(t_id, 4, 0)
      end
    else
      SetCell(t_id, 4, 0, "No price - wait")
      Red(t_id, 4, 0)
    end
    sleep(100)
  end
end
function CreateTableMenu()
  t_id_Menu = AllocTable()
  AddColumn(t_id_Menu, 0, "", true, QTABLE_STRING_TYPE, 17)
  AddColumn(t_id_Menu, 1, "", true, QTABLE_STRING_TYPE, 17)
  AddColumn(t_id_Menu, 2, "", true, QTABLE_STRING_TYPE, 17)
  AddColumn(t_id_Menu, 3, "", true, QTABLE_STRING_TYPE, 17)
  CreateWindow(t_id_Menu)
  SetWindowCaption(t_id_Menu, Name .. "//roboforts.ru")
  SetWindowPos(t_id_Menu, 682, 322, 391, 188)
  for i = 1, 9 do
    InsertRow(t_id_Menu, i)
  end
  SetCell(t_id_Menu, 1, 0, "\209\247\229\242")
  SetCell(t_id_Menu, 1, 1, tostring(Account))
  SetCell(t_id_Menu, 2, 0, "\185 \242\240\224\237\231\224\234\246\232\233")
  SetCell(t_id_Menu, 2, 1, tostring(trans_id))
  SetCell(t_id_Menu, 3, 0, "\196\237\229\233 \226 \227\238\228\243")
  SetCell(t_id_Menu, 3, 1, tostring(Year))
  Gray(t_id_Menu, 4)
  SetCell(t_id_Menu, 5, 0, "Fut")
  SetCell(t_id_Menu, 5, 1, tostring(Fut))
  SetCell(t_id_Menu, 7, 0, "Put")
  SetCell(t_id_Menu, 7, 1, tostring(Put))
  SetCell(t_id_Menu, 2, 2, "\204\232\237 \239\240\238\244\232\242")
  SetCell(t_id_Menu, 2, 3, tostring(Min_Profit))
  SetCell(t_id_Menu, 3, 2, "\204\224\234\241 \239\240\238\244\232\242")
  SetCell(t_id_Menu, 3, 3, tostring(Max_Profit))
  SetCell(t_id_Menu, 5, 2, "\202\238\236 \244\252\254\247\229\240\241\224")
  SetCell(t_id_Menu, 5, 3, tostring(Comm_Fut))
  SetCell(t_id_Menu, 6, 2, "\202\238\236 \238\239\246\232\238\237\224")
  SetCell(t_id_Menu, 6, 3, tostring(Comm_Opt))
  SetCell(t_id_Menu, 7, 2, "NFO")
  SetCell(t_id_Menu, 7, 3, tostring(NFO))
  SetCell(t_id_Menu, 8, 2, "\196\229\235\252\242\224")
  SetCell(t_id_Menu, 8, 3, tostring(Delta))
  SetCell(t_id_Menu, 9, 0, "\209\210\192\208\210")
  Blue(t_id_Menu, 9, 0)
  SetTableNotificationCallback(t_id_Menu, OnClick)
end
function CreateTable()
  t_id = AllocTable()
  AddColumn(t_id, 0, "Fut/Put", true, QTABLE_STRING_TYPE, 17)
  AddColumn(t_id, 1, "Current", true, QTABLE_INT_TYPE, 9)
  AddColumn(t_id, 2, "Volume", true, QTABLE_INT_TYPE, 6)
  AddColumn(t_id, 3, "Price", true, QTABLE_INT_TYPE, 9)
  AddColumn(t_id, 4, "Profit", true, QTABLE_INT_TYPE, 11)
  AddColumn(t_id, 5, "Total", true, QTABLE_INT_TYPE, 11)
  CreateWindow(t_id)
  SetWindowCaption(t_id, Name .. "//roboforts.ru")
  SetWindowPos(t_id, 682, 209, 368, 113)
  for i = 1, 4 do
    InsertRow(t_id, i)
  end
  SetCell(t_id, 1, 1, "\204\229\237\254")
  Blue(t_id, 1, 1)
  SetTableNotificationCallback(t_id, OnClick)
end
function OnClick(id, event, line, column)
  if event == QTABLE_LBUTTONUP then
    if id == t_id_Menu then
      Account_Inputing = false
      SetCell(t_id_Menu, 1, 1, tostring(Account))
      trans_id_Inputing = false
      SetCell(t_id_Menu, 2, 1, tostring(trans_id))
      Year_Inputing = false
      SetCell(t_id_Menu, 3, 1, tostring(Year))
      Fut_Inputing = false
      SetCell(t_id_Menu, 5, 1, tostring(Fut))
      Put_Inputing = false
      SetCell(t_id_Menu, 7, 1, tostring(Put))
      Comm_Fut_Inputing = false
      SetCell(t_id_Menu, 5, 3, tostring(Comm_Fut))
      Comm_Opt_Inputing = false
      SetCell(t_id_Menu, 6, 3, tostring(Comm_Opt))
      NFO_Inputing = false
      SetCell(t_id_Menu, 7, 3, tostring(NFO))
      if line == 1 and column == 1 then
        Account_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 2 and column == 1 then
        trans_id_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 3 and column == 1 then
        Year_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 5 and column == 1 then
        Fut_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 7 and column == 1 then
        Put_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 5 and column == 3 then
        Comm_Fut_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 6 and column == 3 then
        Comm_Opt_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 7 and column == 3 then
        NFO_Inputing = true
        BlueAtten(t_id_Menu, line, column)
      elseif line == 9 and column == 0 then
        Menu = 1
        DestroyTable(t_id_Menu)
      end
    end
    if id == t_id and line == 1 and column == 1 then
      Menu = 0
      KillAll()
      DestroyTable(t_id_Menu)
      CreateTableMenu()
    end
  elseif event == QTABLE_CHAR then
    if Account_Inputing then
      Arr = Parameter(1, 1, column, Account_Text, Account_Cursor)
      Account_Text = Arr.text
      Account_Cursor = Arr.cursor
      Account = tostring(Arr.param)
    end
    if trans_id_Inputing then
      Arr = Parameter(2, 1, column, trans_id_Text, trans_id_Cursor)
      trans_id_Text = Arr.text
      trans_id_Cursor = Arr.cursor
      trans_id = tonumber(Arr.param)
    end
    if Year_Inputing then
      Arr = Parameter(3, 1, column, Year_Text, Year_Cursor)
      Year_Text = Arr.text
      Year_Cursor = Arr.cursor
      Year = tonumber(Arr.param)
    end
    if Fut_Inputing then
      Arr = Parameter(5, 1, column, Fut_Text, Fut_Cursor)
      Fut_Text = Arr.text
      Fut_Cursor = Arr.cursor
      Fut = tostring(Arr.param)
    end
    if Put_Inputing then
      Arr = Parameter(7, 1, column, Put_Text, Put_Cursor)
      Put_Text = Arr.text
      Put_Cursor = Arr.cursor
      Put = tostring(Arr.param)
    end
    if Comm_Fut_Inputing then
      Arr = Parameter(5, 3, column, Comm_Fut_Text, Comm_Fut_Cursor)
      Comm_Fut_Text = Arr.text
      Comm_Fut_Cursor = Arr.cursor
      Comm_Fut = tonumber(Arr.param)
    end
    if Comm_Opt_Inputing then
      Arr = Parameter(6, 3, column, Comm_Opt_Text, Comm_Opt_Cursor)
      Comm_Opt_Text = Arr.text
      Comm_Opt_Cursor = Arr.cursor
      Comm_Opt = tonumber(Arr.param)
    end
    if NFO_Inputing then
      Arr = Parameter(7, 3, column, NFO_Text, NFO_Cursor)
      NFO_Text = Arr.text
      NFO_Cursor = Arr.cursor
      NFO = tonumber(Arr.param)
    end
  elseif event == QTABLE_CLOSE and id == t_id_Menu then
    OnStop()
  end
end
function Parameter(line, column, key_code, text, cursor)
  if key_code >= 32 and key_code <= 126 or key_code >= 192 and key_code <= 255 then
    if cursor == 0 then
      text = string.char(key_code) .. "|"
    else
      text = string.sub(text, 1, cursor) .. string.char(key_code) .. "|"
    end
    cursor = cursor + 1
    param = string.sub(text, 1, cursor)
    SetCell(t_id_Menu, line, column, text)
  elseif key_code == 8 and cursor > 0 then
    text = string.sub(text, 1, cursor - 1) .. "|"
    cursor = cursor - 1
    param = string.sub(text, 1, cursor)
    if cursor == 0 then
      param = 0
    end
    SetCell(t_id_Menu, line, column, text)
  end
  return {
    text = text,
    cursor = cursor,
    param = param
  }
end
function Cursor()
  if os.clock() - Timer >= 0.5 then
    if Account_Inputing then
      Account_Text = Curs(1, 1, Account_Text, Account_Cursor)
    elseif trans_id_Inputing then
      trans_id_Text = Curs(2, 1, trans_id_Text, trans_id_Cursor)
    elseif Year_Inputing then
      Year_Text = Curs(3, 1, Year_Text, Year_Cursor)
    elseif Fut_Inputing then
      Fut_Text = Curs(5, 1, Fut_Text, Fut_Cursor)
    elseif Put_Inputing then
      Put_Text = Curs(7, 1, Put_Text, Put_Cursor)
    elseif Comm_Fut_Inputing then
      Comm_Fut_Text = Curs(5, 3, Comm_Fut_Text, Comm_Fut_Cursor)
    elseif Comm_Opt_Inputing then
      Comm_Opt_Text = Curs(6, 3, Comm_Opt_Text, Comm_Opt_Cursor)
    elseif NFO_Inputing then
      NFO_Text = Curs(7, 3, NFO_Text, NFO_Cursor)
    end
  end
end
function Curs(line, column, text, cursor)
  if string.sub(text, cursor + 1, cursor + 1) == "|" then
    text = string.gsub(text, "|", " ")
    SetCell(t_id_Menu, line, column, text)
    Timer = os.clock()
  else
    text = string.gsub(text, " ", "|")
    SetCell(t_id_Menu, line, column, text)
    Timer = os.clock()
  end
  return text
end
function OnStop()
  is_run = false
  KillAll()
  SaveCurrentState()
end
function KillAll()
  if F_Status == 1 then
    if FL_Open > 0 and 0 < FL_Num then
      Kill(Fut, "LOpen", FL_Num)
    end
    FL_Open = 0
    FL_Num = 0
    FL_Lin = 0
    if 0 < FL_Close and 0 < FL_Num_Cl then
      Kill(Fut, "LClose", FL_Num_Cl)
    end
    FL_Close = 0
    FL_Num_Cl = 0
    FL_Lin_Cl = 0
    White(t_id, 2, 0)
    if 0 < P_Open and 0 < P_Num then
      Kill(Put, "LOpen", P_Num)
    end
    P_Open = 0
    P_Num = 0
    P_Lin = 0
    if 0 < P_Close and 0 < P_Num_Cl then
      Kill(Put, "LClose", P_Num_Cl)
    end
    P_Close = 0
    P_Num_Cl = 0
    P_Lin_Cl = 0
    White(t_id, 3, 0)
  end
end
function SaveCurrentState()
  local f = io.open(getScriptPath() .. "//" .. Name .. ".txt", "w")
  f:write(Account .. ";" .. Fut .. ";" .. Put .. "\n")
  f:write(trans_id .. ";" .. Comm_Fut .. ";" .. Comm_Opt .. ";" .. Year .. ";" .. NFO .. ";" .. Delta .. ";" .. Min_Profit .. ";" .. Max_Profit .. "\n")
  f:write(Deal .. ";" .. Curr_Hist .. ";" .. Close .. ";" .. Trading .. ";" .. Level .. ";" .. Menu .. "\n")
  f:write(FL_Open .. ";" .. FL_Num .. ";" .. FL_Lin .. ";" .. FL_Close .. ";" .. FL_Num_Cl .. ";" .. FL_Lin_Cl .. "\n")
  f:write(P_Open .. ";" .. P_Num .. ";" .. P_Lin .. ";" .. P_Close .. ";" .. P_Num_Cl .. ";" .. P_Lin_Cl .. "\n")
  for i = 1, Level do
    f:write(FL_Pr[i] .. ";" .. P_Pr[i] .. "\n")
  end
  f:flush()
  f:close()
end
function String(line)
  local i = 0
  for str in line:gmatch("[^;^\n]+") do
    i = i + 1
    if i == 1 then
      s1 = tostring(str)
    elseif i == 2 then
      s2 = tostring(str)
    elseif i == 3 then
      s3 = tostring(str)
    elseif i == 4 then
      s4 = tostring(str)
    end
  end
  return {
    s1 = s1,
    s2 = s2,
    s3 = s3,
    s4 = s4
  }
end
function Number(line)
  local i = 0
  for str in line:gmatch("[^;^\n]+") do
    i = i + 1
    if i == 1 then
      n1 = tonumber(str)
    elseif i == 2 then
      n2 = tonumber(str)
    elseif i == 3 then
      n3 = tonumber(str)
    elseif i == 4 then
      n4 = tonumber(str)
    elseif i == 5 then
      n5 = tonumber(str)
    elseif i == 6 then
      n6 = tonumber(str)
    elseif i == 7 then
      n7 = tonumber(str)
    elseif i == 8 then
      n8 = tonumber(str)
    elseif i == 9 then
      n9 = tonumber(str)
    elseif i == 10 then
      n10 = tonumber(str)
    end
  end
  return {
    n1 = n1,
    n2 = n2,
    n3 = n3,
    n4 = n4,
    n5 = n5,
    n6 = n6,
    n7 = n7,
    n8 = n8,
    n9 = n9,
    n10 = n10
  }
end
function Opt(sec)
  local Theor = tonumber(getParamEx("SPBOPT", sec, "theorprice").param_value)
  local Bid = tonumber(getParamEx("SPBOPT", sec, "bid").param_value)
  local Offer = tonumber(getParamEx("SPBOPT", sec, "offer").param_value)
  local Curr = 0
  if Bid == 0 and Offer == 0 then
    Curr = Theor
  elseif Bid > 0 and Offer == 0 then
    if Theor < Bid then
      Curr = Bid
    else
      Curr = Theor
    end
  elseif Bid == 0 and Offer > 0 then
    if Theor > Offer then
      Curr = Offer
    else
      Curr = Theor
    end
  elseif Bid > 0 and Offer > 0 then
    if Theor >= Bid and Theor <= Offer then
      Curr = Theor
    elseif Theor < Bid or Theor > Offer then
      Curr = RoundToStep((Bid + Offer) / 2)
    end
  end
  local F = string.sub(sec, #sec - 3, #sec - 3)
  if F == "0" then
    m = 3
  else
    m = 4
  end
  local S = tonumber(string.sub(sec, 3, #sec - m))
  local Vola = Round(tonumber(getParamEx("SPBOPT", sec, "volatility").param_value), 2)
  local V = tonumber(getParamEx("SPBOPT", sec, "volatility").param_value) / 100
  local D = tonumber(getParamEx("SPBOPT", sec, "days_to_mat_date").param_value) / Year
  local d1 = (math.log(F_Curr / S) + V * V * D / 2) / (V * math.sqrt(D))
  local d2 = d1 - V * math.sqrt(D)
  local P_Delta = -Round(-math.exp(-D) * N(-d1), 2)
  local Theta = -F_Curr * V * math.exp(-D) * pN(d1) / (2 * math.sqrt(D))
  local P_Theta = Round((Theta + S * math.exp(-D) * N(-d2) - F_Curr * math.exp(-D) * N(-d1)) / Year, 0)
  return {
    Bid = Bid,
    Offer = Offer,
    Curr = Curr,
    Vola = Vola,
    P_Delta = P_Delta,
    P_Theta = P_Theta
  }
end
function N(x)
  if x > 10 then
    return 1
  end
  if x < -10 then
    return 0
  end
  local t = 1 / (1 + 0.2316419 * math.abs(x))
  local d = 1 / math.sqrt(2 * math.pi) * math.exp(-x * x / 2)
  local p = d * t * ((((1.330274429 * t - 1.821255978) * t + 1.781477937) * t - 0.356563782) * t + 0.31938153)
  if x > 0 then
    return 1 - p
  else
    return p
  end
end
function pN(x)
  return math.exp(-0.5 * x * x) / math.sqrt(2 * math.pi)
end
function Round(num, idp)
  local mult = 10 ^ idp
  return math.floor(num * mult + 0.5) / mult
end
function RoundToStep(price)
  PS = tonumber(getParamEx("SPBFUT", Fut, "sec_price_step").param_value)
  return math.floor(price / PS) * PS
end
function Str(line, column, profit)
  SetCell(t_id, line, column, tostring(profit))
  if profit == 0 then
    White(t_id, line, column)
  elseif profit > 0 then
    Green(t_id, line, column)
  else
    Red(t_id, line, column)
  end
end
function Position(line, sec, cl, volume, price, profit)
  if volume ~= 0 then
    SetCell(t_id, line, 0, sec)
    SetCell(t_id, line, 1, tostring(cl))
    SetCell(t_id, line, 2, tostring(volume))
    SetCell(t_id, line, 3, tostring(price))
    SetCell(t_id, line, 4, tostring(profit))
    if profit == 0 then
      White(t_id, line, 0)
      White(t_id, line, 1)
      White(t_id, line, 2)
      White(t_id, line, 3)
      White(t_id, line, 4)
    elseif profit > 0 then
      Green(t_id, line, 0)
      Green(t_id, line, 1)
      Green(t_id, line, 2)
      Green(t_id, line, 3)
      Green(t_id, line, 4)
    else
      Red(t_id, line, 0)
      Red(t_id, line, 1)
      Red(t_id, line, 2)
      Red(t_id, line, 3)
      Red(t_id, line, 4)
    end
  else
    SetCell(t_id, line, 0, "")
    White(t_id, line, 0)
    SetCell(t_id, line, 1, "")
    White(t_id, line, 1)
    SetCell(t_id, line, 2, "")
    White(t_id, line, 2)
    SetCell(t_id, line, 3, "")
    White(t_id, line, 3)
    SetCell(t_id, line, 4, "")
    White(t_id, line, 4)
  end
end
function White(id, line, column)
  SetColor(id, line, column, RGB(255, 255, 255), RGB(0, 0, 0), RGB(255, 255, 255), RGB(0, 0, 0))
end
function Green(id, line, column)
  SetColor(id, line, column, RGB(165, 227, 128), RGB(0, 0, 0), RGB(165, 227, 128), RGB(0, 0, 0))
end
function Red(id, line, column)
  SetColor(id, line, column, RGB(255, 168, 164), RGB(0, 0, 0), RGB(255, 168, 164), RGB(0, 0, 0))
end
function Gray(id, line, column)
  if column == nil then
    column = QTABLE_NO_INDEX
  end
  SetColor(id, line, column, RGB(208, 208, 208), RGB(0, 0, 0), RGB(208, 208, 208), RGB(0, 0, 0))
end
function Blue(id, line, column)
  SetColor(id, line, column, RGB(44, 112, 188), RGB(255, 255, 255), RGB(44, 112, 188), RGB(255, 255, 255))
end
function BlueAtten(id, line, column)
  Highlight(id, line, column, RGB(44, 112, 188), RGB(255, 255, 255), 100)
end
function TransFut(ls, bs, open, lots)
  trans_id = trans_id + 1
  if ls == "Long" then
    if bs == "\207\238\234\243\239\234\224" then
      FL_Open = trans_id
    else
      FL_Close = trans_id
    end
  end
  local Transaction = {
    ["TRANS_ID"] = tostring(trans_id),
    ["CLASSCODE"] = "SPBFUT",
    ["ACTION"] = "\194\226\238\228 \231\224\255\226\234\232",
    ["\210\238\240\227\238\226\251\233 \241\247\229\242"] = Account,
    ["\202/\207"] = bs,
    ["\210\232\239"] = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255",
    ["\202\235\224\241\241"] = "SPBFUT",
    ["\200\237\241\242\240\243\236\229\237\242"] = Fut,
    ["\214\229\237\224"] = tostring(open),
    ["\202\238\235\232\247\229\241\242\226\238"] = tostring(lots),
    ["\211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255"] = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252",
    ["\202\238\236\236\229\237\242\224\240\232\233"] = Name,
    ["\207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243"] = "\196\224",
    ["\196\224\242\224 \253\234\241\239\232\240\224\246\232\232"] = tostring(tonumber(getParamEx("SPBFUT", Fut, "mat_date").param_value))
  }
  local res = sendTransaction(Transaction)
  if res ~= "" then
    message("\206\248\232\225\234\224 TransFut: " .. res)
  end
end
function TransOpt(sec, bs, open, lots)
  trans_id = trans_id + 1
  if sec == Put then
    if bs == "\207\238\234\243\239\234\224" then
      P_Open = trans_id
    else
      P_Close = trans_id
    end
  end
  local Transaction = {
    ["TRANS_ID"] = tostring(trans_id),
    ["CLASSCODE"] = "SPBOPT",
    ["ACTION"] = "\194\226\238\228 \231\224\255\226\234\232",
    ["\210\238\240\227\238\226\251\233 \241\247\229\242"] = Account,
    ["\202/\207"] = bs,
    ["\210\232\239"] = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255",
    ["\202\235\224\241\241"] = "SPBOPT",
    ["\200\237\241\242\240\243\236\229\237\242"] = sec,
    ["\214\229\237\224"] = tostring(open),
    ["\202\238\235\232\247\229\241\242\226\238"] = tostring(lots),
    ["\211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255"] = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252",
    ["\202\238\236\236\229\237\242\224\240\232\233"] = Name,
    ["\207\240\238\226\229\240\255\242\252 \235\232\236\232\242 \246\229\237\251"] = "\196\224",
    ["\207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243"] = "\196\224",
    ["\196\224\242\224 \253\234\241\239\232\240\224\246\232\232"] = tostring(tonumber(getParamEx("SPBOPT", sec, "mat_date").param_value))
  }
  local res = sendTransaction(Transaction)
  if res ~= "" then
    message("\206\248\232\225\234\224 TransOpt: " .. res)
  end
end
function Kill(sec, bs, num)
  trans_id = trans_id + 1
  if sec == Fut then
    class = "SPBFUT"
    if bs == "LOpen" then
      FL_Open = 0
    elseif bs == "LClose" then
      FL_Close = 0
    end
  end
  if sec == Put then
    class = "SPBOPT"
    if bs == "LOpen" then
      P_Open = 0
    else
      P_Close = 0
    end
  end
  local Transaction = {
    TRANS_ID = tostring(trans_id),
    CLASSCODE = class,
    SECCODE = sec,
    ACTION = "KILL_ORDER",
    ORDER_KEY = tostring(num)
  }
  local res = sendTransaction(Transaction)
  if res ~= "" then
    message("\206\248\232\225\234\224 Kill: " .. res)
  end
end
function OnTransReply(trans_reply)
  if FL_Open > 0 and FL_Num == 0 and FL_Open == trans_reply.trans_id then
    if trans_reply.status == 3 then
      FL_Open = trans_reply.price
      FL_Num = trans_reply.order_num
      FL_Lin = trans_reply.order_num
    elseif trans_reply.status == 4 then
      FL_Open = -1
    elseif trans_reply.status > 4 then
      FL_Open = 0
    end
  end
  if FL_Open == 0 and 0 < FL_Num and FL_Num == trans_reply.order_num then
    if trans_reply.status == 3 then
      FL_Num = 0
      FL_Lin = 0
    elseif trans_reply.status > 3 then
      FL_Open = trans_reply.price
    end
  end
  if 0 < FL_Close and FL_Num_Cl == 0 and FL_Close == trans_reply.trans_id then
    if trans_reply.status == 3 then
      FL_Close = trans_reply.price
      FL_Num_Cl = trans_reply.order_num
      FL_Lin_Cl = trans_reply.order_num
    elseif trans_reply.status == 4 then
      FL_Close = -1
    elseif trans_reply.status > 4 then
      FL_Close = 0
    end
  end
  if FL_Close == 0 and 0 < FL_Num_Cl and FL_Num_Cl == trans_reply.order_num then
    if trans_reply.status == 3 then
      FL_Num_Cl = 0
      FL_Lin_Cl = 0
    elseif trans_reply.status > 3 then
      FL_Close = trans_reply.price
    end
  end
  if 0 < P_Open and P_Num == 0 and P_Open == trans_reply.trans_id then
    if trans_reply.status == 3 then
      P_Open = trans_reply.price
      P_Num = trans_reply.order_num
      P_Lin = trans_reply.order_num
    elseif trans_reply.status == 4 then
      P_Open = -1
    elseif trans_reply.status > 4 then
      P_Open = 0
    end
  end
  if P_Open == 0 and 0 < P_Num and P_Num == trans_reply.order_num then
    if trans_reply.status == 3 then
      P_Num = 0
      P_Lin = 0
    elseif trans_reply.status > 3 then
      P_Open = trans_reply.price
    end
  end
  if 0 < P_Close and P_Num_Cl == 0 and P_Close == trans_reply.trans_id then
    if trans_reply.status == 3 then
      P_Close = trans_reply.price
      P_Num_Cl = trans_reply.order_num
      P_Lin_Cl = trans_reply.order_num
    elseif trans_reply.status == 4 then
      P_Close = -1
    elseif trans_reply.status > 4 then
      P_Close = 0
    end
  end
  if P_Close == 0 and 0 < P_Num_Cl and P_Num_Cl == trans_reply.order_num then
    if trans_reply.status == 3 then
      P_Num_Cl = 0
      P_Lin_Cl = 0
    elseif trans_reply.status > 3 then
      P_Close = trans_reply.price
    end
  end
  SaveCurrentState()
end
function OnOrder(order)
  if FL_Lin > 0 and FL_Lin == order.linkedorder then
    FL_Num = order.order_num
  end
  if 0 < FL_Lin_Cl and FL_Lin_Cl == order.linkedorder then
    FL_Num_Cl = order.order_num
  end
  if 0 < P_Lin and P_Lin == order.linkedorder then
    P_Num = order.order_num
  end
  if 0 < P_Lin_Cl and P_Lin_Cl == order.linkedorder then
    P_Num_Cl = order.order_num
  end
  SaveCurrentState()
end
function OnTrade(trade)
  if Deal < trade.trade_num then
    if FL_Num == trade.order_num then
      Deal = trade.trade_num
      FL_Pr[FL_Op] = Round(trade.price + Comm_Fut, 0)
      FL_Open = 0
      FL_Num = 0
      FL_Lin = 0
      FL_Op = 0
    end
    if FL_Num_Cl == trade.order_num then
      Deal = trade.trade_num
      Curr_Hist = Curr_Hist + trade.price - FL_Pr[FL_Cl]
      FL_Close = 0
      FL_Num_Cl = 0
      FL_Lin_Cl = 0
      FL_Pr[FL_Cl] = 0
      FL_Cl = 0
    end
    if P_Num == trade.order_num then
      Deal = trade.trade_num
      P_Pr[P_Op] = Round(trade.price + Comm_Opt, 0)
      P_Open = 0
      P_Num = 0
      P_Lin = 0
      P_Op = 0
    end
    if P_Num_Cl == trade.order_num then
      Deal = trade.trade_num
      Curr_Hist = Curr_Hist + trade.price - P_Pr[P_Cl]
      P_Close = 0
      P_Num_Cl = 0
      P_Lin_Cl = 0
      P_Pr[P_Cl] = 0
      P_Cl = 0
    end
    SaveCurrentState()
  end
end
