module GLSL
  module Collection
    VERTEX_SHADER_S3 = %q(
        #version 330 core
        layout(location=0) in vec3 pos;
        layout(location=1) in vec3 normal;
        layout(location=2) in float uva;
        layout(location=3) in vec3 color;
        uniform mat4 MVP;

        out vec3 fragVertex;
        out vec3 fragNormal;
        out float fragUVA;
        out vec3 fragColor;

        void main()
        {
          fragVertex = pos;
          fragNormal = normal;
          fragUVA = uva;
          fragColor = color;

          gl_Position = MVP * vec4(pos, 1.0);
        }
      )

      FRAGMENT_SHADER_S3 = %q(
          #version 330 core

          in vec3 fragVertex;
          in vec3 fragNormal;
          in float fragUVA;
          in vec3 fragColor;
          out vec4 out_color;
          vec4 outputColor0;
          vec4 outputColor1;

          uniform sampler2D texture1;
          uniform sampler2D texture2;
          uniform vec2 texture_center;

          void main()
          {
            vec3 lightNormal = normalize(vec3(0.0, 1.0, 0.0));
            float angle = dot(fragNormal, lightNormal);

            vec4 materialAmbientColor = vec4(fragColor, 1.0);
            vec4 abyr = vec4(0.0, 0.0, 0.0, 0.0);

            float dx = fragVertex.x - texture_center.x;
            float dz = fragVertex.z - texture_center.y;
            vec2 uv = vec2(dx, dz);
            abyr = texture(texture1, uv).rgba * fragUVA + texture(texture2, uv).rgba * (1.0 - fragUVA);


            vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);

            outputColor0 = abyr * abyr.a;
            outputColor1 = materialAmbientColor;

            out_color = outputColor0 + (outputColor1 - vec4(abyr.a));
            out_color = out_color * lightColor * max(angle, 0.1);
          }
        )

      FRAGMENT_SHADER_ORTHO2D = %q(
        #version 330 core

        out vec4 out_color;

        void main()
        {
          out_color = vec4(1.0, 0.2, 0.4, 1.0);
        }
      )
  end
end
