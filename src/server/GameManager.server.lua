local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- References
local chairTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ChairModel")
local chairZone = Workspace:WaitForChild("ChairZone")

local currentChairs = {}

-- Game States
local GameState = {
    Waiting = "Waiting",
    Intermission = "Intermission",
    Playing = "Playing",
    Resolving = "Resolving",
    GameOver = "GameOver"
}

local currentState = GameState.Waiting
local roundTime = 10
local intermissionTime = 5
local roundNumber = 0

-- Countdown
local function startCountdown(seconds)
    for i = seconds, 0, -1 do
        wait(1)
    end
end

-- Check enough players
local function enoughPlayers()
    return #Players:GetPlayers() >= 2
end

-- Spawn Chairs
local function spawnChairs()

    -- حذف القديم
    for _, chair in ipairs(currentChairs) do
        chair:Destroy()
    end
    currentChairs = {}

    local playerCount = #Players:GetPlayers()
    local chairCount = math.max(playerCount - 1, 1)

    local spacing = 8
    local startOffset = -(chairCount - 1) * spacing / 2

    for i = 1, chairCount do
        local chair = chairTemplate:Clone()
        chair.Parent = chairZone

        local xOffset = startOffset + (i - 1) * spacing
        local newPosition = chairZone.Position + Vector3.new(xOffset, 2, 0)

        chair:SetPrimaryPartCFrame(CFrame.new(newPosition))

        chair:SetAttribute("Danger", false)
        table.insert(currentChairs, chair)
    end

    -- اختيار Danger عشوائي
    if #currentChairs > 0 then
        local randomIndex = math.random(1, #currentChairs)
        currentChairs[randomIndex]:SetAttribute("Danger", true)
    end
end

-- Resolve Round
local function resolveRound()

    local seatedPlayers = {}

    for _, chair in ipairs(currentChairs) do
        local seat = chair:FindFirstChildWhichIsA("Seat", true)

        if seat and seat.Occupant then
            local humanoid = seat.Occupant
            local character = humanoid.Parent
            local player = Players:GetPlayerFromCharacter(character)

            if player then
                seatedPlayers[player] = true

                if chair:GetAttribute("Danger") then
                    -- Launch + Kill
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bodyVel = Instance.new("BodyVelocity")
                        bodyVel.Velocity = Vector3.new(0,80,0)
                        bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
                        bodyVel.Parent = hrp
                    end

                    wait(0.2)

                    humanoid.Health = 0
                else
                    -- Safe reward
                    if player:FindFirstChild("leaderstats") then
                        player.leaderstats.Wins.Value += 1
                        player.leaderstats.Coins.Value += 10
                    end
                end
            end
        end
    end

    -- Kill players who didn't sit
    for _, player in ipairs(Players:GetPlayers()) do
        if not seatedPlayers[player] then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    end
end

-- Main Loop
task.spawn(function()
    while true do

        if currentState == GameState.Waiting then
            print("Waiting for players...")
            repeat task.wait(1) until enoughPlayers()
            currentState = GameState.Intermission
        end

        if currentState == GameState.Intermission then
            print("Intermission")
            spawnChairs()
            startCountdown(intermissionTime)
            roundNumber += 1
            currentState = GameState.Playing
        end

        if currentState == GameState.Playing then
            print("Round "..roundNumber.." started!")
            startCountdown(roundTime)
            currentState = GameState.Resolving
        end

        if currentState == GameState.Resolving then
            print("Resolving Round "..roundNumber)
            resolveRound()
            task.wait(3)

            local alivePlayers = {}

            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    if player.Character.Humanoid.Health > 0 then
                        table.insert(alivePlayers, player)
                    end
                end
            end

            if #alivePlayers <= 1 then
                currentState = GameState.GameOver
            else
                currentState = GameState.Intermission
            end
        end

        if currentState == GameState.GameOver then
            print("Game Over")
            roundNumber = 0
            task.wait(5)
            currentState = GameState.Waiting
        end

        task.wait()
    end
end)
