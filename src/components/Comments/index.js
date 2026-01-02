import React from "react";
import Giscus from "@giscus/react";
import { useColorMode } from "@docusaurus/theme-common";
import BrowserOnly from "@docusaurus/BrowserOnly";

export default function Comments() {
  return (
    <BrowserOnly>
      {() => {
        const { colorMode } = useColorMode();

        return (
          <div style={{ marginTop: "2rem" }}>
            <Giscus
              id="General"
              repo="pacers31colts18/pacers31colts18.github.io"
              repoId="R_kgDONP9Srw"
              category="Blog"
              categoryId="DIC_kwDONP9Sr84C0f-1"
              mapping="pathname"
              strict="0"
              reactionsEnabled="1"
              emitMetadata="0"
              inputPosition="bottom"
              theme="preferred_color_scheme"
              lang="en"
              crossorigin="anonymous"
              async
            />
          </div>
        );
      }}
    </BrowserOnly>
  );
}
