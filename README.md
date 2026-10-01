# SENTINEL Asset Pipeline Documentation

## REAL MESH PIPELINE
Blender
→ .blend (Source)
→ .glb (Export)
→ Godot import
→ .tscn (Scene)
→ runtime

## Standards
*   **Blender Version**: 5.2.2 LTS
*   **Blender Executable**: `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`
*   **Coordinate Convention**:
    *   Blender: Z-up, Y-forward
    *   Godot: Y-up, -Z-forward (standard GLTF/GLB import handling)
*   **Scale**: 1 Godot unit = 1 meter.
*   **Source Asset Location**: `assets/source/`
*   **Runtime Asset Location**: `assets/meshes/`
*   **Scene Location**: `assets/scenes/`
*   **Collision Strategy**: Simplified `CollisionShape3D` on `StaticBody3D` attached to mesh node.
*   **Export Process**: Use GLTF exporter with default GLB settings (apply transforms on export/import).

## Current Status
*   **Pipeline Verified**: Yes, custom mesh created, exported, and imported successfully.

