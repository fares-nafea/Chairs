local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local statsStore = DataStoreService:GetDataStore("DangerChairsData_v1")

-- Create Leaderstats
local function createLeaderstats(player, savedData)

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = savedData and savedData.Wins or 0
    wins.Parent = leaderstats

    local deaths = Instance.new("IntValue")
    deaths.Name = "Deaths"
    deaths.Value = savedData and savedData.Deaths or 0
    deaths.Parent = leaderstats

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = savedData and savedData.Coins or 0
    coins.Parent = leaderstats
end

-- Load Data
Players.PlayerAdded:Connect(function(player)

    local savedData
    local success, err = pcall(function()
        savedData = statsStore:GetAsync(player.UserId)
    end)

    if not success then
        warn("Data failed to load for "..player.Name)
    end

    createLeaderstats(player, savedData)

    -- Track Death Automatically
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            player.leaderstats.Deaths.Value += 1
        end)
    end)
end)

-- Save Data
local function saveData(player)

    if not player:FindFirstChild("leaderstats") then return end

    local data = {
        Wins = player.leaderstats.Wins.Value,
        Deaths = player.leaderstats.Deaths.Value,
        Coins = player.leaderstats.Coins.Value
    }

    local success, err = pcall(function()
        statsStore:SetAsync(player.UserId, data)
    end)

    if not success then
        warn("Data failed to save for "..player.Name)
    end
end

Players.PlayerRemoving:Connect(saveData)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        saveData(player)
    end
end)
