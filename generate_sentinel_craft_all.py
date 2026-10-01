import bpy
import bmesh

def create_sentinel():
    # Clear scene
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    # Fuselage (Main body - Cone based)
    bpy.ops.mesh.primitive_cone_add(radius1=1, radius2=0.5, depth=8, location=(0, 0, 0))
    fuselage = bpy.context.active_object
    fuselage.name = "Fuselage"

    # Cockpit (Window cutout simulation)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.7, location=(0, 0, 3))
    cockpit = bpy.context.active_object
    cockpit.name = "Cockpit"
    
    # Engines (Rear)
    for i in [-0.5, 0.5]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=1, location=(i, 0, -4))
        engine = bpy.context.active_object
        engine.name = f"Engine_{i}"

    # Landing Gear (Structural)
    for i in [-1, 1]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(i, -1, 1))
        leg = bpy.context.active_object
        leg.scale = (0.2, 1, 0.2)
        leg.name = f"Leg_{i}"

    # Interior (Simple box layout)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    interior = bpy.context.active_object
    interior.scale = (1, 1, 6)
    interior.name = "InteriorCorridor"

    # Join All
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.join()
    craft = bpy.context.active_object
    craft.name = "SentinelCraft"

    # Bevel Modifier for detail
    bpy.ops.object.modifier_add(type='BEVEL')
    craft.modifiers["Bevel"].width = 0.05
    bpy.ops.object.modifier_apply(modifier="Bevel")

    # Apply Transforms
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    # Save & Export
    bpy.ops.wm.save_as_mainfile(filepath=r"C:\Users\asd\Documents\silent-sentinel\assets\source\spacecraft\SentinelCraft.blend")
    bpy.ops.export_scene.gltf(filepath=r"C:\Users\asd\Documents\silent-sentinel\assets\meshes\spacecraft\SentinelCraft.glb", export_format='GLB')

create_sentinel()

