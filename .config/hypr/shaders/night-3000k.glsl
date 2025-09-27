#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    pixColor.r *= 1.0; pixColor.g *= 0.69; pixColor.b *= 0.42;
    fragColor = pixColor;
}
