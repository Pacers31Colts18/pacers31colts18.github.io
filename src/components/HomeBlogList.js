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
      metadata: mod.metadata || {},
    };
  });
}

/**
 * ALWAYS return a string.
 * Priority:
 * 1) metadata.formattedDate (exact blog-post value)
 * 2) frontMatter.date (string or Date → normalized)
 * 3) empty string
 */
function getDisplayDate(post) {
  const { metadata } = post;

  // 1) Exact same string the blog post uses
  if (typeof metadata.formattedDate === 'string') {
    return metadata.formattedDate;
  }

  // 2) Fallback: format metadata.date in UTC (never local)
  if (metadata.date) {
    return new Date(metadata.date).toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
      timeZone: 'UTC',
    });
  }

  return '';
}


export default function HomeBlogList() {
  const posts = loadPosts()
    .sort(
      (a, b) =>
        new Date(b.metadata.date) -
        new Date(a.metadata.date)
    )
    .slice(0, 7);

  if (posts.length === 0) {
    return null;
  }

  const [featured, ...rest] = posts;

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
          <span>{getDisplayDate(featured)}</span>
          <span>•</span>
          <span>{featured.metadata.readingTime} min read</span>
        </div>

        {featured.frontMatter.description && (
          <p className={styles.featuredDescription}>
            {featured.frontMatter.description}
          </p>
        )}

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
          <article
            key={post.metadata.permalink}
            className={styles.card}
          >
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
              <span>{getDisplayDate(post)}</span>
              <span>•</span>
              <span>{post.metadata.readingTime} min read</span>
            </div>

            {post.frontMatter.description && (
              <p className={styles.description}>
                {post.frontMatter.description}
              </p>
            )}

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
