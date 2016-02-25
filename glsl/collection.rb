module GLSL
  module Collection
    VERTEX_SHADER_S1 = %q(
        #version 330 core
        layout(location=0) in vec3 pos;
        layout(location=1) in vec3 normal;
        uniform mat4 MVP;
        uniform mat4 M;
        uniform mat4 V;
        uniform vec3 rayNear;
        uniform vec3 rayFar;

        out vec4 cursorColor;
        out float light_K;

        void ray_is_near(out float outputValue)
        {
          vec3 s = rayFar - rayNear;
          vec3 mo = rayFar - pos;
          vec3 ss = cross(mo, s);
          float d = length(ss) / length(s);

          outputValue = clamp( d / 0.15, 0.0, 1.0 );
        }

        void main()
        {
          vec3 light_source = vec3(3.0, 10.0, 0.0);

          // Vector that goes from the vertex to the camera, in camera space.
          // In camera space, the camera is at the origin (0,0,0).
          vec3 vertexPosition_cameraspace = ( V * M * vec4(pos, 1)).xyz;
          vec3 EyeDirection_cameraspace = vec3(0.0,0.0,0.0) - vertexPosition_cameraspace;

          // Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
          vec3 LightPosition_cameraspace = ( V * vec4(light_source, 1)).xyz;
          vec3 LightDirection_cameraspace = LightPosition_cameraspace + EyeDirection_cameraspace;

          // Normal of the the vertex, in camera space
          // Only correct if ModelMatrix does not scale the model ! Use its inverse transpose if not.
          vec3 Normal_cameraspace = ( V * M * vec4(normal, 0)).xyz;

          // Normal of the computed fragment, in camera space
          vec3 n = normalize( Normal_cameraspace );
          // Direction of the light (from the fragment to the light)
          vec3 l = normalize( LightDirection_cameraspace );

          light_K = clamp( dot(n, l), 0, 1 );
          gl_Position = MVP * vec4(pos, 1.0);

          float a = 0.0;
          ray_is_near(a);
          cursorColor = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.8, 0.8, 0.8, 1.0), a);
        }
      )

    FRAGMENT_SHADER_S1 = %q(
        #version 330 core
        in float light_K;
        in vec4 cursorColor;

        out vec4 out_color;
        void main()
        {
          vec4 materialColor = cursorColor;
          vec4 materialAmbientColor = vec4(0.1, 0.1, 0.1, 1.0) * materialColor;
          vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
          out_color = materialAmbientColor + materialColor * lightColor * light_K;
        }
      )

    VERTEX_SHADER_S2 = %q(
        #version 330 core
        layout(location=0) in vec3 pos;
        layout(location=1) in vec3 normal;
        layout(location=2) in vec3 color;
        uniform mat4 MVP;
        uniform mat4 M;
        uniform mat4 V;

        out vec4 matColor;
        out float light_K;

        void main()
        {
          vec3 light_source = vec3(3.0, 10.0, 0.0);

          // Vector that goes from the vertex to the camera, in camera space.
          // In camera space, the camera is at the origin (0,0,0).
          vec3 vertexPosition_cameraspace = ( V * M * vec4(pos, 1)).xyz;
          vec3 EyeDirection_cameraspace = vec3(0.0,0.0,0.0) - vertexPosition_cameraspace;

          // Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
          vec3 LightPosition_cameraspace = ( V * vec4(light_source, 1)).xyz;
          vec3 LightDirection_cameraspace = LightPosition_cameraspace + EyeDirection_cameraspace;

          // Normal of the the vertex, in camera space
          // Only correct if ModelMatrix does not scale the model ! Use its inverse transpose if not.
          vec3 Normal_cameraspace = ( V * M * vec4(normal, 0)).xyz;

          // Normal of the computed fragment, in camera space
          vec3 n = normalize( Normal_cameraspace );
          // Direction of the light (from the fragment to the light)
          vec3 l = normalize( LightDirection_cameraspace );

          light_K = clamp( dot(n, l), 0, 1 );
          gl_Position = MVP * vec4(pos, 1.0);

          matColor = vec4(color, 1.0);
        }
      )

    FRAGMENT_SHADER_S2 = %q(
        #version 330 core
        in float light_K;
        in vec4 matColor;

        out vec4 out_color;
        void main()
        {
          vec4 materialAmbientColor = vec4(0.1, 0.1, 0.1, 1.0) * matColor;
          vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
          out_color = materialAmbientColor + matColor * lightColor * light_K;
        }
      )

    VERTEX_SHADER_S3 = %q(
        #version 330 core
        layout(location=0) in vec3 pos;
        layout(location=1) in vec3 normal;
        layout(location=2) in float uva;
        layout(location=3) in vec3 color;
        uniform mat4 MVP;
        uniform mat4 M;
        uniform mat4 V;

        out vec3 fragVertex;
        out vec3 fragNormal;
        flat out float fragUVA;
        flat out vec3 fragColor;
        out mat4 model;
        out mat4 view;
        out vec2 text_coord;

        void main()
        {
          text_coord = vec2(pos.x / 200.0, pos.z / 200.0);
          fragVertex = pos;
          fragNormal = normal;
          fragUVA = uva;
          fragColor = color;
          model = M;
          view = V;

          gl_Position = MVP * vec4(pos, 1.0);
        }
      )

      FRAGMENT_SHADER_S3 = %q(
          #version 330 core

          in vec3 fragVertex;
          in vec3 fragNormal;
          flat in float fragUVA;
          flat in vec3 fragColor;
          in mat4 model;
          in mat4 view;
          out vec4 out_color;
          vec4 outputColor0;
          vec4 outputColor1;

          uniform sampler2D texture1;
          uniform sampler2D texture2;
          uniform vec2 texture_center;

          in vec2 text_coord;

          void main()
          {
            vec3 lightNormal = normalize(vec3(0.0, 1.0, 1.0));
            float angle = dot(fragNormal, lightNormal);

            vec4 materialAmbientColor = vec4(fragColor, 1.0);
            vec4 abyr = vec4(0.0, 0.0, 0.0, 0.0);

            if (fragUVA > 0) {
              float dx = fragVertex.x - texture_center.x;
              float dz = fragVertex.z - texture_center.y;
              float u = dx * 0.1;
              float v = dz * 0.1;
              vec2 uv = vec2(u, v);
              //abyr = texture(texture1, uv).rgba;
              if (fragUVA == 1) {
                abyr = texture(texture1, uv).rgba;
              }
            else if (fragUVA == 2) {
                abyr = texture(texture2, uv).rgba;
              }
            }

            vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);

            outputColor0 = abyr * abyr.a;
            outputColor1 = materialAmbientColor;

            out_color = outputColor0 + (outputColor1 - vec4(abyr.a));
            out_color = out_color * lightColor * angle;
          }
        )
  end
end
