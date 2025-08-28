local module = {}

function module.New(Time:number?, EasingStyle:Types?, EasingDirection:Direciton?)
    return {
        Time = Time or 0;
        EasingStyle = EasingStyle or "Linear";
        EasingDirection = EasingDirection or "In"
    }
end

return module