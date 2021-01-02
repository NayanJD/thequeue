--[[
    Input:
        KEYS[1] 'jobId'
        KEYS[2] 'waitQueue'

        ARGV[1] key prefix
        ARGV[2] data
        ARGV[3] created at timestamp
]]

local jobId
local jobIdKey
local rcall = redis.call

local jobCounter = rcall("INCR", KEYS[1])

jobId = jobCounter
jobIdKey = ARGV[1] .. jobId

rcall("HMSET", jobIdKey, "data", ARGV[2],"createdAt", ARGV[3])

return jobId


