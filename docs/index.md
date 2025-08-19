---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "VitePress On AWS"
  text: ""
  tagline: "A simple OpenTofu configuration to deploy highly available VitePress site on AWS using S3 and Cloudfront."
  image:
    src: /large-logo.svg
    alt: VitePress On AWS Logo
  actions:
    - theme: brand
      text: Quickstart
      link: /getting-started
    - theme: alt
      text: Github
      link: https://github.com/NickMrshll/vitepress-on-aws
    - theme: alt
      text: VitePress Project
      link: https://vitepress.dev/

features:
  - title: Highly Available & Serverless
    icon: ☁️
    details: Built on S3 and CloudFront for a fully serverless, globally distributed, and fault-tolerant architecture.

  - title: Infrastructure as Code with OpenTofu
    icon: 🧱
    details: Entire infrastructure is managed declaratively using OpenTofu, enabling automated, versioned, and repeatable deployments.

  - title: Fast & Lightweight Static Site Delivery
    icon: ⚡
    details: Powered by VitePress for blazing-fast builds and CloudFront CDN for instant content delivery at the edge.

  - title: Secure, Cost-Efficient, and Scalable
    icon: 🔒
    details: SSL by default, scalable with zero idle costs, and optimized for both performance and budget.
---
