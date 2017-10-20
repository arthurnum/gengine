module GLSL
  module Collection
    VERTEX_SHADER_S3 = %q(
      #version 330 core

      layout(location=0) in vec3 pos;
      layout(location=1) in vec2 uva;
      uniform mat4 MVP;
      uniform mat4 model;
      uniform sampler2D hmap_texture;

      out vec2 fragUVA;
      out vec3 fragPos;

      void main()
      {
        fragUVA = uva;

        vec4 wave = texture(hmap_texture, uva);
        float s11 = wave.z * 50;

        vec4 verticeVector = vec4(pos.x, s11, pos.z, 1.0);
        fragPos = vec3(model * verticeVector);
        gl_Position = MVP * verticeVector;
      }
    )

    FRAGMENT_SHADER_S3 = %q(
      #version 330 core

      in vec2 fragUVA;
      in vec3 fragPos;

      out vec4 fragmentColor;

      uniform sampler2D hmap_texture;
      uniform sampler2D texture2;
      uniform sampler2D texture3;
      uniform sampler2D texture4;
      uniform vec2 texture_center;

      void main()
      {
        vec3 lightColor = vec3(1.0, 1.0, 1.0);
        vec3 lightPos = vec3(175.0, 200.0, 1875.0);
        vec3 lightDir = normalize(lightPos - fragPos);
        vec2 uva = fragUVA * 40;
        vec3 samplerColor = texture(texture3, uva).rgb;
        vec3 normal = normalize(texture(texture2, fragUVA).rgb);
        float diff = max(dot(normal, lightDir), 0.0);
        fragmentColor = vec4(samplerColor * lightColor * diff, 1.0);
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

    VERTEX_SHADER_CUBE = %q(
      #version 330 core
      layout(location=0) in vec3 pos;
      layout(location=1) in vec3 normal;

      uniform mat4 MVP;
      uniform mat4 model;

      out vec3 fragPos;
      out vec3 fragNormal;

      void main()
      {
        vec4 verticeVector = vec4(pos, 1.0);
        fragPos = vec3(model * verticeVector);
        fragNormal = normal;
        gl_Position = MVP * verticeVector;
      }
    )

    FRAGMENT_SHADER_CUBE = %q(
      #version 330 core
      uniform vec3 lightPos;

      in vec3 fragPos;
      in vec3 fragNormal;

      out vec4 out_color;

      void main()
      {
        vec3 lightColor = vec3(1.0, 1.0, 1.0);
        //vec3 lightPos = vec3(0.0, 30.0, 15.0);
        vec3 lightDir = normalize(lightPos - fragPos);

        vec3 samplerColor = vec3(0.1, 0.1, 0.2);

        float diff = max(dot(fragNormal, lightDir), 0.1);
        out_color = vec4(samplerColor + lightColor * diff, 1.0);
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

        void result_color(in float alpha, out vec4 color) {
          color = vec4(0.4, 0.9, 1.0, alpha);
        }

        void calculate_edge_color(in float i, out vec4 color) {
            float delta = 1.0 - (abs(i - 3.0) / 3.0);
            result_color(delta, color);
        }

        void calculate_edge_color2(in float i, in float k, out vec4 color) {
            float delta_i = 1.0 - (abs(i - 3.0) / 3.0);
            float delta_k = 1.0 - (abs(k - 3.0) / 3.0);
            float delta_min = min(delta_i, delta_k);
            float delta_max = max(delta_i, delta_k);

            if (i - 3.0 < 0) {
              if (k - 3.0 < 0) {
                result_color(delta_min, color);
              } else {
                result_color(delta_i, color);
              }
            } else if (k - 3.0 < 0) {
              result_color(delta_k, color);
            } else {
              result_color(delta_max, color);
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
