// @ts-check
import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Joe Loveless',
  tagline: 'Sr. Endpoint Configuration and Automation Engineer',
  favicon: '/img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://joeloveless.com/',
  baseUrl: '/',
  organizationName: 'Pacers31Colts18',
  projectName: 'pacers31colts18.github.io',

  onBrokenLinks: 'throw',
  onBrokenAnchors: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: false,
        blog: {
          id: 'blog',
          routeBasePath: 'blog',
          path: './blog',
          showReadingTime: true,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      },
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },

    // Umami Analytics Script
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

    navbar: {
      items: [
        { to: '/', label: 'Home', position: 'left' },
        { to: '/blog', label: 'Blog', position: 'left' },
        { to: '/blog/tags', label: 'Tags', position: 'left' },
        { to: '/about', label: 'About', position: 'left' },
      ],
    },

    footer: {
      style: 'dark',
      links: [
        {
          items: [
            {
              html: `
                <div class="footer-icons">
                  <a href="https://github.com/pacers31colts18" class="footer-icon footer-icon-github" target="_blank" rel="noopener noreferrer"></a>
                  <a href="https://linkedin.com/in/joe-loveless" class="footer-icon footer-icon-linkedin" target="_blank" rel="noopener noreferrer"></a>
                  <a href="https://bsky.app/profile/joeloveless.com" class="footer-icon footer-icon-bluesky" target="_blank" rel="noopener noreferrer"></a>
                  <a href="https://infosec.exchange/@Pacers31Colts18" class="footer-icon footer-icon-mastodon" target="_blank" rel="noopener noreferrer"></a>
                  <a href="mailto:joe@joeloveless.com" class="footer-icon footer-icon-email"></a>
                  <a href="https://joeloveless.com/index.xml" class="footer-icon footer-icon-rss" target="_blank" rel="noopener noreferrer"></a>
                </div>
              `,
            },
          ],
        },
      ],
      copyright: `© ${new Date().getFullYear()} Joe Loveless`,
    },
  },
};

export default config;
