import React, { useState, useRef } from 'react';
import styles from './HomeBlogList.module.css';
import { normalizeTag } from '../theme/utils/normalizeTag';

const req = require.context('../../blog', true, /\.mdx?$/);
const POSTS_PER_PAGE = 6;

function loadPosts() {
  return req.keys().map((key) => {
    const mod = req(key);
    const fm = mod.frontMatter || {};
    const fmTags = Array.isArray(fm.tags) ? fm.tags : fm.tags ? [fm.tags] : [];
    return {
      frontMatter: { ...fm, tags: fmTags },
      metadata: mod.metadata || {},
    };
  });
}

function getDisplayDate(post) {
  const { metadata } = post;
  if (typeof metadata.formattedDate === 'string') return metadata.formattedDate;
  if (metadata.date) {
    return new Date(metadata.date).toLocaleDateString('en-US', {
      month: 'long', day: 'numeric', year: 'numeric', timeZone: 'UTC',
    });
  }
  return '';
}

function getUnifiedTags(post) {
  const mdTags = post.metadata.tags ?? [];
  const fmTags = post.frontMatter.tags ?? [];
  const rawTags = mdTags.length > 0 ? mdTags : fmTags;
  return rawTags.map(normalizeTag);
}

export default function HomeBlogList() {
  const [page, setPage] = useState(0);
  const topRef = useRef(null);

  const allPosts = loadPosts().sort(
    (a, b) => new Date(b.metadata.date) - new Date(a.metadata.date)
  );

  if (allPosts.length === 0) return null;

  const totalPages = Math.ceil(allPosts.length / POSTS_PER_PAGE);
  const pagePosts = allPosts.slice(page * POSTS_PER_PAGE, (page + 1) * POSTS_PER_PAGE);

  function goTo(nextPage) {
    setPage(nextPage);
    if (topRef.current) {
      topRef.current.scrollIntoView({ block: 'start' });
    }
  }

  return (
    <div ref={topRef}>
      <div className={styles.grid}>
        {pagePosts.map((post) => {
          const tags = getUnifiedTags(post);
          return (
            <article key={post.metadata.permalink} className={styles.card}>
              <h2 className={styles.title}>
                <a href={post.metadata.permalink}>{post.frontMatter.title}</a>
              </h2>

              <div className={styles.meta}>
                <span>{getDisplayDate(post)}</span>
                {post.metadata.readingTime && (
                  <>
                    <span className={styles.metaDot}>·</span>
                    <span>{Math.ceil(post.metadata.readingTime)} min read</span>
                  </>
                )}
              </div>

              {post.frontMatter.description && (
                <p className={styles.description}>{post.frontMatter.description}</p>
              )}

              {tags.length > 0 && (
                <div className={styles.tags}>
                  {tags.map((tag) => (
                    <a key={tag.permalink} href={tag.permalink} className={styles.tag}>
                      {tag.label}
                    </a>
                  ))}
                </div>
              )}
            </article>
          );
        })}
      </div>

      {totalPages > 1 && (
        <div className={styles.pagination}>
          <button
            className={styles.pageBtn}
            onClick={() => goTo(page - 1)}
            disabled={page === 0}
          >
            ← prev
          </button>
          <span className={styles.pageInfo}>{page + 1} / {totalPages}</span>
          <button
            className={styles.pageBtn}
            onClick={() => goTo(page + 1)}
            disabled={page >= totalPages - 1}
          >
            next →
          </button>
        </div>
      )}
    </div>
  );
}
