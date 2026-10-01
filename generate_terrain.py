
import bpy

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_terrain():
    clear_scene()
    # Create plane
    bpy.ops.mesh.primitive_plane_add(size=100, location=(0,0,0))
    terrain = bpy.context.active_object
    
    # Subdivide
    bpy.ops.object.modifier_add(type='SUBSURF')
    terrain.modifiers['Subdivision'].subdivision_type = 'SIMPLE'
    terrain.modifiers['Subdivision'].levels = 6
    terrain.modifiers['Subdivision'].render_levels = 6
    
    # Add displacement
    tex = bpy.data.textures.new('TerrainTexture', type='CLOUDS')
    tex.noise_scale = 0.5
    tex.noise_depth = 5
    
    mod = terrain.modifiers.new(name='Displacement', type='DISPLACE')
    mod.texture = tex
    mod.strength = 10
    
    # Apply
    bpy.ops.object.modifier_apply(modifier='Displacement')
    
    # Save & Export
    bpy.ops.wm.save_as_mainfile(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\terrain\worldmachine_test\TerrainTest.blend')
    bpy.ops.export_scene.gltf(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\terrain\worldmachine_test\TerrainTest.glb', export_format='GLB')

create_terrain()
