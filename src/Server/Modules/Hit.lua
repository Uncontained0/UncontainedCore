local Hit = {}
Hit._Cache = {}

function Hit.new (Target:Humanoid,Origin:Player,DecayTime:number?,Metadata:any?): Hit
    local self = {}
    setmetatable(self,{__index=Hit})

    self.Target = Target
    self.Origin = Origin
    self.Metadata = Metadata

    if Hit._Cache[Target] then
        Hit._Cache[Target]:Destroy ()
    end

    Hit._Cache[Target] = self
    
    if DecayTime then
        task.delay(DecayTime,self.Destroy,self)
    end

    return self
end

function Hit.fromTarget (Target:Humanoid): Hit?
    return Hit._Cache[Target]
end

function Hit:Destroy ()
    if self.Destroyed then return end
    self.Destroyed = true
    Hit._Cache[self.Target] = nil
end

return Hit