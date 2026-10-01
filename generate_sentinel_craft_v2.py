import bpy
import math

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_material(name, color, metallic, roughness):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Metallic'].default_value = metallic
    bsdf.inputs['Roughness'].default_value = roughness
    return mat

def create_part(name, mesh_type, location, scale, rotation=(0,0,0), material=None, collection='Exterior'):
    if mesh_type == 'cube':
        bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    elif mesh_type == 'cylinder':
        bpy.ops.mesh.primitive_cylinder_add(radius=1, depth=1, location=location)
    elif mesh_type == 'cone':
        bpy.ops.mesh.primitive_cone_add(radius1=1, radius2=0.5, depth=1, location=location)
    
    obj = bpy.context.active_object
    obj.name = name
    obj.location = location
    obj.scale = scale
    obj.rotation_euler = rotation
    
    if material:
        obj.data.materials.append(material)
    
    # Move to collection
    col = bpy.data.collections.get(collection)
    if col:
        for c in obj.users_collection:
            c.objects.unlink(obj)
        col.objects.link(obj)
        
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return obj

def create_cockpit(mat_graphite, mat_comp, mat_metal, mat_glass):
    # Cockpit Shell (curved structural walls)
    create_part('Cockpit_Shell', 'cylinder', (4, 0, 0), (3, 3, 4), (0, math.pi/2, 0), material=mat_graphite, collection='Interior')
    
    # Pilot Seat
    create_part('Seat_Base', 'cube', (3.5, 0, -0.5), (0.7, 0.7, 0.3), material=mat_comp, collection='Interior')
    create_part('Seat_Back', 'cube', (3.5, 0, 0.2), (0.2, 0.7, 1.2), material=mat_comp, collection='Interior')
    
    # Main Console (Multi-part)
    create_part('Console_Housing', 'cube', (4.8, 0, 0.2), (0.4, 2, 1.5), material=mat_graphite, collection='Interior')
    create_part('Console_Display_Main', 'cube', (5.0, 0, 0.2), (0.1, 1.2, 0.8), material=mat_glass, collection='Interior')
    
    # Side Consoles
    create_part('SideConsole_L', 'cube', (4.0, 1.2, 0), (0.8, 0.4, 0.6), material=mat_comp, collection='Interior')
    create_part('SideConsole_R', 'cube', (4.0, -1.2, 0), (0.8, 0.4, 0.6), material=mat_comp, collection='Interior')
    
    # Canopy Frame (simplified frame + glass)
    create_part('Canopy_Frame', 'cone', (5.2, 0, 1.0), (1.5, 2.5, 2), (0, math.pi/2, 0), material=mat_graphite, collection='Interior')
    create_part('Canopy_Glass', 'cone', (5.3, 0, 1.0), (1.4, 2.3, 1.8), (0, math.pi/2, 0), material=mat_glass, collection='Interior')

def generate_sentinel():
    clear_scene()

    # Collections
    ext_col = bpy.data.collections.new('Exterior')
    bpy.context.scene.collection.children.link(ext_col)
    int_col = bpy.data.collections.new('Interior')
    bpy.context.scene.collection.children.link(int_col)

    # Materials
    mat_graphite = create_material('Graphite', (0.05, 0.05, 0.05, 1), 0.8, 0.5)
    mat_comp = create_material('Composite', (0.3, 0.3, 0.35, 1), 0.2, 0.8)
    mat_metal = create_material('BrushedMetal', (0.4, 0.4, 0.45, 1), 0.7, 0.3)
    mat_glass = create_material('Glass', (0.1, 0.1, 0.2, 1), 0.1, 0.05)

    # 1. EXTERIOR
    create_part('HullShell', 'cylinder', (0, 0, 0), (10, 10, 14), (0, math.pi/2, 0), material=mat_graphite, collection='Exterior')
    
    # 2. INTERIOR
    create_cockpit(mat_graphite, mat_comp, mat_metal, mat_glass)
    
    # Basic placeholders for other areas
    create_part('Int_Floor', 'cube', (0, 0, -1), (10, 4, 0.2), material=mat_comp, collection='Interior')
    create_part('Int_Corridor', 'cube', (0, 0, 0), (4, 2, 2), material=mat_comp, collection='Interior')

    # Save & Export
    bpy.ops.wm.save_as_mainfile(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\source\spacecraft\SentinelCraft.blend')
    bpy.ops.export_scene.gltf(filepath=r'C:\Users\asd\Documents\silent-sentinel\assets\meshes\spacecraft\SentinelCraft.glb', export_format='GLB', export_materials='EXPORT')

generate_sentinel()
