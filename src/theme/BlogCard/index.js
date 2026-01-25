import React from 'react';
import Link from '@docusaurus/Link';
import styles from '../BlogListPage/styles.module.css';
import { normalizeTag } from '../utils/normalizeTag';

export default function BlogCard({ fm = {}, md = {} }) {
  const title = fm.title ?? md.title;
  const description = fm.description ?? md.description;
  const image = fm.image ?? md.image;
  const permalink = md.permalink;
  const date = md.date;
  const readingTime = md.readingTime;

  // Prefer metadata tags (Docusaurus-prettified), fallback to frontmatter tags
  const rawTags =
    md.tags && md.tags.length > 0
      ? md.tags
      : fm.tags ?? [];

  // Normalize everything so labels match everywhere
  const tags = rawTags.map(normalizeTag);

  function formatDate(dateInput) {
    if (!dateInput) return '';

    const d = new Date(dateInput);
    if (isNaN(d)) return '';

    // 🔑 Use UTC parts, then rebuild as local date
    const localDate = new Date(
      d.getUTCFullYear(),
      d.getUTCMonth(),
      d.getUTCDate()
    );

    return localDate.toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    });
  }

  return (
    <article className={styles.card}>
      <div className={styles.topBar} />

      {image && (
        <Link to={permalink}>
          <img
            src={image}
            alt={title}
            className={styles.thumbnail}
          />
        </Link>
      )}

      <div className={styles.cardBody}>
        <h2 className={styles.cardTitle}>
          <Link to={permalink}>{title}</Link>
        </h2>

        {description && (
          <p className={styles.cardDescription}>
            {description}
          </p>
        )}

        <div className={styles.meta}>
          {date && (
            <time dateTime={date}>
              {formatDate(date)}
            </time>
          )}
          {readingTime && (
            <span> · {Math.ceil(readingTime)} min read</span>
          )}
        </div>

        {tags.length > 0 && (
          <div className={styles.tags}>
            {tags.map((tag) => (
              <Link
                key={tag.permalink}
                to={tag.permalink}
                className={styles.tag}
              >
                {tag.label}
              </Link>
            ))}
          </div>
        )}
      </div>
    </article>
  );
}
