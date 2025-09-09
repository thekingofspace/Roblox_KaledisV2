varying vec4 worldPosition;
varying vec3 vertexNormal;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform vec3 lightPosition;
uniform float ambient = 0.2;
uniform float brightness = 1.0;  // Controls overall light brightness
uniform float shininess = 32.0;  // Controls how shiny/reflective the surface is
uniform float specularStrength = 0.5; // Controls strength of specular highlights
uniform float solidness = 1.0; // Controls how solid the object appears (0.0 = transparent, 1.0 = completely solid)

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
    vec3 lightDirection = normalize(lightPosition.xyz - worldPosition.xyz);
    vec3 normal = normalize(mat3(modelMatrix) * vertexNormal);
    
    // Force normal to face camera if it's facing away (fixes see-through issues)
    vec3 viewDirection = normalize(-worldPosition.xyz);
    if (dot(normal, viewDirection) < 0.0) {
        normal = -normal; // Flip the normal to face the camera
    }
    
    // Diffuse lighting
    float diffuse = max(dot(lightDirection, normal), 0.0);
    
    // Specular lighting (Phong reflection model)
    vec3 reflectDirection = reflect(-lightDirection, normal);
    float specular = pow(max(dot(viewDirection, reflectDirection), 0.0), shininess) * specularStrength;
    
    vec4 texcolor = Texel(tex, texcoord);
    
    // Only discard if texture is completely transparent
    if (texcolor.a < 0.1) { discard; }
    
    // Combine all lighting components with brightness modifier
    float lightness = (diffuse + specular) * brightness + ambient;
    
    // Apply solidness control - blend between lit surface and original color
    vec3 finalColor = mix((texcolor * color).rgb, (texcolor * color).rgb * lightness, solidness);
    
    return vec4(finalColor, solidness);
}