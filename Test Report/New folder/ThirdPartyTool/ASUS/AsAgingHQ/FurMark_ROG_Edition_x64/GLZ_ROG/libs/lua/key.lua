--[[
By stakov999
http://www.geeks3d.com/forums/index.php/topic,4369.msg7019/topicseen.html#msg7019


How to use the key table:

-----------------------------------------------------------
local lib_dir = gh_utils.get_scripting_libs_dir() 		
dofile(lib_dir .. "lua/key.lua")

local kbcode,state
gh_window.keyboard_update_buffer(0)

--KEYBOARD STATUS
for k,v in pairs(key) do
  kbcode=k
  for k1,v1 in pairs(key[k]) do
    if k1>1 then
      state=gh_input.keyboard_is_key_down(key[k][k1])
    end
  end

  if state==1 then 
    text(kbcode,state,key[kbcode][1]) 
  end
end



function text(keycode,status,str)
  gh_imgui.text(string.format("%d_%d_%s",keycode,status,str))
end
-----------------------------------------------------------
--]]
 

key={}
key[8]={"backspace", 14 }
key[9]={"tab", 15 }
key[13]={"enter", 156,28 }
key[16]={"shift", 54,42 }
key[17]={"ctrl", 157,29 }
key[18]={"alt", 184,56 }
key[19]={"pause", 223 }
key[20]={"capital", 58 }
key[27]={"escape", 1 }
key[32]={"space", 57 }
key[33]={"pageup", 201 }
key[34]={"pagedown", 209 }
key[35]={"_end", 207 }
key[36]={"home", 199 }
key[37]={"left", 75 ,203}
key[38]={"up", 72,200 }
key[39]={"right", 77 ,205}
key[40]={"down", 80 ,208}
key[45]={"insert", 210 }
key[46]={"delete", 211 }
key[48]={"_0", 11 }
key[49]={"_1", 2 }
key[50]={"_2", 3 }
key[51]={"_3", 4 }
key[52]={"_4", 5 }
key[53]={"_5", 6 }
key[54]={"_6", 7 }
key[55]={"_7", 8 }
key[56]={"_8", 9 }
key[57]={"_9", 10 }
key[65]={"a", 30 }
key[66]={"b", 48 }
key[67]={"c", 46 }
key[68]={"d", 32 }
key[69]={"e", 18 }
key[70]={"f", 33 }
key[71]={"g", 34 }
key[72]={"h", 35 }
key[73]={"i", 23 }
key[74]={"j", 36 }
key[75]={"k", 37 }
key[76]={"l", 38 }
key[77]={"m", 50 }
key[78]={"n", 49 }
key[79]={"o", 24 }
key[80]={"p", 25 }
key[81]={"q", 16 }
key[82]={"r", 19 }
key[83]={"s", 31 }
key[84]={"t", 20 }
key[85]={"u", 22 }
key[86]={"v", 47 }
key[87]={"w", 17 }
key[88]={"x", 45 }
key[89]={"y", 21 }
key[90]={"z", 44 }
key[91]={"lwin", 219 }
key[92]={"rwin", 220 }
key[96]={"numpad0", 82 }
key[97]={"numpad1", 79 }
key[98]={"numpad2", 80 }
key[99]={"numpad3", 81 }
key[100]={"numpad4", 75 }
key[101]={"numpad5", 76 }
key[102]={"numpad6", 77 }
key[103]={"numpad7", 71 }
key[104]={"numpad8", 72 }
key[105]={"numpad9", 73 }
key[106]={"multiply", 55 }
key[107]={"add", 78 }
key[109]={"subtract", 74 }
key[110]={"decimal", 83 }
key[111]={"divide", 181 }
key[112]={"f1", 59 }
key[113]={"f2", 60 }
key[114]={"f3", 61 }
key[115]={"f4", 62 }
key[116]={"f5", 63 }
key[117]={"f6", 64 }
key[118]={"f7", 65 }
key[119]={"f8", 66 }
key[120]={"f9", 67 }
key[121]={"f10", 68 }
key[122]={"f11", 87 }
key[123]={"f12", 88 }
key[144]={"numlock", 69 }
key[145]={"scroll", 70 }
