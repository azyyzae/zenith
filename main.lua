local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Commands = {}
local FolderPath = "Zenith/commands"

if not isfolder("Zenith") then makefolder("Zenith") end
if not isfolder(FolderPath) then makefolder(FolderPath) end

for _, file in pairs(listfiles(FolderPath)) do
    if file:sub(-4) == ".lua" then
        local commandName = file:match("([^/]+)%.lua$") or file:match("([^/\\]+)%.lua$")
        local success, result = pcall(function()
            return loadstring(readfile(file))
        end)
        
        if success and type(result) == "function" then
            Commands[commandName:lower()] = result() 
        elseif success and type(result) == "table" then
             Commands[commandName:lower()] = result
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenithAdmin"
ScreenGui.Parent = CoreGui

local CmdBarFrame = Instance.new("Frame")
CmdBarFrame.Name = "CmdBarFrame"
CmdBarFrame.Size = UDim2.new(0, 400, 0, 50)
CmdBarFrame.Position = UDim2.new(0.5, -200, 0.8, 0)
CmdBarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CmdBarFrame.BorderSizePixel = 0
CmdBarFrame.Visible = false
CmdBarFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = CmdBarFrame

local CmdInput = Instance.new("TextBox")
CmdInput.Name = "Input"
CmdInput.Size = UDim2.new(1, -20, 1, 0)
CmdInput.Position = UDim2.new(0, 10, 0, 0)
CmdInput.BackgroundTransparency = 1
CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdInput.TextSize = 18
CmdInput.Font = Enum.Font.Gotham
CmdInput.Text = ""
CmdInput.PlaceholderText = "Command..."
CmdInput.Parent = CmdBarFrame

local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "Notifications"
NotificationFrame.Size = UDim2.new(0, 300, 1, 0)
NotificationFrame.Position = UDim2.new(1, -320, 0, 20)
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Parent = NotificationFrame

local function SendNotification(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 40)
    Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.BackgroundTransparency = 1
    Label.TextTransparency = 1
    Label.Parent = NotificationFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Label

    TweenService:Create(Label, TweenInfo.new(0.5), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    
    task.delay(3, function()
        TweenService:Create(Label, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.5)
        Label:Destroy()
    end)
end

local function ExecuteCommand(text)
    local args = text:split(" ")
    local cmdName = args[1]:lower()
    
    if Commands[cmdName] then
        task.spawn(function()
            pcall(Commands[cmdName])
        end)
        SendNotification(cmdName .. " was enabled")
    else
        SendNotification("Command does not exist")
    end
end

CmdInput.FocusLost:Connect(function(enter)
    if enter then
        ExecuteCommand(CmdInput.Text)
        CmdInput.Text = ""
        CmdBarFrame.Visible = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Period then
        CmdBarFrame.Visible = not CmdBarFrame.Visible
        if CmdBarFrame.Visible then
            CmdInput:CaptureFocus()
        end
    end
end)

if UserInputService.TouchEnabled then
    local MobileBtn = Instance.new("TextButton")
    MobileBtn.Size = UDim2.new(0, 50, 0, 50)
    MobileBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
    MobileBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileBtn.Text = "Z"
    MobileBtn.TextSize = 24
    MobileBtn.Font = Enum.Font.GothamBold
    MobileBtn.Parent = ScreenGui

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = MobileBtn

    local dragging, dragInput, dragStart, startPos

    MobileBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MobileBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MobileBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    MobileBtn.MouseButton1Click:Connect(function()
        CmdBarFrame.Visible = not CmdBarFrame.Visible
        if CmdBarFrame.Visible then
            CmdInput:CaptureFocus()
        end
    end)
end
