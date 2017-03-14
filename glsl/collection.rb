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

    VERTEX_SHADER_S4 = %q(
      #version 330 core
        layout(location=0) in vec3 pos;
        layout(location=1) in vec2 uva;
        uniform mat4 MVP;
        uniform sampler2D texture1;

        out vec2 fragUVA;

        void main()
        {
          fragUVA = uva;

          vec4 wave = texture(texture1, uva);
          float s11 = wave.z * 50;

          gl_Position = MVP * vec4(pos.x, s11, pos.z, 1.0);
        }
      )

      FRAGMENT_SHADER_S4 = %q(
          #version 330 core

          uniform sampler2D texture1;
          uniform sampler2D texture2;
          uniform sampler2D texture3;

          in vec2 fragUVA;

          out vec4 out_color;

          vec4 outputColor1;

          const ivec3 off = ivec3(-1, 0, 1);

          void main()
          {
            vec3 fn11 = texture(texture2, fragUVA).xyz;
            vec3 fn01 = textureOffset(texture2, fragUVA, off.xy).xyz;
            vec3 fn21 = textureOffset(texture2, fragUVA, off.zy).xyz;
            vec3 fn10 = textureOffset(texture2, fragUVA, off.yx).xyz;
            vec3 fn12 = textureOffset(texture2, fragUVA, off.yz).xyz;

            vec3 fn00 = textureOffset(texture2, fragUVA, off.xx).xyz;
            vec3 fn20 = textureOffset(texture2, fragUVA, off.zx).xyz;
            vec3 fn02 = textureOffset(texture2, fragUVA, off.xz).xyz;
            vec3 fn22 = textureOffset(texture2, fragUVA, off.zz).xyz;

            vec3 fn = normalize(fn11+fn01+fn21+fn10+fn12+fn00+fn20+fn02+fn22);

            vec3 lightNormal = normalize(vec3(0.0, 1.0, 0.0));
            float angle = dot(fn.xzy, lightNormal);
            vec4 lightColor = vec4(1.0, 0.9, 0.9, 1.0);
            vec2 uva = fragUVA * 60;

            out_color = texture(texture3, uva) * lightColor * max(angle, 0.4);
          }
        )

      VERTEX_SHADER_CUBE = %(
        #version 330 core
        layout(location=0) in vec3 pos;
        uniform mat4 MVP;

        void main()
        {
          gl_Position = MVP * vec4(pos, 1.0);
        }
      )

      FRAGMENT_SHADER_CUBE = %(
        #version 330 core

        out vec4 out_color;

        void main()
        {
          out_color = vec4(0.8, 0.6, 0.2, 1.0);
        }
      )

      VERTEX_SHADER_ORTHO2D = %q(
          #version 330 core
          layout(location=0) in vec3 pos;
          layout(location=1) in vec2 uva;
          uniform mat4 MVP;

          out vec2 fragUVA;

          void main()
          {
            fragUVA = uva;

            gl_Position = MVP * vec4(pos, 1.0);
          }
        )

      FRAGMENT_SHADER_ORTHO2D = %q(
        #version 330 core

        in vec2 fragUVA;

        out vec4 out_color;

        uniform sampler2D texture1;

        void main()
        {
          out_color = texture(texture1, fragUVA).rgba;
        }
      )
  end
end
