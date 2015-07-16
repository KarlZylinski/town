#version 410 core
layout(location = 0) in vec2 in_position;
layout(location = 1) in vec3 in_color;
uniform mat4 model_view_projection_matrix;
out vec4 f_color;

void main()
{
    f_color = vec4(in_color, 1.0);
    gl_Position = model_view_projection_matrix * vec4(in_position, 0.5, 1.0);
};