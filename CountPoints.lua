-- Define the item categories and their base points
local ITEM_CATEGORIES = {
    Common = { points = 1, items = {"Carrot", "Strawberry"} },
    Uncommon = { points = 2, items = {"Blueberry", "Orange Tulip"} },
    Rare = { points = 3, items = {"Tomato", "Corn", "Daffodil"} },
    Legendary = { points = 4, items = {"Watermelon", "Pumpkin", "Apple", "Bamboo"} },
    Mythical = { points = 5, items = {"Coconut", "Cactus", "Dragon Fruit", "Mango"} },
    Divine = { points = 6, items = {"Grape", "Mushroom", "Pepper Cacao", "Prismatic", "Beanstalk"} }
}

-- Define bonus points
local BONUS_POINTS = {
    Gold = 2,
    Rainbow = 3,
    Bloodlit = 2
}

-- Get the local player and services
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")

-- Create the main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackpackCounterUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- Enable dragging
mainFrame.Parent = screenGui

-- Add rounded corners
local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
scrollingFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrollingFrame

local totalScoreLabel = Instance.new("TextLabel")
totalScoreLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
totalScoreLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
totalScoreLabel.BackgroundTransparency = 1
totalScoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
totalScoreLabel.TextScaled = true
totalScoreLabel.Text = "Total Score: 0"
totalScoreLabel.Font = Enum.Font.SourceSansBold
totalScoreLabel.Parent = mainFrame

-- Create the toggle UI
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0.1, 0, 0.05, 0)
toggleFrame.Position = UDim2.new(0.9, 0, 0.05, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame.BackgroundTransparency = 0.3
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = screenGui

local toggleFrameCorner = Instance.new("UICorner")
toggleFrameCorner.CornerRadius = UDim.new(0, 5)
toggleFrameCorner.Parent = toggleFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0.9, 0)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Text = "Hide"
toggleButton.Font = Enum.Font.SourceSans
toggleButton.Parent = toggleFrame

local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(0, 5)
toggleButtonCorner.Parent = toggleButton

-- Toggle main UI visibility
local isMainUIVisible = true
toggleButton.MouseButton1Click:Connect(function()
    isMainUIVisible = not isMainUIVisible
    mainFrame.Visible = isMainUIVisible
    toggleButton.Text = isMainUIVisible and "Hide" or "Show"
end)

-- Dragging logic for main UI
local isDragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        mainFrame.Position = newPos
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Function to get the item name and total points from a tool's name
local function getItemInfo(toolName)
    local lowerToolName = toolName:lower()
    if not lowerToolName:find("moonlit") then
        return nil, 0
    end

    local basePoints = 0
    local itemName = nil
    for category, data in pairs(ITEM_CATEGORIES) do
        for _, name in pairs(data.items) do
            local lowerItemName = name:lower()
            if lowerToolName:find(lowerItemName) then
                itemName = name
                basePoints = data.points
                break
            end
        end
        if itemName then break end
    end

    if not itemName then
        return nil, 0
    end

    local bonusPoints = 0
    if lowerToolName:find("gold") then
        bonusPoints = bonusPoints + BONUS_POINTS.Gold
    end
    if lowerToolName:find("rainbow") then
        bonusPoints = bonusPoints + BONUS_POINTS.Rainbow
    end
    if lowerToolName:find("bloodlit") then
        bonusPoints = bonusPoints + BONUS_POINTS.Bloodlit
    end

    return itemName, basePoints + bonusPoints
end

-- Function to calculate the total score and update the UI
local function calculateBackpackScore(backpack)
    local totalScore = 0
    local itemCounts = {}
    local itemPoints = {}

    for category, data in pairs(ITEM_CATEGORIES) do
        for _, itemName in pairs(data.items) do
            itemCounts[itemName] = 0
            itemPoints[itemName] = 0
        end
    end

    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local itemName, points = getItemInfo(item.Name)
            if itemName and points > 0 then
                itemCounts[itemName] = (itemCounts[itemName] or 0) + 1
                itemPoints[itemName] = points
            end
        end
    end

    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local layoutOrder = 0
    for itemName, count in pairs(itemCounts) do
        if count > 0 then
            local points = itemPoints[itemName]
            totalScore = totalScore + (count * points)
            print(string.format("%s: %d (x%d points)", itemName, count, points))

            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size = UDim2.new(1, 0, 0, 30)
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemLabel.TextScaled = true
            itemLabel.Text = string.format("%s: %d (x%d points)", itemName, count, points)
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.LayoutOrder = layoutOrder
            itemLabel.Parent = scrollingFrame
            layoutOrder = layoutOrder + 1
        end
    end

    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder * 35)
    totalScoreLabel.Text = string.format("Total Score: %d", totalScore)

    return totalScore
end

-- Get the local player's Backpack
local backpack = player:WaitForChild("Backpack")

-- Initial score calculation
local function updateScore()
    local score = calculateBackpackScore(backpack)
    print(string.format("Total Score: %d", score))
end

-- Run initial score calculation
updateScore()
backpack.ChildAdded:Connect(updateScore)
backpack.ChildRemoved:Connect(updateScore)
