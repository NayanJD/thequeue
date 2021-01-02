--[[

    Input:

        ARGV[1] key prefix
        ARGV[2] job id
        ARGV[3] queue token
        ARGV[4] lock duration in milliseconds
        ARGV[5] processed at timestamp
]]

local rcall = redis.call

local jobId = ARGV[2]
local jobKey = ARGV[1] .. jobId
local lockKey = jobKey .. ':lock'

rcall("SET", lockKey, ARGV[3], "PX", ARGV[4])

rcall("HSET", jobKey, "processedOn", ARGV[5])

local jobMapData = rcall("HGETALL", jobKey)


--Send the job map data in a single array with key and value
table.insert(jobMapData, "jobId")
table.insert(jobMapData, jobId)

return jobMapData

