// Author: Casta-mere
async function umamiPlugin() {
  // 判断是否为开发环境
  const isDevelopment = "development" === process.env.NODE_ENV;

  return {
    name: "docusaurus-plugin-umami",

    injectHtmlTags() {
      if (isDevelopment) return;
      return {
        headTags: [
          {
            tagName: "link",
            attributes: {
              rel: "preconnect",
              // 换成你的域名
              href: "https://joeloveless.com/",
            },
          },
          {
            tagName: "script",
            attributes: {
              defer: true,
              // 这里就是上一步复制的跟踪代码中的内容
              src: "https://joeloveless.com/script.js",
              "data-website-id": "50771638-05b4-4125-a8fd-c8e7e72e57e5",
            },
          },
        ],
      };
    },
  };
}

module.exports = umamiPlugin;