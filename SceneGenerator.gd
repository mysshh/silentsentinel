extends Node

func _ready():
    create_player_scene()
    create_main_scene()
    print("Scenes generated successfully.")
    get_tree().quit()

func create_player_scene():
    var player = CharacterBody3D.new()
    player.name = "Player"
    var camera = Camera3D.new()
    camera.name = "Camera3D"
    player.add_child(camera)
    camera.owner = player
    
    var collision = CollisionShape3D.new()
    collision.name = "CollisionShape3D"
    player.add_child(collision)
    collision.owner = player
    
    var packed_scene = PackedScene.new()
    packed_scene.pack(player)
    ResourceSaver.save(packed_scene, "res://scenes/player/Player.tscn")

func create_main_scene():
    var main = Node3D.new()
    main.name = "Main"
    
    var packed_scene = PackedScene.new()
    packed_scene.pack(main)
    ResourceSaver.save(packed_scene, "res://scenes/main/Main.tscn")
