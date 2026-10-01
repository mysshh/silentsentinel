import bpy
import os

# Clear scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Create body (cylinder)
bpy.ops.mesh.primitive_cylinder_add(radius=0.3, depth=0.6, location=(0,0,0))
body = bpy.context.active_object
body.name = "ProbeBody"

# Create limbs (4 cubes)
for i in range(4):
    angle = (i * 3.14159 / 2)
    bpy.ops.mesh.primitive_cube_add(size=0.2, location=(0.4 * __import__('math').cos(angle), 0.4 * __import__('math').sin(angle), 0))
    limb = bpy.context.active_object
    limb.scale = (1, 0.5, 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    limb.name = f"ProbeLeg_{i}"

# Join all
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.join()
probe = bpy.context.active_object
probe.name = "PipelineTestProbe"

# Bevel
bpy.ops.object.modifier_add(type='BEVEL')
probe.modifiers["Bevel"].width = 0.05
bpy.ops.object.modifier_apply(modifier="Bevel")

# Apply Transforms
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')

# Materials
mat = bpy.data.materials.new(name="SciFiMaterial")
mat.use_nodes = True
probe.data.materials.append(mat)

# Save
source_path = r"C:\Users\asd\Documents\silent-sentinel\assets\source\props\pipeline_test.blend"
bpy.ops.wm.save_as_mainfile(filepath=source_path)

# Export GLB
glb_path = r"C:\Users\asd\Documents\silent-sentinel\assets\meshes\props\pipeline_test.glb"
bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB')
