import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "VitePress On AWS",
  description: "A simple OpenTofu configuration to deploy highly available VitePress site on AWS using S3 and Cloudfront.",
  head: [['link', { rel: 'icon', href: '/mini-logo.svg' }]],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/mini-logo.svg',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/getting-started' }
    ],
    search: {
      provider: 'local'
    },
    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'Getting Started', link: '/getting-started' },
          { text: 'Infrastructure Diagram', link: '/infrastructure-diagram' }
        ]
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/NickMrshll/vitepress-on-aws' }
    ],
  }
})
