shader_type canvas_item;

uniform bool is_visible = false;

void fragment()
{
	if (is_visible)
	{
		vec4 tex_color = texture(TEXTURE, UV);
        COLOR = vec4(tex_color.g, tex_color.r, tex_color.b, tex_color.a);
	}
}