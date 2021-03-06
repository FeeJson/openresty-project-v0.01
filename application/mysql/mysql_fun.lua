--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/6/02 22:29
* |  Function: msyql add select udpate delete option
* |------------------------------------------------------------------------
--]]
local mysql = require 'resty.mysql'
local cjson = require 'cjson'
local db_config = {
    host = '127.0.0.1',
    port = 3306,
    database = 'lua',
    user = 'root',
    password = '123456',
    max_packet_size = 1024 * 1024,
    timeout = 1000,
    table = 'tb_ngx_test'
}
local db, err = mysql:new()
if not db then
    ngx.log(ngx_ERR, "failed to instantiate mysql: ", err) -- 未安装mysql客户端
    return
end
local ok, err, errcode, sqlstate = db:connect({
    host = db_config.host,
    port = db_config.port,
    database = db_config.database,
    user = db_config.user,
    password = db_config.password
})
if not ok then
    ngx.log(ngx_ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate) -- mysql连接不上
    return
end

-- 添加
--  data = { name = "XIDaDa", address = "HeilongJiang", age = "66" }
--  local result = add(data.name,data.address,data.age)
--  ngx.print(cjson.encode(result))
function add(name, address, age)
    local res = {}
    if name ~= nil then
        local sql = "INSERT INTO tb_ngx_test (name,address,age) VALUES (\'" .. name .. "\',\'" .. address .. "\'," .. age .. ")";
        local data, err, errcode, sqlstate = db:query(sql)
        if not data then
            res.error_code = 501
            res.message = 'add failed ' .. '[err]:' .. err .. ',[sql]:' .. sql
            res.result = nil
        else
            res.error_code = 200
            res.message = 'add successfully'
            res.result = res.insert_id
        end
    else
        res.error_code = 501
        res.message = 'parameter error'
        res.result = nil
    end
    return res
end

-- 查询
--  local result = select(3)
--  ngx.print(cjson.encode(result))
function select(id)
    local res = {}
    if id ~= nil then
        local data, err, errno, sqlstate = db:query('SELECT * FROM ' .. db_config.table .. ' WHERE id=' .. id .. ' LIMIT 1', 1)
        if data ~= nil then
            res.error_code = 200
            res.message = 'search successfully'
            res.result = data[1]
        else
            res.error_code = 502
            res.message = 'no data'
            res.result = data
        end
    else
        res.error_code = 501
        res.message = 'parameter error'
        res.result = nil
    end
    return res
end

-- 修改
--  local result = update(3,"TinTinAIAI")
--  ngx.print(cjson.encode(result))
function update(id, name)
    local res = {}
    if id ~= nil and name ~= nil then
        local data, err, errno, sqlstate = db:query('UPDATE ' .. db_config.table .. ' SET `name` = "' .. name .. '" WHERE id=' .. id)
        if not data or data.affected_rows < 1 then
            res.error_code = 504
            res.message = 'fail to update'
        else
            res.error_code = 200
            res.message = 'successfully modified'
        end
    else
        res.error_code = 501
        res.message = 'parameter error'
        res.result = nil
    end
    return res
end

-- 删除操作
--local result = delete(3)
--ngx.print(cjson.encode(result))
function delete(id)
    local res = {}
    if id ~= nil then
        local data, err, errno, sqlstate = db:query('DELETE FROM ' .. db_config.table .. ' WHERE id=' .. id)
        if not data or data.affected_rows < 1 then
            res.error_code = 504
            res.message = 'failed to delete'
        else
            res.error_code = 200
            res.message = 'successfully deleted'
        end
    else
        res.error_code = 501
        res.message = 'parameter error'
        res.result = nil
    end
    return res
end

function add(a,b)
    return a+b
end




