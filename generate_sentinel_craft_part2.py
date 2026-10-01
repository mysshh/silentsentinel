
# Interior
def create_interior():
    # Corridor
    corridor = create_block("Corridor", (0, 0, 0), (1, 1, 5))
    corridor.display_type = 'WIRE'
    
    # AirLock
    airlock = create_block("Airlock", (0, -0.5, 4), (1, 1, 1))

# Finalizing
import generate_sentinel_craft_part1 as part1
part1.create_sentinel()
create_interior()

# Apply Transforms
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Save
source_path = r"C:\Users\asd\Documents\silent-sentinel\assets\source\spacecraft\SentinelCraft.blend"
bpy.ops.wm.save_as_mainfile(filepath=source_path)

# Export
glb_path = r"C:\Users\asd\Documents\silent-sentinel\assets\meshes\spacecraft\SentinelCraft.glb"
bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB')
