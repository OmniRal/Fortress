-- OmniRal

local EnemyService = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modules
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remotes
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Variables
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Enemies = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function CubicBezier(T, P0, P1, P2, P3)
	local OneMinusT = 1 - T
	return OneMinusT^3 * P0 
		+ 3 * OneMinusT^2 * T * P1 
		+ 3 * OneMinusT * T^2 * P2 
		+ T^3 * P3
end


local function CalculateFlightPath(PathModel: Model, Location: string): {Vector3}
	if not PathModel then return end

	local FlightPath: {Vector3} = {}

	for x = 1, #PathModel:GetChildren() do
		local Point_A: BasePart = PathModel:WaitForChild("Point_" .. x, 0.1)
		local Point_B: BasePart = PathModel:WaitForChild("Point_" .. x + 1, 0.1)

		--print("Point A: ", Point_A)
		--print("Point B: ", Point_B)

		if not Point_A then break end

		Point_A.Transparency = 1

		local Attach_A: Attachment = Point_A:FindFirstChild("Attachment")
		if not Attach_A then
			warn("Missing attachment in flight point " .. x)
			break
		end

		if Point_B then
			local Attach_B: Attachment = Point_B:FindFirstChild("Attachment")
			if not Attach_B then
				warn("Missing attachment in flight point " .. x + 1)
				break
			end

			local Beam: Beam = Point_A:FindFirstChild("FBeam")
			if (Beam) and (Beam.Attachment0 == Attach_A and Beam.Attachment1 == Attach_B) then
				Beam.Enabled = false

				local P0, P3 = Attach_A.WorldPosition, Attach_B.WorldPosition
				local Dir_0, Dir_1 = Attach_A.WorldAxis, Attach_B.WorldAxis
				local Curve_0, Curve_1 = Beam.CurveSize0, Beam.CurveSize1
				local P1 = P0 + Dir_0 * Curve_0
				local P2 = P3 - Dir_1 * Curve_1

				for T = 0, 1, 0.05 do
					local Point = Util.CubicBezier(T, P0, P1, P2, P3)
					--Util.CreateDot(CFrame.new(Point))
					table.insert(FlightPath, Point)
				end
			else
				table.insert(FlightPath, Attach_A.WorldPosition)
			end

		else
			table.insert(FlightPath, Attach_A.WorldPosition)
		end
	end

	local Blackhole = SharedAssets.Portal.Blackhole:Clone()
	Blackhole.CFrame = CFrame.new(FlightPath[#FlightPath])
	Blackhole:SetAttribute("Location", Location)
	Blackhole.Parent = Workspace.Blackholes

	return FlightPath, Blackhole
end


function LaunchPlayer()
	if State ~= "StartingToFly"  then return end
	local Info = Portals[CurrentPortal]
	if not Info then
		CancelLaunch()
		return
	end

	State = "Flying"
	
	MyTrail.Enabled = true
	CurrentPortal:SetAttribute("State", 3)
	CurrentPortal.Base.FXPoint.Explosion:Emit(2)
	CurrentPortal.Base.Portal_Launch:Play()
	
	Camera.CameraType = Enum.CameraType.Scriptable

	local FlightPath = table.clone(Info.FlightPath)

	table.insert(FlightPath, 1, MyCF.Value.Position) -- Have the flight start just in front of the portal

	-- Travel time / distance
	local TotalDistance = 0
	for n = 1, #FlightPath - 1 do
		TotalDistance += (FlightPath[n + 1] - FlightPath[n]).Magnitude
	end

	local TotalTime, TimePassed = TotalDistance / FLIGHT_SPEED, 0
	local LastCF = MyCF.Value
	local HoldTime = 0
	
	task.delay(0.4, function()
		ToggleArmBeams(false)
	end)
	FadeSound(SharedAssets.Portal.Sounds.Portal_Prepping, 0)
	FadeSound(SharedAssets.Portal.Sounds.Portal_Flying, 0.5)		

	local Connection: RBXScriptConnection? = nil
	Connection = RunService.RenderStepped:Connect(function(DeltaTime)
		TimePassed += DeltaTime

		local Progress = math.min(TimePassed / TotalTime, 1)

		local TargetDistance = Progress * TotalDistance
		local CurrentDistance = 0
		local CurrentPoint = 1

		for n = 1, #FlightPath - 1 do
			local SegmentDistance = (FlightPath[n + 1] - FlightPath[n]).Magnitude
			if CurrentDistance + SegmentDistance >= TargetDistance then
				CurrentPoint = n
				break
			end
			CurrentDistance += SegmentDistance
		end

		local A = FlightPath[CurrentPoint]
		local B = FlightPath[CurrentPoint + 1] or FlightPath[CurrentPoint]
		local SegmentDistance = (B - A).Magnitude
		local SegmentProgress = (TargetDistance - CurrentDistance) / SegmentDistance
		SegmentProgress = math.clamp(SegmentProgress, 0, 1)

		local CurrentPosition = A:Lerp(B, SegmentProgress)

		local NextPoint = math.min(CurrentPoint + 1, #FlightPath)
		local Direction = (FlightPath[NextPoint] - CurrentPosition).Unit
		local TargetCFrame = CFrame.new(CurrentPosition, CurrentPosition + Direction)

		-- Smoothly interpolate from previous orientation to target orientation
		local CurrentCF = LastCF:Lerp(TargetCFrame, 0.05)
		MyCF.Value = CurrentCF
		LastCF = CurrentCF

		local CameraOffset = CFrame.new(0, CAMERA_HEIGHT, CAMERA_DISTANCE)
		local TargetCameraCFrame = CurrentCF * CameraOffset

		Camera.CFrame = Camera.CFrame:Lerp(TargetCameraCFrame, CAMERA_SMOOTHING)

		--local CurrentSpeed = (CurrentPosition - LastCF.Position).Magnitude / DeltaTime		
		--local SpeedRatio = math.clamp(CurrentSpeed / MAX_SPEED, 0, 1)
		--local TargetFOV = MIN_FOV + (MAX_FOV - MIN_FOV) * SpeedRatio
		--Camera.FieldOfView = Camera.FieldOfView + (TargetFOV - Camera.FieldOfView) * FOV_SMOOTHING

		if Progress < 1 then return end

		--HoldTime += DeltaTime
		--if HoldTime < TELEPORT_DELAY then return end

		MyTrail.Enabled = false
		Connection:Disconnect()
		PortalManager.TeleportPlayerToParticpatingGame(CurrentPortal:GetAttribute("PlaceId"))
	end)
end

]]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



function EnemyService:Init()
end

function EnemyService:Deferred()
end

return EnemyService