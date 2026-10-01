
import bpy
import math

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_rock(name, location, scale):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    # Deform slightly
    for vert in obj.data.vertices:
        vert.co.x += (math.sin(vert.co.z * 5) * 0.2)
        vert.co.y += (math.cos(vert.co.x * 5) * 0.2)
    return obj

def generate_rocks():
    clear_scene()
    create_rock('Rock_Large', (0,0,0), (2, 3, 2))
    create_rock('Rock_Small', (5,0,0), (1, 1, 1))
    
    # Save & Export
    bpy.ops.wm.save_as_mainfile(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\source\environment\RockPack.blend')
    bpy.ops.export_scene.gltf(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\meshes\environment\RockPack.glb', export_format='GLB')

generate_rocks()
