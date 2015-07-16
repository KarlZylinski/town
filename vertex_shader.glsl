#version 410 core
in vec2 in_position;
in vec3 in_color;
out vec4 f_color;

void main()
{
    f_color = vec4(in_color, 1.0f);
    gl_Position = vec4(in_position, 0.0f, 1.0f);
};