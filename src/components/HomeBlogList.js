import React from 'react';
import styles from './HomeBlogList.module.css';
import { normalizeTag } from '../theme/utils/normalizeTag';

// Recursively import all MD/MDX files under /blog
const req = require.context('../../blog', true, /\.mdx?$/);

function loadPosts() {
  return req.keys().map((key) => {
    const mod = req(key);
    const fm = mod.frontMatter || {};

    // Normalize frontmatter tags into an array
    const fmTags = Array.isArray(fm.tags)
      ? fm.tags
      : fm.tags
      ? [fm.tags]
      : [];

    return {
      Content: mod.default,
      frontMatter: { ...fm, tags: fmTags },
      metadata: mod.metadata,
    };
  });
}

export default function HomeBlogList() {
  const posts = loadPosts()
    .sort((a, b) => new Date(b.metadata.date) - new Date(a.metadata.date))
    .slice(0, 7);

  const [featured, ...rest] = posts;

  // Helper to unify tags for homepage posts
  function getUnifiedTags(post) {
    const mdTags = post.metadata.tags ?? [];
    const fmTags = post.frontMatter.tags ?? [];

    const rawTags = mdTags.length > 0 ? mdTags : fmTags;
    return rawTags.map(normalizeTag);
  }

  return (
    <div>

      {/* FEATURED POST */}
      <article className={styles.featuredCard}>
        {featured.frontMatter.thumbnail && (
          <img
            src={featured.frontMatter.thumbnail}
            alt={featured.frontMatter.title}
            className={styles.featuredThumbnail}
          />
        )}

        <h2 className={styles.featuredTitle}>
          <a href={featured.metadata.permalink}>
            {featured.frontMatter.title}
          </a>
        </h2>

        <div className={styles.featuredMeta}>
          <span>{new Date(featured.metadata.date).toLocaleDateString()}</span>
          <span>•</span>
          <span>{featured.metadata.readingTime} min read</span>
        </div>

        {featured.frontMatter.description && (
          <p className={styles.featuredDescription}>
            {featured.frontMatter.description}
          </p>
        )}

        {/* Unified tags */}
        {getUnifiedTags(featured).length > 0 && (
          <div className={styles.featuredCategories}>
            {getUnifiedTags(featured).map((tag) => (
              <a
                key={tag.permalink}
                href={tag.permalink}
                className={styles.categoryBadge}
              >
                {tag.label}
              </a>
            ))}
          </div>
        )}
      </article>

      {/* GRID POSTS */}
      <div className={styles.grid}>
        {rest.map((post) => (
          <article key={post.metadata.permalink} className={styles.card}>

            <div className={styles.cardBar} />

            {post.frontMatter.thumbnail && (
              <img
                src={post.frontMatter.thumbnail}
                alt={post.frontMatter.title}
                className={styles.thumbnail}
              />
            )}

            <h2 className={styles.title}>
              <a href={post.metadata.permalink}>
                {post.frontMatter.title}
              </a>
            </h2>

            <div className={styles.meta}>
              <span>{new Date(post.metadata.date).toLocaleDateString()}</span>
              <span>•</span>
              <span>{post.metadata.readingTime} min read</span>
            </div>

            {post.frontMatter.description && (
              <p className={styles.description}>
                {post.frontMatter.description}
              </p>
            )}

            {/* Unified tags */}
            {getUnifiedTags(post).length > 0 && (
              <div className={styles.categories}>
                {getUnifiedTags(post).map((tag) => (
                  <a
                    key={tag.permalink}
                    href={tag.permalink}
                    className={styles.categoryBadge}
                  >
                    {tag.label}
                  </a>
                ))}
              </div>
            )}

          </article>
        ))}
      </div>
    </div>
  );
}
