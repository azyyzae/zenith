return function()
    local plr = game:GetService("Players").LocalPlayer
    local mouse = plr:GetMouse()
    local human = plr.Character:FindFirstChildOfClass("Humanoid")
    local torso = plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
    
    local speed = 50
    local flying = true
    
    local bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    local bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0,0,1)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    local function fly()
        repeat wait()
            human.PlatformStand = true
            if not flying then break end
            
            bg.cframe = CFrame.new(torso.Position, torso.Position + workspace.CurrentCamera.CFrame.lookVector)
            bv.velocity = Vector3.new(0,0,0)
            
            local cam = workspace.CurrentCamera.CFrame
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                bv.velocity = cam.lookVector * speed
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                bv.velocity = -cam.lookVector * speed
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                bv.velocity = -cam.RightVector * speed
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                bv.velocity = cam.RightVector * speed
            end
        until not flying
        
        bg:Destroy()
        bv:Destroy()
        human.PlatformStand = false
    end
    fly()
end
