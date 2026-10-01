import bpy
import bmesh
import math

def create_block(name, location, size):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj

def create_sentinel():
    # Clear scene
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    # Fuselage
    fuselage = create_block("Fuselage", (0, 0, 0), (2, 2, 10))
    # Tapering
    bm = bmesh.new()
    bm.from_mesh(fuselage.data)
    for v in bm.verts:
        if v.co.z > 2:
            v.co.x *= 0.5
            v.co.y *= 0.5
    bm.to_mesh(fuselage.data)
    bm.free()

    # Cockpit
    cockpit = create_block("Cockpit", (0, 0, 5), (1.5, 1.5, 2))
    
    # Engines
    engine1 = create_block("Engine1", (-1, 0, -5), (1, 1, 2))
    engine2 = create_block("Engine2", (1, 0, -5), (1, 1, 2))

    # Landing Gear
    for i in range(4):
        x = 1.5 if i % 2 == 0 else -1.5
        z = 3 if i < 2 else -3
        leg = create_block(f"Leg_{i}", (x, -1.5, z), (0.3, 1, 0.3))

    # Joining
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.join()
    craft = bpy.context.active_object
    craft.name = "SentinelCraft"
