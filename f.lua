-- Decompiled using luadec 2.0.2 by sztupy (http://winmo.sztupy.hu)
-- Command line was: f_deltafp.luac 

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
OnInit = function(l_1_0)
  Name = l_1_0:match(".+\\(.+).lua")
  do
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
          for line in (for generator) do
          end
          if Count == 2 then
            Arr = Number(line)
            trans_id = Arr.n1
            Comm_Fut = Arr.n2
            Comm_Opt = Arr.n3
            Year = Arr.n4
            NFO = Arr.n5
            Delta = Arr.n6
            Min_Profit = Arr.n7
            Max_Profit = Arr.n8
            for line in (for generator) do
            end
            if Count == 3 then
              Arr = Number(line)
              Deal = Arr.n1
              Curr_Hist = Arr.n2
              Close = Arr.n3
              Trading = Arr.n4
              Level = Arr.n5
              Menu = Arr.n6
              for line in (for generator) do
              end
              if Count == 4 then
                Arr = Number(line)
                FL_Open = Arr.n1
                FL_Num = Arr.n2
                FL_Lin = Arr.n3
                FL_Close = Arr.n4
                FL_Num_Cl = Arr.n5
                FL_Lin_Cl = Arr.n6
                for line in (for generator) do
                end
                if Count == 5 then
                  Arr = Number(line)
                  P_Open = Arr.n1
                  P_Num = Arr.n2
                  P_Lin = Arr.n3
                  P_Close = Arr.n4
                  P_Num_Cl = Arr.n5
                  P_Lin_Cl = Arr.n6
                  for line in (for generator) do
                  end
                  if Count > 5 and Count <= 5 + Level then
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
             -- Warning: missing end command somewhere! Added here
          end
           -- Warning: missing end command somewhere! Added here
        end
         -- Warning: missing end command somewhere! Added here
      end
       -- Warning: missing end command somewhere! Added here
    end
     -- Warning: missing end command somewhere! Added here
  end
end

main = function()
  repeat
    if is_run then
      F_Status = tonumber(getParamEx("SPBFUT", Fut, "status").param_value)
      F_Bid = tonumber(getParamEx("SPBFUT", Fut, "bid").param_value)
      F_Offer = tonumber(getParamEx("SPBFUT", Fut, "offer").param_value)
      F_Curr = RoundToStep((F_Bid + F_Offer) / 2)
      P_Theor = tonumber(getParamEx("SPBOPT", Put, "theorprice").param_value)
      Day = tonumber(getParamEx("SPBOPT", Put, "days_to_mat_date").param_value)
      if F_Curr > 0 and P_Theor > 0 and Day > 0 then
        P = Opt(Put)
        if P_Open > 0 and P_Num > 0 then
          PCurr = P_Open
        else
          PCurr = P.Curr
        end
        if Close == 1 then
          if P_Close > 0 and P_Num_Cl > 0 then
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
          if FL_Pr[i] > 0 then
            FL_Volume = FL_Volume + 1
            FL_Price = FL_Price + FL_Pr[i]
            FL_Profit = FL_Profit + F_Curr - FL_Pr[i]
          end
          if P_Pr[i] > 0 then
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
            if P_Op > 0 and P_Open == 0 and P_Num == 0 and (P_Volume < Round(1 / P.P_Delta, 0) or Delta > D or P_Volume < Round(NFO / P.P_Delta, 0)) then
              TransOpt(Put, "\207\238\234\243\239\234\224", P.Curr, 1)
            end
            if (D < Delta or P_Open < P.Bid) and P_Open > 0 and P_Num > 0 then
              Kill(Put, "LOpen", P_Num)
            end
            if (Round(1 / P.P_Delta, 0) <= P_Volume and FL_Volume == 0) or D < Delta and FL_Volume < NFO then
              TransFut("Long", "\207\238\234\243\239\234\224", F_Curr, 1)
            end
            if (Delta <= D or FL_Open < F_Bid) and FL_Open > 0 and FL_Num > 0 then
              Kill(Fut, "LOpen", FL_Num)
            else
              Red(t_id, 4, 0)
            end
          else
            SetCell(t_id, 4, 0, "No price - wait")
            Red(t_id, 4, 0)
          end
        end
      end
      sleep(100)
    else
       -- Warning: missing end command somewhere! Added here
    end
     -- Warning: missing end command somewhere! Added here
  end
end

CreateTableMenu = function()
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

CreateTable = function()
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

OnClick = function(l_5_0, l_5_1, l_5_2, l_5_3)
  if l_5_1 == QTABLE_LBUTTONUP then
    if l_5_0 == t_id_Menu then
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
      if l_5_2 == 1 and l_5_3 == 1 then
        Account_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 2 and l_5_3 == 1 then
        trans_id_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 3 and l_5_3 == 1 then
        Year_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 5 and l_5_3 == 1 then
        Fut_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 7 and l_5_3 == 1 then
        Put_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 5 and l_5_3 == 3 then
        Comm_Fut_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 6 and l_5_3 == 3 then
        Comm_Opt_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 7 and l_5_3 == 3 then
        NFO_Inputing = true
        BlueAtten(t_id_Menu, l_5_2, l_5_3)
      elseif l_5_2 == 9 and l_5_3 == 0 then
        Menu = 1
        DestroyTable(t_id_Menu)
      end
    end
    if l_5_0 == t_id and l_5_2 == 1 and l_5_3 == 1 then
      Menu = 0
      KillAll()
      DestroyTable(t_id_Menu)
      CreateTableMenu()
    elseif l_5_1 == QTABLE_CHAR then
      if Account_Inputing then
        Arr = Parameter(1, 1, l_5_3, Account_Text, Account_Cursor)
        Account_Text = Arr.text
        Account_Cursor = Arr.cursor
        Account = tostring(Arr.param)
      end
      if trans_id_Inputing then
        Arr = Parameter(2, 1, l_5_3, trans_id_Text, trans_id_Cursor)
        trans_id_Text = Arr.text
        trans_id_Cursor = Arr.cursor
        trans_id = tonumber(Arr.param)
      end
      if Year_Inputing then
        Arr = Parameter(3, 1, l_5_3, Year_Text, Year_Cursor)
        Year_Text = Arr.text
        Year_Cursor = Arr.cursor
        Year = tonumber(Arr.param)
      end
      if Fut_Inputing then
        Arr = Parameter(5, 1, l_5_3, Fut_Text, Fut_Cursor)
        Fut_Text = Arr.text
        Fut_Cursor = Arr.cursor
        Fut = tostring(Arr.param)
      end
      if Put_Inputing then
        Arr = Parameter(7, 1, l_5_3, Put_Text, Put_Cursor)
        Put_Text = Arr.text
        Put_Cursor = Arr.cursor
        Put = tostring(Arr.param)
      end
      if Comm_Fut_Inputing then
        Arr = Parameter(5, 3, l_5_3, Comm_Fut_Text, Comm_Fut_Cursor)
        Comm_Fut_Text = Arr.text
        Comm_Fut_Cursor = Arr.cursor
        Comm_Fut = tonumber(Arr.param)
      end
      if Comm_Opt_Inputing then
        Arr = Parameter(6, 3, l_5_3, Comm_Opt_Text, Comm_Opt_Cursor)
        Comm_Opt_Text = Arr.text
        Comm_Opt_Cursor = Arr.cursor
        Comm_Opt = tonumber(Arr.param)
      end
      if NFO_Inputing then
        Arr = Parameter(7, 3, l_5_3, NFO_Text, NFO_Cursor)
        NFO_Text = Arr.text
        NFO_Cursor = Arr.cursor
        NFO = tonumber(Arr.param)
      elseif l_5_1 == QTABLE_CLOSE and l_5_0 == t_id_Menu then
        OnStop()
      end
    end
  end
end

Parameter = function(l_6_0, l_6_1, l_6_2, l_6_3, l_6_4)
  if (l_6_2 >= 32 and l_6_2 <= 126) or l_6_2 >= 192 and l_6_2 <= 255 then
    if l_6_4 == 0 then
      l_6_3 = string.char(l_6_2) .. "|"
    else
      l_6_3 = string.sub(l_6_3, 1, l_6_4) .. string.char(l_6_2) .. "|"
    end
    l_6_4 = l_6_4 + 1
    param = string.sub(l_6_3, 1, l_6_4)
    SetCell(t_id_Menu, l_6_0, l_6_1, l_6_3)
  elseif l_6_2 == 8 and l_6_4 > 0 then
    l_6_3 = string.sub(l_6_3, 1, l_6_4 - 1) .. "|"
    l_6_4 = l_6_4 - 1
    param = string.sub(l_6_3, 1, l_6_4)
    if l_6_4 == 0 then
      param = 0
    end
    SetCell(t_id_Menu, l_6_0, l_6_1, l_6_3)
  end
  return {text = l_6_3, cursor = l_6_4, param = param}
end

Cursor = function()
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

Curs = function(l_8_0, l_8_1, l_8_2, l_8_3)
  if string.sub(l_8_2, l_8_3 + 1, l_8_3 + 1) == "|" then
    l_8_2 = string.gsub(l_8_2, "|", " ")
    SetCell(t_id_Menu, l_8_0, l_8_1, l_8_2)
    Timer = os.clock()
  else
    l_8_2 = string.gsub(l_8_2, " ", "|")
    SetCell(t_id_Menu, l_8_0, l_8_1, l_8_2)
    Timer = os.clock()
  end
  return l_8_2
end

OnStop = function()
  is_run = false
  KillAll()
  SaveCurrentState()
end

KillAll = function()
  if F_Status == 1 then
    if FL_Open > 0 and FL_Num > 0 then
      Kill(Fut, "LOpen", FL_Num)
    end
    FL_Open = 0
    FL_Num = 0
    FL_Lin = 0
    if FL_Close > 0 and FL_Num_Cl > 0 then
      Kill(Fut, "LClose", FL_Num_Cl)
    end
    FL_Close = 0
    FL_Num_Cl = 0
    FL_Lin_Cl = 0
    White(t_id, 2, 0)
    if P_Open > 0 and P_Num > 0 then
      Kill(Put, "LOpen", P_Num)
    end
    P_Open = 0
    P_Num = 0
    P_Lin = 0
    if P_Close > 0 and P_Num_Cl > 0 then
      Kill(Put, "LClose", P_Num_Cl)
    end
    P_Close = 0
    P_Num_Cl = 0
    P_Lin_Cl = 0
    White(t_id, 3, 0)
  end
end

SaveCurrentState = function()
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

String = function(l_12_0)
  do
    local i = 0
    for str in l_12_0:gmatch("[^;^\n]+") do
      i = i + 1
      if i == 1 then
        s1 = tostring(str)
        for str in (for generator) do
        end
        if i == 2 then
          s2 = tostring(str)
          for str in (for generator) do
          end
          if i == 3 then
            s3 = tostring(str)
            for str in (for generator) do
            end
            if i == 4 then
              s4 = tostring(str)
            end
          end
          return {s1 = s1, s2 = s2, s3 = s3, s4 = s4}
        end
         -- Warning: missing end command somewhere! Added here
      end
       -- Warning: missing end command somewhere! Added here
    end
     -- Warning: missing end command somewhere! Added here
  end
end

Number = function(l_13_0)
  do
    local i = 0
    for str in l_13_0:gmatch("[^;^\n]+") do
      i = i + 1
      if i == 1 then
        n1 = tonumber(str)
        for str in (for generator) do
        end
        if i == 2 then
          n2 = tonumber(str)
          for str in (for generator) do
          end
          if i == 3 then
            n3 = tonumber(str)
            for str in (for generator) do
            end
            if i == 4 then
              n4 = tonumber(str)
              for str in (for generator) do
              end
              if i == 5 then
                n5 = tonumber(str)
                for str in (for generator) do
                end
                if i == 6 then
                  n6 = tonumber(str)
                  for str in (for generator) do
                  end
                  if i == 7 then
                    n7 = tonumber(str)
                    for str in (for generator) do
                    end
                    if i == 8 then
                      n8 = tonumber(str)
                      for str in (for generator) do
                      end
                      if i == 9 then
                        n9 = tonumber(str)
                        for str in (for generator) do
                        end
                        if i == 10 then
                          n10 = tonumber(str)
                        end
                      end
                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n5 = n5
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n6 = n6
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n7 = n7
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n8 = n8
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n9 = n9
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      {n1 = n1, n2 = n2, n3 = n3, n4 = n4}.n10 = n10
                       -- DECOMPILER ERROR: Confused about usage of registers!

                      return {n1 = n1, n2 = n2, n3 = n3, n4 = n4}
                    end
                     -- Warning: missing end command somewhere! Added here
                  end
                   -- Warning: missing end command somewhere! Added here
                end
                 -- Warning: missing end command somewhere! Added here
              end
               -- Warning: missing end command somewhere! Added here
            end
             -- Warning: missing end command somewhere! Added here
          end
           -- Warning: missing end command somewhere! Added here
        end
         -- Warning: missing end command somewhere! Added here
      end
       -- Warning: missing end command somewhere! Added here
    end
     -- Warning: missing end command somewhere! Added here
  end
end

Opt = function(l_14_0)
  local Theor = tonumber(getParamEx("SPBOPT", l_14_0, "theorprice").param_value)
  local Bid = tonumber(getParamEx("SPBOPT", l_14_0, "bid").param_value)
  local Offer = tonumber(getParamEx("SPBOPT", l_14_0, "offer").param_value)
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
    if Offer < Theor then
      Curr = Offer
    else
      Curr = Theor
    end
  elseif Bid > 0 and Offer > 0 then
    if Bid <= Theor and Theor <= Offer then
      Curr = Theor
    elseif Theor < Bid or Offer < Theor then
      Curr = RoundToStep((Bid + Offer) / 2)
    end
  end
  local F = string.sub(l_14_0, #l_14_0 - 3, #l_14_0 - 3)
  if F == "0" then
    m = 3
  else
    m = 4
  end
  local S = tonumber(string.sub(l_14_0, 3, #l_14_0 - m))
  local Vola = Round(tonumber(getParamEx("SPBOPT", l_14_0, "volatility").param_value), 2)
  local V = tonumber(getParamEx("SPBOPT", l_14_0, "volatility").param_value) / 100
  local D = tonumber(getParamEx("SPBOPT", l_14_0, "days_to_mat_date").param_value) / Year
  local d1 = (math.log(F_Curr / S) + V * V * D / 2) / (V * math.sqrt(D))
  local d2 = d1 - V * math.sqrt(D)
  local P_Delta = -Round(-math.exp(-D) * N(-d1), 2)
  local Theta = -F_Curr * V * math.exp(-D) * pN(d1) / (2 * math.sqrt(D))
  local P_Theta = Round((Theta + S * math.exp(-D) * N(-d2) - F_Curr * math.exp(-D) * N(-d1)) / Year, 0)
  return {Bid = Bid, Offer = Offer, Curr = Curr, Vola = Vola, P_Delta = P_Delta, P_Theta = P_Theta}
end

N = function(l_15_0)
  if l_15_0 > 10 then
    return 1
  end
  if l_15_0 < -10 then
    return 0
  end
  local t = 1 / (1 + 0.2316419 * math.abs(l_15_0))
  local d = 1 / math.sqrt(2 * math.pi) * math.exp(-l_15_0 * l_15_0 / 2)
  local p = d * t * ((((1.330274429 * t - 1.821255978) * t + 1.781477937) * t - 0.356563782) * t + 0.31938153)
  if l_15_0 > 0 then
    return 1 - p
  else
    return p
  end
end

pN = function(l_16_0)
  return math.exp(-0.5 * l_16_0 * l_16_0) / math.sqrt(2 * math.pi)
end

Round = function(l_17_0, l_17_1)
  local mult = 10 ^ l_17_1
  return math.floor(l_17_0 * mult + 0.5) / mult
end

RoundToStep = function(l_18_0)
  PS = tonumber(getParamEx("SPBFUT", Fut, "sec_price_step").param_value)
  return math.floor(l_18_0 / PS) * PS
end

Str = function(l_19_0, l_19_1, l_19_2)
  SetCell(t_id, l_19_0, l_19_1, tostring(l_19_2))
  if l_19_2 == 0 then
    White(t_id, l_19_0, l_19_1)
  elseif l_19_2 > 0 then
    Green(t_id, l_19_0, l_19_1)
  else
    Red(t_id, l_19_0, l_19_1)
  end
end

Position = function(l_20_0, l_20_1, l_20_2, l_20_3, l_20_4, l_20_5)
  if l_20_3 ~= 0 then
    SetCell(t_id, l_20_0, 0, l_20_1)
    SetCell(t_id, l_20_0, 1, tostring(l_20_2))
    SetCell(t_id, l_20_0, 2, tostring(l_20_3))
    SetCell(t_id, l_20_0, 3, tostring(l_20_4))
    SetCell(t_id, l_20_0, 4, tostring(l_20_5))
    if l_20_5 == 0 then
      White(t_id, l_20_0, 0)
      White(t_id, l_20_0, 1)
      White(t_id, l_20_0, 2)
      White(t_id, l_20_0, 3)
      White(t_id, l_20_0, 4)
    elseif l_20_5 > 0 then
      Green(t_id, l_20_0, 0)
      Green(t_id, l_20_0, 1)
      Green(t_id, l_20_0, 2)
      Green(t_id, l_20_0, 3)
      Green(t_id, l_20_0, 4)
    else
      Red(t_id, l_20_0, 0)
      Red(t_id, l_20_0, 1)
      Red(t_id, l_20_0, 2)
      Red(t_id, l_20_0, 3)
      Red(t_id, l_20_0, 4)
    end
  else
    SetCell(t_id, l_20_0, 0, "")
    White(t_id, l_20_0, 0)
    SetCell(t_id, l_20_0, 1, "")
    White(t_id, l_20_0, 1)
    SetCell(t_id, l_20_0, 2, "")
    White(t_id, l_20_0, 2)
    SetCell(t_id, l_20_0, 3, "")
    White(t_id, l_20_0, 3)
    SetCell(t_id, l_20_0, 4, "")
    White(t_id, l_20_0, 4)
  end
end
end

White = function(l_21_0, l_21_1, l_21_2)
  SetColor(l_21_0, l_21_1, l_21_2, RGB(255, 255, 255), RGB(0, 0, 0), RGB(255, 255, 255), RGB(0, 0, 0))
end

Green = function(l_22_0, l_22_1, l_22_2)
  SetColor(l_22_0, l_22_1, l_22_2, RGB(165, 227, 128), RGB(0, 0, 0), RGB(165, 227, 128), RGB(0, 0, 0))
end

Red = function(l_23_0, l_23_1, l_23_2)
  SetColor(l_23_0, l_23_1, l_23_2, RGB(255, 168, 164), RGB(0, 0, 0), RGB(255, 168, 164), RGB(0, 0, 0))
end

Gray = function(l_24_0, l_24_1, l_24_2)
  if l_24_2 == nil then
    l_24_2 = QTABLE_NO_INDEX
  end
  SetColor(l_24_0, l_24_1, l_24_2, RGB(208, 208, 208), RGB(0, 0, 0), RGB(208, 208, 208), RGB(0, 0, 0))
end

Blue = function(l_25_0, l_25_1, l_25_2)
  SetColor(l_25_0, l_25_1, l_25_2, RGB(44, 112, 188), RGB(255, 255, 255), RGB(44, 112, 188), RGB(255, 255, 255))
end

BlueAtten = function(l_26_0, l_26_1, l_26_2)
  Highlight(l_26_0, l_26_1, l_26_2, RGB(44, 112, 188), RGB(255, 255, 255), 100)
end

TransFut = function(l_27_0, l_27_1, l_27_2, l_27_3)
  trans_id = trans_id + 1
  if l_27_0 == "Long" then
    if l_27_1 == "\207\238\234\243\239\234\224" then
      FL_Open = trans_id
    else
      FL_Close = trans_id
    end
  end
  {TRANS_ID = tostring(trans_id), CLASSCODE = "SPBFUT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_27_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBFUT", \200\237\241\242\240\243\236\229\237\242 = Fut, \214\229\237\224 = tostring(l_27_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_27_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name}["\207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243"] = "\196\224"
   -- DECOMPILER ERROR: Confused about usage of registers!

  {TRANS_ID = tostring(trans_id), CLASSCODE = "SPBFUT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_27_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBFUT", \200\237\241\242\240\243\236\229\237\242 = Fut, \214\229\237\224 = tostring(l_27_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_27_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name}["\196\224\242\224 \253\234\241\239\232\240\224\246\232\232"] = tostring(tonumber(getParamEx("SPBFUT", Fut, "mat_date").param_value))
   -- DECOMPILER ERROR: Confused at declaration of local variable

   -- DECOMPILER ERROR: Confused about usage of registers!

  do
     -- DECOMPILER ERROR: Confused at declaration of local variable

    if sendTransaction({TRANS_ID = tostring(trans_id), CLASSCODE = "SPBFUT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_27_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBFUT", \200\237\241\242\240\243\236\229\237\242 = Fut, \214\229\237\224 = tostring(l_27_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_27_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name}) ~= "" then
      message("\206\248\232\225\234\224 TransFut: " .. sendTransaction({TRANS_ID = tostring(trans_id), CLASSCODE = "SPBFUT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_27_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBFUT", \200\237\241\242\240\243\236\229\237\242 = Fut, \214\229\237\224 = tostring(l_27_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_27_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name}))
    end
     -- DECOMPILER ERROR: Confused about usage of registers for local variables.

  end
end

TransOpt = function(l_28_0, l_28_1, l_28_2, l_28_3)
  trans_id = trans_id + 1
  if l_28_0 == Put then
    if l_28_1 == "\207\238\234\243\239\234\224" then
      P_Open = trans_id
    else
      P_Close = trans_id
    end
  end
  {TRANS_ID = tostring(trans_id), CLASSCODE = "SPBOPT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_28_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBOPT", \200\237\241\242\240\243\236\229\237\242 = l_28_0, \214\229\237\224 = tostring(l_28_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_28_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name, \207\240\238\226\229\240\255\242\252 \235\232\236\232\242 \246\229\237\251 = "\196\224", \207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243 = "\196\224"}["\196\224\242\224 \253\234\241\239\232\240\224\246\232\232"] = tostring(tonumber(getParamEx("SPBOPT", l_28_0, "mat_date").param_value))
   -- DECOMPILER ERROR: Confused at declaration of local variable

   -- DECOMPILER ERROR: Confused about usage of registers!

  do
     -- DECOMPILER ERROR: Confused at declaration of local variable

    if sendTransaction({TRANS_ID = tostring(trans_id), CLASSCODE = "SPBOPT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_28_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBOPT", \200\237\241\242\240\243\236\229\237\242 = l_28_0, \214\229\237\224 = tostring(l_28_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_28_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name, \207\240\238\226\229\240\255\242\252 \235\232\236\232\242 \246\229\237\251 = "\196\224", \207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243 = "\196\224"}) ~= "" then
      message("\206\248\232\225\234\224 TransOpt: " .. sendTransaction({TRANS_ID = tostring(trans_id), CLASSCODE = "SPBOPT", ACTION = "\194\226\238\228 \231\224\255\226\234\232", \210\238\240\227\238\226\251\233 \241\247\229\242 = Account, \202/\207 = l_28_1, \210\232\239 = "\203\232\236\232\242\232\240\238\226\224\237\237\224\255", \202\235\224\241\241 = "SPBOPT", \200\237\241\242\240\243\236\229\237\242 = l_28_0, \214\229\237\224 = tostring(l_28_2), \202\238\235\232\247\229\241\242\226\238 = tostring(l_28_3), \211\241\235\238\226\232\229 \232\241\239\238\235\237\229\237\232\255 = "\207\238\241\242\224\226\232\242\252 \226 \238\247\229\240\229\228\252", \202\238\236\236\229\237\242\224\240\232\233 = Name, \207\240\238\226\229\240\255\242\252 \235\232\236\232\242 \246\229\237\251 = "\196\224", \207\229\240\229\237\238\241\232\242\252 \231\224\255\226\234\243 = "\196\224"}))
    end
     -- DECOMPILER ERROR: Confused about usage of registers for local variables.

  end
end

Kill = function(l_29_0, l_29_1, l_29_2)
  trans_id = trans_id + 1
  if l_29_0 == Fut then
    class = "SPBFUT"
    if l_29_1 == "LOpen" then
      FL_Open = 0
    elseif l_29_1 == "LClose" then
      FL_Close = 0
    end
  end
  if l_29_0 == Put then
    class = "SPBOPT"
    if l_29_1 == "LOpen" then
      P_Open = 0
    else
      P_Close = 0
    end
  end
  local Transaction = {TRANS_ID = tostring(trans_id), CLASSCODE = class, SECCODE = l_29_0, ACTION = "KILL_ORDER", ORDER_KEY = tostring(l_29_2)}
  local res = sendTransaction(Transaction)
  if res ~= "" then
    message("\206\248\232\225\234\224 Kill: " .. res)
  end
end

OnTransReply = function(l_30_0)
  if FL_Open > 0 and FL_Num == 0 and FL_Open == l_30_0.trans_id then
    if l_30_0.status == 3 then
      FL_Open = l_30_0.price
      FL_Num = l_30_0.order_num
      FL_Lin = l_30_0.order_num
    elseif l_30_0.status == 4 then
      FL_Open = -1
    elseif l_30_0.status > 4 then
      FL_Open = 0
    end
  end
  if FL_Open == 0 and FL_Num > 0 and FL_Num == l_30_0.order_num then
    if l_30_0.status == 3 then
      FL_Num = 0
      FL_Lin = 0
    elseif l_30_0.status > 3 then
      FL_Open = l_30_0.price
    end
  end
  if FL_Close > 0 and FL_Num_Cl == 0 and FL_Close == l_30_0.trans_id then
    if l_30_0.status == 3 then
      FL_Close = l_30_0.price
      FL_Num_Cl = l_30_0.order_num
      FL_Lin_Cl = l_30_0.order_num
    elseif l_30_0.status == 4 then
      FL_Close = -1
    elseif l_30_0.status > 4 then
      FL_Close = 0
    end
  end
  if FL_Close == 0 and FL_Num_Cl > 0 and FL_Num_Cl == l_30_0.order_num then
    if l_30_0.status == 3 then
      FL_Num_Cl = 0
      FL_Lin_Cl = 0
    elseif l_30_0.status > 3 then
      FL_Close = l_30_0.price
    end
  end
  if P_Open > 0 and P_Num == 0 and P_Open == l_30_0.trans_id then
    if l_30_0.status == 3 then
      P_Open = l_30_0.price
      P_Num = l_30_0.order_num
      P_Lin = l_30_0.order_num
    elseif l_30_0.status == 4 then
      P_Open = -1
    elseif l_30_0.status > 4 then
      P_Open = 0
    end
  end
  if P_Open == 0 and P_Num > 0 and P_Num == l_30_0.order_num then
    if l_30_0.status == 3 then
      P_Num = 0
      P_Lin = 0
    elseif l_30_0.status > 3 then
      P_Open = l_30_0.price
    end
  end
  if P_Close > 0 and P_Num_Cl == 0 and P_Close == l_30_0.trans_id then
    if l_30_0.status == 3 then
      P_Close = l_30_0.price
      P_Num_Cl = l_30_0.order_num
      P_Lin_Cl = l_30_0.order_num
    elseif l_30_0.status == 4 then
      P_Close = -1
    elseif l_30_0.status > 4 then
      P_Close = 0
    end
  end
  if P_Close == 0 and P_Num_Cl > 0 and P_Num_Cl == l_30_0.order_num then
    if l_30_0.status == 3 then
      P_Num_Cl = 0
      P_Lin_Cl = 0
    elseif l_30_0.status > 3 then
      P_Close = l_30_0.price
    end
  end
  SaveCurrentState()
end

OnOrder = function(l_31_0)
  if FL_Lin > 0 and FL_Lin == l_31_0.linkedorder then
    FL_Num = l_31_0.order_num
  end
  if FL_Lin_Cl > 0 and FL_Lin_Cl == l_31_0.linkedorder then
    FL_Num_Cl = l_31_0.order_num
  end
  if P_Lin > 0 and P_Lin == l_31_0.linkedorder then
    P_Num = l_31_0.order_num
  end
  if P_Lin_Cl > 0 and P_Lin_Cl == l_31_0.linkedorder then
    P_Num_Cl = l_31_0.order_num
  end
  SaveCurrentState()
end

OnTrade = function(l_32_0)
  if Deal < l_32_0.trade_num then
    if FL_Num == l_32_0.order_num then
      Deal = l_32_0.trade_num
      FL_Pr[FL_Op] = Round(l_32_0.price + Comm_Fut, 0)
      FL_Open = 0
      FL_Num = 0
      FL_Lin = 0
      FL_Op = 0
    end
    if FL_Num_Cl == l_32_0.order_num then
      Deal = l_32_0.trade_num
      Curr_Hist = Curr_Hist + l_32_0.price - FL_Pr[FL_Cl]
      FL_Close = 0
      FL_Num_Cl = 0
      FL_Lin_Cl = 0
      FL_Pr[FL_Cl] = 0
      FL_Cl = 0
    end
    if P_Num == l_32_0.order_num then
      Deal = l_32_0.trade_num
      P_Pr[P_Op] = Round(l_32_0.price + Comm_Opt, 0)
      P_Open = 0
      P_Num = 0
      P_Lin = 0
      P_Op = 0
    end
    if P_Num_Cl == l_32_0.order_num then
      Deal = l_32_0.trade_num
      Curr_Hist = Curr_Hist + l_32_0.price - P_Pr[P_Cl]
      P_Close = 0
      P_Num_Cl = 0
      P_Lin_Cl = 0
      P_Pr[P_Cl] = 0
      P_Cl = 0
    end
    SaveCurrentState()
  end
end


