
extends SceneTree

func _init():
    var glb_path = 'res://assets/meshes/spacecraft/SentinelCraft.glb'
    var scene = load(glb_path)
    if not scene:
        print('Failed to load: ', glb_path)
        quit()
    
    var root = scene.instantiate()
    print_tree_recursive(root, 0)
    quit()

func print_tree_recursive(node, depth):
    print('  '.repeat(depth), node.name, ' (', node.get_class(), ')')
    for child in node.get_children():
        print_tree_recursive(child, depth + 1)

