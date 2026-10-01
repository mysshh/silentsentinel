
import bpy

# Open the previously generated file
bpy.ops.wm.open_mainfile(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\terrain\worldmachine_test\TerrainTest.blend')

# Export to GLB
bpy.ops.export_scene.gltf(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\terrain\worldmachine_test\TerrainTest.glb', export_format='GLB')

