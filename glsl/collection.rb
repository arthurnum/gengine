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
          uniform sampler2D texture4;
          uniform mat4 ModelView;
          uniform mat4 NormalView;

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
            vec4 fneye = NormalView * vec4(fn.xzy, 0.0);

            vec4 r = reflect(normalize(vec4(0.0, 1.0, 0.0, 0.0)), fneye);
            vec4 eyeCord = ModelView * vec4(fn.xzy, 0.0);
            vec4 v = normalize(-eyeCord);
            float spec = max( dot(v,r), 0.0 );
            vec4 specColor = pow(spec, 4) * vec4(1,1,1,1) * 0.5;

            vec3 lightNormal = normalize(vec3(0.0, 1.0, 0.0));
            float angle = dot(fn.xzy, lightNormal);
            vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
            vec2 uva = fragUVA * 40;
            vec4 abyr = texture(texture3, uva).rgba * fn.z + texture(texture4, uva).rgba * (1.0 - fn.z);

            // out_color = texture(texture3, uva) * lightColor * max(angle, 0.4);
            out_color = abyr * lightColor * max(angle, 0.5) + specColor;
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
          out vec3 fragVertex;

          void main()
          {
            fragUVA = uva;
            fragVertex = pos;

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

      FRAGMENT_SHADER_ORTHO2D_BLEND_INFO = %q(
        #version 330 core

        in vec2 fragUVA;

        out vec4 out_color;

        uniform sampler2D texture1;

        void main()
        {
          float blue = texture(texture1, fragUVA).b;

          if (blue > 0.0) {
            out_color = vec4(1.0, 1.0, 1.0, 1.0);
          }  else {
            out_color = vec4(0.0, 0.0, 0.0, 0.0);
          }
        }
      )

      FRAGMENT_SHADER_ORTHO2D_MENU_EDGE = %q(
        #version 330 core

        in vec2 fragUVA;
        in vec3 fragVertex;

        out vec4 out_color;

        uniform vec4 rect_info;

        void calculate_edge_color(in float i, out vec4 color) {
            float delta = 1.0 - (abs(i - 3.0) / 3.0);
            color = vec4(0.4, 0.9, 1.0, 1.0 * delta);
        }

        void calculate_edge_color2(in float i, in float k, out vec4 color) {
            float delta_i = 1.0 - (abs(i - 3.0) / 3.0);
            float delta_k = 1.0 - (abs(k - 3.0) / 3.0);
            float delta_min = min(delta_i, delta_k);
            float delta_max = max(delta_i, delta_k);

            if (i - 3.0 < 0) {
              if (k - 3.0 < 0) {
                color = vec4(0.4, 0.9, 1.0, 1.0 * delta_min);
              } else {
                color = vec4(0.4, 0.9, 1.0, 1.0 * delta_i);
              }
            } else if (k - 3.0 < 0) {
              color = vec4(0.4, 0.9, 1.0, 1.0 * delta_k);
            } else {
              color = vec4(0.4, 0.9, 1.0, 1.0 * delta_max);
            }
        }

        void main()
        {
          float left_x = fragVertex.x - rect_info.x;
          float right_x = rect_info.z - fragVertex.x + rect_info.x;
          float bottom_y = fragVertex.y - rect_info.y;
          float top_y = rect_info.w - fragVertex.y + rect_info.y;

          if (left_x < 6) {

            if (bottom_y < 6) {
              calculate_edge_color2(left_x, bottom_y, out_color);
            } else if (top_y < 6) {
              calculate_edge_color2(left_x, top_y, out_color);
            } else {
              calculate_edge_color(left_x, out_color);
            }

          } else if (right_x < 6) {

            if (bottom_y < 6) {
              calculate_edge_color2(right_x, bottom_y, out_color);
            } else if (top_y < 6) {
              calculate_edge_color2(right_x, top_y, out_color);
            } else {
              calculate_edge_color(right_x, out_color);
            }

          } else if (bottom_y < 6) {
            calculate_edge_color(bottom_y, out_color);
          } else if (top_y < 6) {
            calculate_edge_color(top_y, out_color);
          } else {
            out_color = vec4(0.0, 0.0, 0.0, 0.0);
          }
        }
      )
  end
end
