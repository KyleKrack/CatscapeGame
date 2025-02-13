extends CharacterBody3D

#onready

@onready var body = $"Body Root"
@onready var navigationAgent = $NavigationAgent3D;
@onready var point = $"../Floating Pointer"






var speed : float  = 5.0; 
var gravity : float = 9.8;
var targetPosition : Vector3 ; 
var currentlyNavigating : bool;




# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(not currentlyNavigating):
		point.visible = false; 
		return
	
	moveToPoint(delta, speed );
	currentlyNavigating = not navigationAgent.is_navigation_finished()
	
	
func moveToPoint(delta, speed):
	
	#body will face in direction of current target
	var targetPosition = navigationAgent.target_position; 
	var direction = global_position.direction_to(targetPosition);
	faceDirection(targetPosition); 

	#move agent based on input target
	pathfindNavAgent()

func _input(event):
	# when LM is clicked raycast from current position to mouse pos direction
	# and the length is rayLength 
	if Input.is_action_just_pressed("LeftMouse"):
		var camera = get_tree().get_nodes_in_group("camera")[0]; 
		var mousePos = get_viewport().get_mouse_position();
		var rayLength = 50; 
		var from = camera.project_ray_origin(mousePos); 
		var to = from + camera.project_ray_normal(mousePos) * rayLength; 
		var space = get_world_3d().direct_space_state;
		
		var rayQuery = PhysicsRayQueryParameters3D.new();
		rayQuery.from = from;
		rayQuery.to = to;
		rayQuery.collide_with_areas = true; 
		
		var result = space.intersect_ray(rayQuery);
		#print(result); 
		
		
	
		if(result.has("position")):
			#navigationAgent.target_position = Vector3(floor(result.position.x),result.position.y,floor(result.position.z));
			targetPosition = result.position;
			
			if result.collider.has_method("interacted"):
				result.collider.interacted(); 	
			else: 
				currentlyNavigating = true;
				point.position = targetPosition;
				point.visible = true; 
			

				
func faceDirection(direction):
	body.look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)
	
	
func pathfindNavAgent():
	navigationAgent.target_position = targetPosition; 
	#print(targetPosition)
		
	var next_location = navigationAgent.get_next_path_position();
	var current_location = transform.origin; 
	var new_velocity = (next_location-current_location).normalized() * speed 
	velocity = velocity.move_toward(new_velocity, 0.25);
	
	
	move_and_slide(); 
	
	
