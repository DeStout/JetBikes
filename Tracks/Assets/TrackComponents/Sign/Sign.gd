tool
extends Spatial


export var sign_texture : Texture setget _set_sign_texture

onready var forward_sign = $ForwardSign


func _ready():
	if sign_texture != null:
		forward_sign.get_surface_material(0).set_shader_param("Sign_Texture", sign_texture)


func _set_sign_texture(new_sign_texture : Texture) -> void:
	sign_texture = new_sign_texture

	if forward_sign == null:
		return
	else:
		forward_sign.get_surface_material(0).set_shader_param("Sign_Texture", new_sign_texture)
