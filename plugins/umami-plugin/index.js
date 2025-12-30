export default function umamiPlugin() {
  return {
    name: 'umami-plugin',
    injectHtmlTags() {
      return {
        headTags: [
          {
            tagName: 'script',
            attributes: {
              defer: true,
              src: 'https://cloud.umami.is/script.js',
              'data-website-id': '50771638-05b4-4125-a8fd-c8e7e72e57e5',
            },
          },
        ],
      };
    },
  };
}
