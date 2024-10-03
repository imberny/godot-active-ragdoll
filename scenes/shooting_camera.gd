extends Camera3D

@export var projectile_scene: PackedScene
@export var shoot_force := 5.0


func _shoot() -> void:
    var projectile := projectile_scene.instantiate() as RigidBody3D
    var mouse_pos := self.get_viewport().get_mouse_position()
    var origin := self.project_ray_origin(mouse_pos)
    var normal := self.project_ray_normal(mouse_pos)
    self.add_sibling(projectile)
    projectile.global_position = origin
    projectile.apply_impulse(normal * self.shoot_force)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("shoot"):
        self._shoot()
    if event.is_action_pressed("quit"):
        self.get_tree().quit()
