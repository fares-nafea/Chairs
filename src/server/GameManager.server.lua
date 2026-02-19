local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent لإرسال التايمر للـ UI
local UpdateTimer = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateTimer")

-- Game States
local GameState = {
    Waiting = "Waiting",
    Intermission = "Intermission",
    Playing = "Playing",
    Resolving = "Resolving",
    GameOver = "GameOver"
}

local currentState = GameState.Waiting
local roundTime = 10 -- ثواني
local intermissionTime = 5
local roundNumber = 0

-- Helper: Broadcast Timer
local function startCountdown(seconds)
    for i = seconds, 0, -1 do
        UpdateTimer:FireAllClients(i)
        wait(1)
    end
end

-- Check if enough players
local function enoughPlayers()
    return #Players:GetPlayers() >= 2
end

-- Main Game Loop
spawn(function()
    while true do
        if currentState == GameState.Waiting then
            print("Waiting for players...")
            repeat wait(1) until enoughPlayers()
            currentState = GameState.Intermission
        end

        if currentState == GameState.Intermission then
            print("Intermission: Prepare for round")
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
            print("Round "..roundNumber.." resolving...")
            -- هنا بعدين هنضيف كود الكراسي والدخول
            -- حالياً مجرد مكان للتحضير
            wait(2)
            -- Check if game over
            local alivePlayers = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    table.insert(alivePlayers, player)
                end
            end

            if #alivePlayers <= 1 then
                currentState = GameState.GameOver
            else
                currentState = GameState.Intermission
            end
        end

        if currentState == GameState.GameOver then
            print("Game Over!")
            -- Reset Round
            roundNumber = 0
            wait(5)
            currentState = GameState.Waiting
        end

        wait() -- تفادي أي freeze
    end
end)
